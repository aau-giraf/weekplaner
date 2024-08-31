import 'dart:async';
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart' as orientation;
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/timer_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/timer_running_mode.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';

import '../test_image.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }
}

class MockAuth extends Mock implements AuthBloc {
  @override
  Stream<bool> get loggedIn => _loggedIn.stream;
  final rx_dart.BehaviorSubject<bool> _loggedIn =
      rx_dart.BehaviorSubject<bool>.seeded(true);

  @override
  Stream<WeekplanMode> get mode => _mode.stream;
  final rx_dart.BehaviorSubject<WeekplanMode> _mode =
      rx_dart.BehaviorSubject<WeekplanMode>.seeded(WeekplanMode.guardian);

  String loggedInUsername = 'Graatand';

  @override
  Future<void> authenticate(String username, String password) async {
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

class MockActivityBloc extends Mock implements ActivityBloc {
  MockActivityBloc();

  @override
  void setAlternateName(String name) {
    mockActivity.title = name;
  }

  @override
  ActivityModel getActivity() {
    return mockActivity;
  }

  @override
  void completeActivity() {
    mockActivity.state = mockActivity.state == ActivityState.Completed
        ? ActivityState.Normal
        : ActivityState.Completed;
    _activityModelStream.add(mockActivity);
  }

  @override
  Stream<ActivityModel> get activityModelStream => _activityModelStream.stream;

  final rx_dart.BehaviorSubject<ActivityModel> _activityModelStream =
      rx_dart.BehaviorSubject<ActivityModel>.seeded(mockActivity);

  /// Mark the selected activity as cancelled.Toggle function, if activity is
  /// Canceled, it will become Normal
  @override
  void cancelActivity() {
    mockActivity.state = mockActivity.state == ActivityState.Canceled
        ? ActivityState.Normal
        : ActivityState.Canceled;
    _activityModelStream.add(mockActivity);
  }

  ///Method to get the standard tile from the pictogram
  @override
  void getStandardTitle() {
    mockActivity.title = mockActivity.pictograms.first.title;
    update();
  }

  @override
  void dispose() {
    _activityModelStream.close();
  }
}

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

class MockPictogramApi extends Mock implements PictogramApi {
  @override
  Stream<Image> getImage(int id) {
    return rx_dart.BehaviorSubject<Image>.seeded(sampleImage);
  }
}

final List<PictogramModel> mockPictograms = <PictogramModel>[
  PictogramModel(
      id: 25,
      title: 'grå',
      accessLevel: AccessLevel.PUBLIC,
      imageHash: null,
      imageUrl: null,
      lastEdit: null),
  PictogramModel(
      id: 26,
      title: 'blå',
      accessLevel: AccessLevel.PUBLIC,
      imageHash: null,
      imageUrl: null,
      lastEdit: null),
  PictogramModel(
      id: 27,
      title: 'giraf-farvet',
      accessLevel: AccessLevel.PUBLIC,
      imageHash: null,
      imageUrl: null,
      lastEdit: null),
  PictogramModel(
      id: 28,
      title: 'orange',
      accessLevel: AccessLevel.PUBLIC,
      imageHash: null,
      imageUrl: null,
      lastEdit: null),
];

final WeekModel mockWeek = WeekModel(
    weekYear: 2018,
    weekNumber: 21,
    name: 'Uge 1',
    thumbnail: mockPictograms.first,
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
      pictograms: <PictogramModel>[mockPictograms[1]],
      title: mockPictograms[1].title)
];

final DisplayNameModel mockUser =
    DisplayNameModel(id: '42', displayName: 'mockUser', role: null);
final DisplayNameModel mockUser2 =
    DisplayNameModel(id: '43', displayName: 'mockUser2', role: null);
final ActivityModel mockActivity = mockWeek.days![0].activities![0];

WeekdayModel mockWeekDayModel() {
  return WeekdayModel(activities: <ActivityModel>[
    ActivityModel(
        id: 1381,
        state: ActivityState.Normal,
        order: 0,
        isChoiceBoard: false,
        pictograms: <PictogramModel>[mockPictograms[1]],
        title: mockPictograms[1].title)
  ], day: Weekday.Monday);
}

class MockScreen extends StatelessWidget {
  const MockScreen(
      this.activity, this.weekplanBloc, this.timerBloc, this.weekdayModel);

