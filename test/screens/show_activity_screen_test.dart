import 'dart:async';

import 'package:api_client/api/week_api.dart';
import 'package:api_client/models/timer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/async.dart';
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

class MockTimerBloc extends Mock implements TimerBloc {
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

final ActivityModel mockActivity = mockWeek.days[0].activities[0];
final UsernameModel mockUser = UsernameModel(id: '42', name: null, role: null);

class MockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowActivityScreen(mockWeek, mockActivity, mockUser);
  }
}

void main() {
  ActivityBloc bloc;
  Api api;
  MockWeekApi weekApi;
  MockAuth authBloc;
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
    authBloc = MockAuth();
    di.registerDependency<AuthBloc>((_) => authBloc);
    bloc = ActivityBloc(api);
    timerBloc = TimerBloc();


    setupApiCalls();

    di.clearAll();
    di.registerDependency<ActivityBloc>((_) => bloc);
    di.registerDependency<AuthBloc>((_) => AuthBloc(api));
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

    expect(find.byKey(const Key('ButtonBarRender')), findsOneWidget);
  });

  testWidgets('Activity has checkmark when done', (WidgetTester tester) async {
    mockActivity.state = ActivityState.Completed;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('Activity has no checkmark when Normal',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));
    await tester.pump();

    expect(find.byKey(const Key('IconComplete')), findsNothing);
  });

  testWidgets('Activity is set to completed and an acitivty mark is shown',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Normal;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('Activity is set to normal and an acitivty mark is not shown',
      (WidgetTester tester) async {
    mockActivity.state = ActivityState.Completed;
    await tester.pumpWidget(MaterialApp(
        home: ShowActivityScreen(mockWeek, mockActivity, mockUser)));

    await tester.pump();
    await tester.tap(find.byKey(const Key('CompleteStateToggleButton')));

    await tester.pump();
    expect(find.byKey(const Key('IconComplete')), findsNothing);
  });

  testWidgets('Test if timer box is shown.',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MockScreen()));
        await tester.pump();
        expect(find.byKey(const Key('OverallTimerBoxKey')), findsOneWidget);
      });

  testWidgets('Test if timer box is not shown in citizen mode.',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: MockScreen()));
        await tester.pump();
        authBloc.logout();
        await tester.pumpAndSettle();

        timerBloc.timerIsInstantiated.listen((bool b) {
          expect(b, false);
        });
        authBloc.loggedIn.listen((bool b){
          expect(b, false);
        });
        authBloc.mode.listen((WeekplanMode b){
          expect(b, WeekplanMode.citizen);
        });
        expect(find.byKey(const Key('OverallTimerBoxKey')), findsNothing);

      });
}
