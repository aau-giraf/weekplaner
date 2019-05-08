import 'dart:async';

import 'package:api_client/api/week_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/access_level_enum.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:api_client/api/api.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockAuth extends Mock implements AuthBloc {
  @override
  Observable<bool> get loggedIn => _loggedIn.stream;
  final BehaviorSubject<bool> _loggedIn = BehaviorSubject<bool>.seeded(true);

  @override
  Observable<WeekplanMode> get mode => _mode.stream;
  final BehaviorSubject<WeekplanMode> _mode =
      BehaviorSubject<WeekplanMode>.seeded(WeekplanMode.guardian);

  @override
  String loggedInUsername = 'Graatand';

  @override
  void authenticate(String username, String password) {
    // Mock the API and allow these 2 users to ?login?
    final bool status = (username == 'test' && password == 'test') ||
        (username == 'Graatand' && password == 'password');
    // If there is a successful login, remove the loading spinner,
    // and push the status to the stream
    if (status) {
      loggedInUsername = username;
    }
    _loggedIn.add(status);
    _mode.add(WeekplanMode.guardian);
  }

  @override
  void logout() {
    _loggedIn.add(false);
    _mode.add(WeekplanMode.citizen);
  }
}

final WeekModel mockWeek = WeekModel(
    weekYear: 2018,
    weekNumber: 21,
    name: 'Uge 1',
    thumbnail: PictogramModel(
        id: 25,
        title: 'grå',
        accessLevel: AccessLevel.PUBLIC,
        imageHash: null,
        imageUrl: null,
        lastEdit: null),
    days: mockWeekdayModels);

final List<WeekdayModel> mockWeekdayModels = <WeekdayModel>[
  WeekdayModel(activities: mockActivities, day: Weekday.Monday)
];

final List<ActivityModel> mockActivities = <ActivityModel>[
  ActivityModel(
      id: 1381,
      state: ActivityState.Normal,
      order: 0,
      isChoiceBoard: false,
      pictogram: PictogramModel(
          id: 25,
          title: 'grå',
          accessLevel: AccessLevel.PUBLIC,
          imageHash: null,
          imageUrl: null,
          lastEdit: null))
];

final UsernameModel mockUser = UsernameModel(id: '42', name: null, role: null);
final ActivityModel mockActivity = mockWeek.days[0].activities[0];

class MockScreen extends StatelessWidget {
  const MockScreen(this.activity);

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    return ShowActivityScreen(mockWeek, activity, mockUser);
  }
}

ActivityModel makeNewActivityModel() {
  return ActivityModel(
      id: 1381,
      state: ActivityState.Normal,
      order: 0,
      isChoiceBoard: false,
      pictogram: PictogramModel(
          id: 25,
          title: 'grå',
          accessLevel: AccessLevel.PUBLIC,
          imageHash: null,
          imageUrl: null,
          lastEdit: null));
}

