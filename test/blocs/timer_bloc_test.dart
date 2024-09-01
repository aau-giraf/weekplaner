import 'dart:io';

import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/timer_running_mode.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/timer_model.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockActivityApi extends Mock implements ActivityApi {
  @override
  Stream<ActivityModel> update(ActivityModel activity, String userId) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }

  @override
  Stream<ActivityModel> updateTimer(ActivityModel activity, String userId) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }
}

void main() {
  late Api api;
  late MockActivityApi mockActivityApi;
  late TimerBloc timerMock;
  late ActivityModel activityModel;
  late final DisplayNameModel mockUser =
      DisplayNameModel(displayName: 'test', role: 'test', id: 'test');

  setUp(() {
    api = Api('any');
    mockActivityApi = MockActivityApi();
    api.activity = mockActivityApi;
    timerMock = TimerBloc(api);

    TestWidgetsFlutterBinding.ensureInitialized();

    di.clearAll();
    di.registerDependency<TimerBloc>(() => timerMock);
  });

  // tearDown(() {
  //   api = null;
  //   mockActivityApi = null;
  //   timerMock = null;
  //   activityModel = null;

  //   di.clearAll();
  // });

  ActivityModel createActivityModel(int fullLength, int progress,
      {bool paused = false}) {
    return ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: fullLength,
            paused: paused,
            progress: progress),
        isChoiceBoard: false);
  }

  test('Testing timerProgressNumeric progress is reset when timer is stopped',
      async((DoneFn done) {
    activityModel = createActivityModel(100, 20);
    timerMock.load(activityModel, user: mockUser);
    timerMock.playTimer();
    timerMock.stopTimer();

    timerMock.timerProgressNumeric.listen((List<int> t) {
      expect(t, <int>[0, 0, 0]);
    });

    done();
  }));

  test('Testing timerProgressNumeric progress is reset when timer is deleted',
      async((DoneFn done) {
    timerMock.load(createActivityModel(100, 20), user: mockUser);
    timerMock.playTimer();
    timerMock.deleteTimer();

    timerMock.timerProgressNumeric.listen((List<int> t) {
      expect(t, <int>[0, 0, 0]);
    });

    done();
  }));

  test('Testing timerProgressNumeric is streamed when timer is played',
      async((DoneFn done) {
    timerMock.load(createActivityModel(5000, 0), user: mockUser);
    timerMock.timerProgressNumeric.listen((List<int> t) {
      int i = 0;
      i += 1;
      if (i == 5) {
        final bool tIsPositive = t[0] > 0 || t[1] > 0 || t[2] > 0;
        expect(tIsPositive, true);
      }
    });
    done();
  }));

  test('Testing if timer is added to an acitivty without a timer already',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: null,
        isChoiceBoard: false);

    timerMock.timerIsInstantiated.skip(1).listen((bool b) {
      expect(b, isFalse);
      done();
    });

    timerMock.load(activityModel, user: mockUser);
  }));

  test('Testing if timerProgressNumeric is updated, if timer is paused',
      async((DoneFn done) {
    activityModel = createActivityModel(4000, 1, paused: true);
    timerMock.load(activityModel, user: mockUser);
    timerMock.initTimer();

    timerMock.timerProgressNumeric.skip(2).listen((List<int> t) {
      expect(t, <int>[0, 0, 3]);
    });
    timerMock.playTimer();
    sleep(const Duration(seconds: 1));
    timerMock.pauseTimer();

    done();
  }));

  test('Testing if timer is not added to an acitivty with a timer already',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: null, fullLength: 100, paused: false, progress: 50),
        isChoiceBoard: false);

    timerMock.timerIsInstantiated.skip(1).listen((bool b) {
      expect(b, isTrue);
      done();
    });

    timerMock.load(activityModel, user: mockUser);
  }));

  test('Testing when timer is added the timerInstantiated streams true',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: null,
        isChoiceBoard: false);

    timerMock.load(activityModel, user: mockUser);
    const Duration duration = Duration(seconds: 100);

    timerMock.timerIsInstantiated.skip(1).listen((bool b) {
      expect(b, isTrue);
      expect(activityModel.timer, isNotNull);
      expect(activityModel.timer!.progress, 0);
      expect(activityModel.timer!.fullLength, duration.inMilliseconds);
      expect(activityModel.timer!.paused, true);
      expect(activityModel.timer!.startTime, isNotNull);
      done();
    });

    timerMock.addTimer(duration);
  }));

  test('Testing timer starts running if its already set', async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 1000,
            paused: false,
            progress: 1),
        isChoiceBoard: false);

    timerMock.timerIsInstantiated.skip(2).listen((bool b) {
      expect(b, isTrue);
      done();
    });

    timerMock.load(activityModel, user: mockUser);
    timerMock.initTimer();
  }));

  test('Testing timer is instantiated when timer is not paused',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 1000,
            paused: false,
            progress: 1),
        isChoiceBoard: false);

    timerMock.timerRunningMode.skip(1).listen((TimerRunningMode m) {
      expect(m, TimerRunningMode.running);
      done();
    });

    timerMock.load(activityModel, user: mockUser);

    timerMock.initTimer();
  }));

  test('Testing if timer is paused the progress is updated',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 1000,
            paused: true,
            progress: 1),
        isChoiceBoard: false);

    timerMock.timerProgressStream.skip(1).listen((double d) {
      expect(
          d,
          1 -
              (1 /
                  activityModel.timer!.fullLength! *
                  (activityModel.timer!.fullLength! -
                      activityModel.timer!.progress!)));
      done();
    });

    timerMock.load(activityModel, user: mockUser);
    timerMock.initTimer();
  }));

  test('Testing when timer is played the progress is streamed',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 5000,
            paused: true,
            progress: 0),
        isChoiceBoard: false);

    timerMock.load(activityModel, user: mockUser);

    int i = 0;
    timerMock.timerProgressStream.listen((double d) {
      i += 1;
      if (i == 5) {
        expect(d, isPositive);
        done();
      }
    });

    timerMock.playTimer();
  }));

  test(
      'Testing when timer is paused, the progress is '
      'updated and the stream shows false', async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 10000,
            paused: true,
            progress: 0),
        isChoiceBoard: false);

    timerMock.load(activityModel, user: mockUser);

    timerMock.playTimer();
    expect(activityModel.timer!.paused, isFalse);

    Future<dynamic>.delayed(const Duration(seconds: 1), () {
      expect(activityModel.timer!.paused, isTrue);
      expect(activityModel.timer!.progress, isPositive);
    });

    timerMock.timerRunningMode.skip(1).listen((TimerRunningMode m) {
      expect(m, TimerRunningMode.paused);
      done();
    });

    timerMock.pauseTimer();
  }));

  test(
      'Testing when timer is stopped, timer status is paused, progress is '
      'reset, and running stream is false and progress stream is 0',
      async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 100,
            paused: false,
            progress: 20),
        isChoiceBoard: false);

    timerMock.load(activityModel, user: mockUser);
    timerMock.playTimer();
    timerMock.stopTimer();

    Future<dynamic>.delayed(const Duration(seconds: 1), () {
      expect(activityModel.timer!.paused, isTrue);
      expect(activityModel.timer!.progress, 0);
    });

    timerMock.timerRunningMode.listen((TimerRunningMode m) {
      expect(m, TimerRunningMode.stopped);
    });

    timerMock.timerProgressStream.listen((double d) {
      expect(d, 0);
      done();
    });
  }));

  test(
      'Testing when timer is deleted, timer is null, and initiated timer '
      'stream is false', async((DoneFn done) {
    activityModel = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        timer: TimerModel(
            startTime: DateTime.now(),
            fullLength: 100,
            paused: false,
            progress: 20),
        isChoiceBoard: false);

    timerMock.load(activityModel, user: mockUser);
    timerMock.deleteTimer();

    expect(activityModel.timer, isNull);
    timerMock.timerIsInstantiated.listen((bool b) {
      expect(b, isFalse);
    });

    timerMock.timerProgressStream.listen((double d) {
      expect(d, 0);
      done();
    });
  }));
}