  final ActivityModel activity;
  final WeekplanBloc weekplanBloc;
  final WeekdayModel weekdayModel;
  final TimerBloc timerBloc;
  @override
  Widget build(BuildContext context) {
    return ShowActivityScreen(
        activity, mockUser, weekplanBloc, timerBloc, weekdayModel,
        key: UniqueKey());
  }
}

ActivityModel makeNewActivityModel() {
  return ActivityModel(
      id: 1381,
      state: ActivityState.Normal,
      order: 0,
      isChoiceBoard: false,
      pictograms: <PictogramModel>[mockPictograms.first],
      title: mockPictograms.first.title);
}

ActivityModel makeNewCompletedActitvyModel() {
  return ActivityModel(
      id: 1381,
      state: ActivityState.Completed,
      order: 0,
      isChoiceBoard: false,
      pictograms: <PictogramModel>[mockPictograms.first],
      title: mockPictograms.first.title);
}

ActivityModel mockActivityModelWithTimer() {
  return ActivityModel(
      id: 1381,
      state: ActivityState.Normal,
      order: 0,
      isChoiceBoard: false,
      pictograms: <PictogramModel>[mockPictograms.first],
      timer: TimerModel(
          startTime: DateTime.now(),
          progress: 0,
          fullLength: const Duration(seconds: 5).inMilliseconds,
          paused: true),
      title: mockPictograms.first.title);
}

ActivityModel mockActivityModelWithCompletedTimer() {
  return ActivityModel(
      id: 1381,
      state: ActivityState.Normal,
      order: 0,
      isChoiceBoard: false,
      pictograms: <PictogramModel>[mockPictograms.first],
      timer: TimerModel(
          startTime: DateTime.now(),
          progress: const Duration(seconds: 5).inMilliseconds,
          fullLength: const Duration(seconds: 5).inMilliseconds,
          paused: true),
      title: 'Activity1');
}

final SettingsModel mockSettings = SettingsModel(
  orientation: orientation.Orientation.Portrait,
  completeMark: CompleteMark.Checkmark,
  cancelMark: CancelMark.Cross,
  defaultTimer: DefaultTimer.PieChart,
  timerSeconds: 1,
  activitiesCount: 1,
  theme: GirafTheme.GirafYellow,
  weekDayColors: null,
  lockTimerControl: false,
  pictogramText: false,
);

final SettingsModel mockSettings2 = SettingsModel(
  orientation: orientation.Orientation.Portrait,
  completeMark: CompleteMark.Checkmark,
  cancelMark: CancelMark.Cross,
  defaultTimer: DefaultTimer.PieChart,
  timerSeconds: 1,
  activitiesCount: 1,
  theme: GirafTheme.GirafYellow,
  weekDayColors: null,
  lockTimerControl: true,
  pictogramText: false,
);

void main() {
  late ActivityBloc bloc;
  late Api api;
  late MockWeekApi weekApi;
  late AuthBloc authBloc;
  late TimerBloc timerBloc;
  late WeekplanBloc weekplanBloc;

  void setupApiCalls() {
    when(() => weekApi.update(
            mockUser.id!, mockWeek.weekYear, mockWeek.weekNumber, mockWeek))
        .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(mockWeek));

    when(() => api.user.getSettings(any())).thenAnswer((_) {
      return Stream<SettingsModel>.value(mockSettings);
    });
  }

