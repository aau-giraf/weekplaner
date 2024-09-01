// ignore_for_file: always_specify_types

import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockActivityApi extends Mock implements ActivityApi {}

void main() {
  Api api = Api('any');
  ActivityBloc bloc = ActivityBloc(api);
  MockWeekApi weekApi = MockWeekApi();
  MockActivityApi activityApi = MockActivityApi();

  final DisplayNameModel mockUser =
      DisplayNameModel(id: '50', displayName: 'testUser202', role: null);

  final ActivityModel mockActivity = ActivityModel(
      id: 1,
      pictograms: <PictogramModel>[],
      order: 0,
      state: ActivityState.Normal,
      isChoiceBoard: false);

  final List<ActivityModel> mockActivityList = <ActivityModel>[mockActivity];

  final WeekdayModel mockWeekdaymodel =
      WeekdayModel(day: Weekday.Monday, activities: mockActivityList);

  final List<WeekdayModel> mockWeekdaymodelList = <WeekdayModel>[
    mockWeekdaymodel
  ];

  final WeekModel mockWeekModel = WeekModel(
      thumbnail: null,
      name: 'testweek',
      days: mockWeekdaymodelList,
      weekNumber: 1,
      weekYear: 2010);

  void setupApiCalls() {
    when(() => weekApi.update(mockUser.id!, mockWeekModel.weekYear,
            mockWeekModel.weekNumber, mockWeekModel))
        .thenAnswer(
            (_) => rx_dart.BehaviorSubject<WeekModel>.seeded(mockWeekModel));
    when(() => activityApi.update(mockActivity, mockUser.id!)).thenAnswer(
        (_) => rx_dart.BehaviorSubject<ActivityModel>.seeded(mockActivity));
  }

  setUp(() {
    api = Api('any');
    weekApi = MockWeekApi();
    api.week = weekApi;
    activityApi = MockActivityApi();
    api.activity = activityApi;
    bloc = ActivityBloc(api);

    setupApiCalls();
  });

  test('Should set activity to completed', async((DoneFn done) {
    final ActivityModel localActivity = mockActivity;

    bloc.load(localActivity, mockUser);
    bloc.completeActivity();

    expect(localActivity.state, equals(ActivityState.Completed));
    done();
  }));

  test('Should set activity to cancelled', async((DoneFn done) {
    final ActivityModel localActivity = mockActivity;

    bloc.load(localActivity, mockUser);
    bloc.cancelActivity();

    expect(localActivity.state, equals(ActivityState.Canceled));
    done();
  }));
}