void main() {
  ActivityBloc bloc;
  Api api;
  MockWeekApi weekApi;
  AuthBloc authBloc;
  TimerBloc timerBloc;

  void setupApiCalls() {
    when(weekApi.update(
            mockUser.id, mockWeek.weekYear, mockWeek.weekNumber, mockWeek))
        .thenAnswer((_) => BehaviorSubject<WeekModel>.seeded(mockWeek));
  }

  setUp(() {
    api = Api('any');
    weekApi = MockWeekApi();
    api.week = weekApi;
    authBloc = AuthBloc(api);
    bloc = ActivityBloc(api);
    timerBloc = TimerBloc();

    setupApiCalls();

    di.clearAll();
    di.registerDependency<ActivityBloc>((_) => bloc);
    di.registerDependency<AuthBloc>((_) => authBloc);
    di.registerDependency<PictogramImageBloc>((_) => PictogramImageBloc(api));
    di.registerDependency<ToolbarBloc>((_) => ToolbarBloc());
    di.registerDependency<TimerBloc>((_) => timerBloc);
  });

  testWidgets('renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
  });

  testWidgets('Has Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Activity pictogram is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump(Duration.zero);

    expect(find.byKey(Key(mockActivity.id.toString())), findsOneWidget);
  });

  testWidgets('ButtonBar is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('ButtonBarRender')), findsOneWidget);
  });

  testWidgets('Cancel activity button is rendered in guardian mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('CancelStateToggleButton')), findsOneWidget);
  });

  testWidgets('Complete activity button is NOT rendered in guardian mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('CompleteStateToggleButton')), findsNothing);
  });

  testWidgets('Cancel activity button is NOT rendered in citizen mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('CancelStateToggleButton')), findsNothing);
  });

  testWidgets('Activity has checkmark icon when completed',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Completed;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('IconCompleted')), findsOneWidget);
  });

  testWidgets('Activity has cancel icon when canceled',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Canceled;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets('Activity has no checkmark when Normal',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('IconCompleted')), findsNothing);
  });

  testWidgets('Activity is set to completed and an activity checkmark is shown',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconCompleted')), findsOneWidget);
  });

  testWidgets('Activity is set to canceled and an activity cross is shown',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CancelStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets('Activity is set to normal and no activity mark is shown',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivity.state = ActivityState.Completed;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconCompleted')), findsNothing);
    expect(find.byKey(const Key('IconCanceled')), findsNothing);
  });

  testWidgets('Test if timer box is shown.', (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pump();
    expect(find.byKey(const Key('OverallTimerBoxKey')), findsOneWidget);
  });

  testWidgets('Test that timer box is not shown in citizen mode.',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pump();
    expect(find.byKey(const Key('OverallTimerBoxKey')), findsNothing);
  });

  testWidgets('Test rendering of content of non-initialized timer box',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pump();
    expect(find.byKey(const Key('TimerTitleKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerNotInitGuardianKey')), findsOneWidget);
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerButtonRow')), findsNothing);
  });

  Future<void> _openTimePickerAndConfirm(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('AddTimerButtonKey')));
    await tester.pump();
    const int hours = 1;
    const int minutes = 2;
    const int seconds = 3;
    await tester.enterText(
        find.byKey(const Key('TimerTextFieldKey')), hours.toString());
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('MinutterTextFieldKey')), minutes.toString());
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('SekunderTextFieldKey')), seconds.toString());
    await tester.pump();
    await tester.tap(find.byKey(const Key('TimePickerDialogAcceptButton')));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Test rendering of content of initialized timer box guardian mode',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pump();
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    await _openTimePickerAndConfirm(tester);
    expect(find.byKey(const Key('TimerTitleKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerButtonRow')), findsOneWidget);
  });

  testWidgets('Test rendering of content of initialized timer box citizen mode',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pump();
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    await _openTimePickerAndConfirm(tester);
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('AddTimerButtonKey')), findsNothing);
    expect(find.byKey(const Key('TimerTitleKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerButtonRow')), findsOneWidget);
  });

  testWidgets(
      'Test rendering of content of initialized timer buttons guardian mode',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    expect(find.byKey(const Key('TimerPlayButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerStopButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerDeleteButtonKey')), findsOneWidget);
    await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerPauseButtonKey')), findsOneWidget);
    await tester.tap(find.byKey(const Key('TimerPauseButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerPlayButtonKey')), findsOneWidget);
  });

  testWidgets(
      'Test rendering of content of initialized timer buttons citizen mode',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerPlayButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerStopButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerDeleteButtonKey')), findsNothing);
    await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerPauseButtonKey')), findsOneWidget);
    await tester.tap(find.byKey(const Key('TimerPauseButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerPlayButtonKey')), findsOneWidget);
  });

  testWidgets('Test that timer stop button probs a confirm dialog',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    await tester.tap(find.byKey(const Key('TimerStopButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerStopConfirmDialogKey')), findsOneWidget);
  });

  testWidgets('Test that timer delete button probs a confirm dialog',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    await tester.tap(find.byKey(const Key('TimerDeleteButtonKey')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('TimerDeleteConfirmDialogKey')), findsOneWidget);
  });

  testWidgets('Test that timerbloc registers the timer initlization',
      (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    final StreamSubscription<bool> listenForFalse =
        timerBloc.timerIsInstantiated.listen((bool init) {
      expect(init, isFalse);
      done.complete();
    });
    await done.future;
    listenForFalse.cancel();
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    timerBloc.timerIsInstantiated.listen((bool init) {
      expect(init, isTrue);
    });
  });

  testWidgets(
      'Test that timerbloc knows whether the timer is running or paused',
      (WidgetTester tester) async {
    final Completer<bool> checkNotRun = Completer<bool>();
    final Completer<bool> checkRunning = Completer<bool>();
    await tester
        .pumpWidget(MaterialApp(home: MockScreen(makeNewActivityModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester);
    final StreamSubscription<bool> listenForRunningFalse =
        timerBloc.timerIsRunning.listen((bool running) {
      expect(running, isFalse);
      checkNotRun.complete();
    });
    await checkNotRun.future;
    listenForRunningFalse.cancel();

    await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));
    await tester.pumpAndSettle();
    final StreamSubscription<bool> listenForRunningTrue =
        timerBloc.timerIsRunning.listen((bool running) {
      expect(running, isTrue);
      checkRunning.complete();
    });
    await checkRunning.future;
    listenForRunningTrue.cancel();
    await tester.tap(find.byKey(const Key('TimerPauseButtonKey')));
    await tester.pumpAndSettle();
    timerBloc.timerIsRunning.listen((bool running) {
      expect(running, isFalse);
    });
  });
}