  setUp(() {
    api = Api('any');
    weekApi = MockWeekApi();
    api.user = MockUserApi();
    api.week = weekApi;
    api.pictogram = MockPictogramApi();
    api.activity = MockActivityApi();
    authBloc = AuthBloc(api);
    bloc = MockActivityBloc();
    timerBloc = TimerBloc(api);
    weekplanBloc = WeekplanBloc(api);
    timerBloc.load(mockActivity,
        user: DisplayNameModel(id: '10', displayName: 'Test', role: ''));
    setupApiCalls();

    di.clearAll();
    di.registerDependency<ActivityBloc>(() => bloc);
    di.registerDependency<AuthBloc>(() => authBloc);
    di.registerDependency<Api>(() => api);
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<TimerBloc>(() => timerBloc);
    di.registerDependency<WeekplanBloc>(() => weekplanBloc);
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
  });

  testWidgets('renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
  });

  testWidgets('Has Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Activity pictogram is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump(Duration.zero);

    expect(find.byKey(Key(mockActivity.id.toString())), findsOneWidget);
  });

  testWidgets('ButtonBar is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('ButtonBarRender')), findsOneWidget);
  });

  testWidgets('Cancel activity button is rendered in guardian mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('CancelStateToggleButton')), findsOneWidget);
  });

  testWidgets('Complete activity button is rendered in guardian mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('CompleteStateToggleButton')), findsOneWidget);
  });

  testWidgets('Cancel activity button is NOT rendered in citizen mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('CancelStateToggleButton')), findsNothing);
  });

  testWidgets('Activity has checkmark icon when completed',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Completed;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('Activity has cancel icon when canceled',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Canceled;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets('Activity has no checkmark when Normal',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('IconCompleted')), findsNothing);
  });

  testWidgets('Activity is set to completed and an activity checkmark is shown',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('Activity is set to canceled and an activity cross is shown',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

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
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconComplete')), findsNothing);
  });

  testWidgets('Add ChoiceBoard button is visible in guardian mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('AddChoiceBoardButtonKey')), findsOneWidget);
  });

  testWidgets('Add ChoiceBoard button is not visible in citizen mode',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('AddChoiceBoardButtonKey')), findsNothing);
  });

  testWidgets(
      'Add ChoiceBoard button is not visible if the activity is cancelled',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.state = ActivityState.Canceled;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('AddChoiceBoardButtonKey')), findsNothing);
  });

  testWidgets('Add ChoiceBoard button is visible if the activity is normal',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('AddChoiceBoardButtonKey')), findsOneWidget);
  });

  testWidgets(
      'ChoiceBoard-button text is Tilføj Valgmulighed" when not a ChoiceBoard',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;
    mockActivity.state = ActivityState.Normal;

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tilføj Valgmulighed'), findsOneWidget);
  });

  testWidgets(
      'ChoiceBoard-button text is "Tilføj Valgmulighed" when is ChoiceBoard',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tilføj Valgmulighed'), findsOneWidget);
  });

  testWidgets('No ChoiceBoardParts when not a ChoiceBoard',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = <PictogramModel>[mockPictograms.first];

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('ChoiceBoardPart')), findsNothing);
  });

  testWidgets('2 ChoiceBoardParts when activity has 2 pictograms',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = mockPictograms.sublist(0, 2); // 2 parts in list

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('ChoiceBoardPart')), findsNWidgets(2));
  });

  testWidgets('3 ChoiceBoardParts when activity has 3 pictograms',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = mockPictograms.sublist(0, 3); // 3 parts in list

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('ChoiceBoardPart')), findsNWidgets(3));
  });

  testWidgets('4 ChoiceBoardParts when activity has 4 pictograms',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = mockPictograms;

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();

    expect(find.byKey(const Key('ChoiceBoardPart')), findsNWidgets(4));
  });

  testWidgets('Test if timer box is shown.', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pump();
    expect(find.byKey(const Key('OverallTimerBoxKey')), findsOneWidget);
  });

  testWidgets('Test that timer box is not shown in citizen mode.',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pump();
    expect(find.byKey(const Key('OverallTimerBoxKey')), findsNothing);
  });

  testWidgets('Test rendering of content of non-initialized timer box',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pump();
    expect(find.byKey(const Key('TimerTitleKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerNotInitGuardianKey')), findsOneWidget);
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerButtonRow')), findsNothing);
  });

  Future<void> _openTimePickerAndConfirm(
      WidgetTester tester, int seconds, int minutes, int hours) async {
    await tester.tap(find.byKey(const Key('AddTimerButtonKey')));
    await tester.pump();
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
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pump();
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
    expect(find.byKey(const Key('TimerTitleKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);
    expect(find.byKey(const Key('TimerButtonRow')), findsOneWidget);
  });

  testWidgets('Test rendering of content of initialized timer box citizen mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pump();
    expect(find.byKey(const Key('AddTimerButtonKey')), findsOneWidget);
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
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
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(
            mockActivity, weekplanBloc, timerBloc, mockWeekDayModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
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
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
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
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
    await tester.tap(find.byKey(const Key('TimerStopButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerStopConfirmDialogKey')), findsNothing);
  });

  testWidgets('Test that timer delete button probs a confirm dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
    await tester.tap(find.byKey(const Key('TimerDeleteButtonKey')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('TimerDeleteConfirmDialogKey')), findsOneWidget);
  });

  testWidgets('Test that timerbloc registers the timer initlization',
      (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pumpAndSettle();
    final StreamSubscription<bool> listenForFalse =
        timerBloc.timerIsInstantiated.listen((bool init) {
      expect(init, isFalse);
      done.complete(true);
    });
    await done.future;
    listenForFalse.cancel();
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
    timerBloc.timerIsInstantiated.listen((bool init) {
      expect(init, isTrue);
    });
  });

  testWidgets(
      'Test that timerbloc knows whether the timer is running or paused',
      (WidgetTester tester) async {
    final Completer<bool> checkNotRun = Completer<bool>();
    final Completer<bool> checkRunning = Completer<bool>();
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
            mockWeekDayModel())));
    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 3, 2, 1);
    final StreamSubscription<TimerRunningMode> listenForNotInitialized =
        timerBloc.timerRunningMode.listen((TimerRunningMode running) {
      expect(running, TimerRunningMode.initialized);
      checkNotRun.complete(true);
    });
    await checkNotRun.future;
    listenForNotInitialized.cancel();

    await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));
    await tester.pumpAndSettle();
    final StreamSubscription<TimerRunningMode> listenForRunningTrue =
        timerBloc.timerRunningMode.listen((TimerRunningMode running) {
      expect(running, TimerRunningMode.running);
      checkRunning.complete(true);
    });
    await checkRunning.future;
    listenForRunningTrue.cancel();
    await tester.tap(find.byKey(const Key('TimerPauseButtonKey')));
    await tester.pumpAndSettle();
    timerBloc.timerRunningMode.listen((TimerRunningMode running) {
      expect(running, TimerRunningMode.paused);
    });
  });

  testWidgets('Timer not visivle when activity cancelled',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Canceled;

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
      mockActivityModelWithTimer(),
      mockUser,
      weekplanBloc,
      timerBloc,
      mockWeekDayModel(),
      key: UniqueKey(),
    )));

    expect(find.byKey(const Key('OverallTimerBoxKey')), findsNothing);

    mockActivity.state = ActivityState.Normal;
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('OverallTimerBoxKey')), findsOneWidget);
  });

  testWidgets('Test that play button does not appear when timer is complete',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      authBloc.setMode(WeekplanMode.guardian);
      final Completer<bool> checkCompleted = Completer<bool>();
      await tester.pumpWidget(MaterialApp(
          home: MockScreen(makeNewActivityModel(), weekplanBloc, timerBloc,
              mockWeekDayModel())));
      await tester.pumpAndSettle();
      await _openTimePickerAndConfirm(tester, 1, 0, 0);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));

      await tester.pumpAndSettle();
      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 2), () async {
        final StreamSubscription<TimerRunningMode> listenForCompleted =
            timerBloc.timerRunningMode.skip(1).listen((TimerRunningMode m) {
          expect(m, TimerRunningMode.completed);
          checkCompleted.complete(true);
        });
        await checkCompleted.future;
        listenForCompleted.cancel();
        expect(find.byKey(const Key('TimerPlayButtonKey')), findsNothing);
      });
    });
  });

  testWidgets('Test that Stop dialog pops up when timer is stopped',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);

    await tester.pumpWidget(MaterialApp(
        home: MockScreen(makeNewActivityModel(), weekplanBloc, TimerBloc(api),
            mockWeekDayModel())));

    await tester.pumpAndSettle();
    await _openTimePickerAndConfirm(tester, 1, 1, 1);
    await tester.tap(find.byKey(const Key('TimerStopButtonKey')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('TimerStopConfirmDialogKey')), findsNothing);
  });

  testWidgets('Only have a play button for timer when lockTimerControl is true',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      when(api.user.getSettings(any as String) as Function()).thenAnswer((_) {
        return Stream<SettingsModel>.value(mockSettings2);
      });
      authBloc.setMode(WeekplanMode.citizen);
      await tester.pumpWidget(MaterialApp(
          home: MockScreen(mockActivityModelWithTimer(), weekplanBloc,
              timerBloc, mockWeekDayModel())));

      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/play.png') &&
              widget.key == const Key('TimerPlayButtonKey')),
          findsOneWidget);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/pause.png') &&
              widget.key == const Key('TimerPauseButtonKey')),
          findsNothing);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/Stop.png') &&
              widget.key == const Key('TimerStopButtonKey')),
          findsNothing);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image ==
                  const AssetImage('assets/icons/delete.png') &&
              widget.key == const Key('TimerDeleteButtonKey')),
          findsNothing);
      await tester.tap(find.byKey(const Key('TimerPlayButtonKey')));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/play.png') &&
              widget.key == const Key('TimerPlayButtonKey')),
          findsNothing);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/pause.png') &&
              widget.key == const Key('TimerPauseButtonKey')),
          findsNothing);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image == const AssetImage('assets/icons/Stop.png') &&
              widget.key == const Key('TimerStopButtonKey')),
          findsNothing);
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is GirafButton &&
              widget.icon.image ==
                  const AssetImage('assets/icons/delete.png') &&
              widget.key == const Key('TimerDeleteButtonKey')),
          findsNothing);
    });
  });

  testWidgets(
      'No buttons for timer when an activity with a completed timer is chosen',
      (WidgetTester tester) async {
    when(api.user.getSettings(any as String) as Function()).thenAnswer((_) {
      return Stream<SettingsModel>.value(mockSettings2);
    });
    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: MockScreen(mockActivityModelWithCompletedTimer(), weekplanBloc,
            timerBloc, mockWeekDayModel())));
    await tester.pumpAndSettle();

    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafButton &&
            widget.icon.image == const AssetImage('assets/icons/play.png') &&
            widget.key == const Key('TimerPlayButtonKey')),
        findsNothing);
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafButton &&
            widget.icon.image == const AssetImage('assets/icons/pause.png') &&
            widget.key == const Key('TimerPauseButtonKey')),
        findsNothing);
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafButton &&
            widget.icon.image == const AssetImage('assets/icons/Stop.png') &&
            widget.key == const Key('TimerStopButtonKey')),
        findsNothing);
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafButton &&
            widget.icon.image == const AssetImage('assets/icons/delete.png') &&
            widget.key == const Key('TimerDeleteButtonKey')),
        findsNothing);
  });

  testWidgets('Choiceboard textfield loads', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = mockPictograms;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
      mockActivity,
      mockUser,
      weekplanBloc,
      timerBloc,
      mockWeekDayModel(),
      key: UniqueKey(),
    )));
    await tester.pump();
    expect(find.byKey(const Key('ChoiceBoardNameText')), findsOneWidget);
  });

  testWidgets('ChoiceBoard name can be changed', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    mockActivity.state = ActivityState.Normal;
    mockActivity.pictograms = mockPictograms;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(
            mockActivity, mockUser, weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('ChoiceBoardNameText')), 'nametest');
    expect(find.text('nametest'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ChoiceBoardNameButton')));
    await tester.pumpAndSettle();
    expect(find.text('nametest'), findsOneWidget);
  });

  testWidgets(
      'Activity state is normal when an activity has been cancelled and'
      ' non-cancelled and timer added', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);

    final ActivityModel activistModel = makeNewActivityModel();
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(activistModel, mockUser, weekplanBloc,
            timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CancelStateToggleButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('CancelStateToggleButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('AddTimerButtonKey')));
    await tester.pumpAndSettle();

    expect(activistModel.state, ActivityState.Normal);
  });

  testWidgets(
      'Button for save alternate name to'
      ' activity is rendered in guardian mode', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('SavePictogramTextForCitizenBtn')),
        findsOneWidget);
  });

  testWidgets(
      'Button for update activity title to pictogram title'
      ' is rendered in guaridan mode', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('GetStandardPictogramTextForCitizenBtn')),
        findsOneWidget);
  });

  testWidgets(
      'Textfield for typing alternate name is rendered in guardian'
      ' mode and isChoiceBoard is false', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('AlternateNameTextField')), findsOneWidget);
  });

  testWidgets(
      'Button for save alternate name to activity title'
      ' is not rendered in citizen mode', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivity.isChoiceBoard = false;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('SavePictogramTextForCitizenBtn')), findsNothing);
  });

  testWidgets(
      'Button for update activity title to pictogram title'
      ' is not rendered in citizen mode', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivity.isChoiceBoard = false;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('GetStandardPictogramTextForCitizenBtn')),
        findsNothing);
  });

  testWidgets(
      'Button for save alternate name to activity title is not rendered'
      ' while isChoiceBoard is true', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const Key('SavePictogramTextForCitizenBtn')), findsNothing);
  });

  testWidgets(
      'Button for update activity title to pictogram title is not'
      ' rendered while isChoiceBoard is true', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = true;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('GetStandardPictogramTextForCitizenBtn')),
        findsNothing);
  });

  testWidgets('Activity title is updated on button press',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      authBloc.setMode(WeekplanMode.guardian);
      mockActivity.isChoiceBoard = false;

      await tester.pumpWidget(MaterialApp(
          home: ShowActivityScreen(mockActivity, mockUser2, weekplanBloc,
              timerBloc, mockWeekDayModel(),
              key: UniqueKey())));

      await tester.pump();

      expect(bloc.getActivity().title, 'blå');
      await tester.enterText(
          find.byKey(const Key('AlternateNameTextField')), 'test');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('SavePictogramTextForCitizenBtn')));
      await tester.pumpAndSettle();

      expect(bloc.getActivity().title, 'test');
    });
  });

  testWidgets('Activity title is set to pictogram title on button press',
      (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockActivity.isChoiceBoard = false;

    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockActivityModelWithTimer(), mockUser2,
            weekplanBloc, timerBloc, mockWeekDayModel(),
            key: UniqueKey())));

    // Change activity title before getting original
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('AlternateNameTextField')), 'test');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('SavePictogramTextForCitizenBtn')));

    // Get original title
    await tester
        .tap(find.byKey(const Key('GetStandardPictogramTextForCitizenBtn')));
    await tester.pumpAndSettle();

    expect(mockActivity.title, mockPictograms.first.title);
  });
}
