import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/screens/settings_screens/number_of_days_selection_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_checkboxButton.dart';

class MockUserApi extends Mock implements UserApi, NavigatorObserver {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<SettingsModel?> getSettings(String id) {
    final SettingsModel settingsModel = SettingsModel(
        orientation: null,
        completeMark: null,
        cancelMark: null,
        defaultTimer: null,
        theme: null,
        nrOfDaysToDisplayPortrait: 1,
        displayDaysRelativePortrait: true,
        nrOfDaysToDisplayLandscape: 7,
        displayDaysRelativeLandscape: false,
        weekDayColors: null);

    return Stream<SettingsModel>.value(settingsModel);
  }
}

void main() {
  late Api api;
  late NavigatorObserver mockObserver;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'Anders And', id: '101', role: Role.Citizen.toString());

  setUp(() {
    di.clearAll();
    api = Api('any');
    api.user = MockUserApi();
    mockObserver = MockUserApi();

    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
  });

  testWidgets('Portrait settings screen has GirafAppBar',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafAppBar &&
            widget.title == user.displayName! + ': indstillinger'),
        findsOneWidget);
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Landscape settings screen has GirafAppBar',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafAppBar &&
            widget.title == user.displayName! + ': indstillinger'),
        findsOneWidget);
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Portrait settings screen has 4 options, SettingsCheckMarkButton',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsCheckMarkButton), findsNWidgets(4));
  });

  testWidgets(
      'Landscape settings screen has 4 options, '
      'SettingsCheckMarkButton', (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsCheckMarkButton), findsNWidgets(4));
  });

  testWidgets('Portrait settings screen has option: "Vis i dag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis i dag'), findsOneWidget);
  });

  testWidgets('Landscape settings screen has option: "Vis i dag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis i dag'), findsOneWidget);
  });

  testWidgets('Portrait settings screen has option: "Vis to dage"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis to dage'), findsOneWidget);
  });

  testWidgets('Landscape settings screen has option: "Vis to dage"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis to dage'), findsOneWidget);
  });

  testWidgets('Portrait settings screen has option: "Vis mandag til fredag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis mandag til fredag'), findsOneWidget);
  });

  testWidgets('Landscape settings screen has option: "Vis mandag til fredag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis mandag til fredag'), findsOneWidget);
  });

  testWidgets('Portrait settings screen has option: "Vis mandag til søndag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis mandag til søndag'), findsOneWidget);
  });

  testWidgets('Landscape settings screen has option: "Vis mandag til søndag"',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, false, null)));
    await tester.pumpAndSettle();
    expect(find.text('Vis mandag til søndag'), findsOneWidget);
  });

  testWidgets('Portrait settings screen has only one selected option',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: NumberOfDaysScreen(user, true, null)));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Portrait settings screen has been popped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NumberOfDaysScreen(user, true, null),
        navigatorObservers: [mockObserver] //ignore: always_specify_types
        ));
    verify(() => mockObserver.didPush(any(), any()));

    await tester.pumpAndSettle();
    expect(find.byType(SettingsCheckMarkButton), findsNWidgets(4));

    await tester.pump();
    await tester.tap(find.byType(SettingsCheckMarkButton).last);
    await tester.pump();
    verify(() => mockObserver.didPop(any(), any()));
  });

  testWidgets('Landscape settings screen has been popped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NumberOfDaysScreen(user, false, null),
        navigatorObservers: [mockObserver] //ignore: always_specify_types
        ));
    verify(() => mockObserver.didPush(any(), any()));

    await tester.pumpAndSettle();
    expect(find.byType(SettingsCheckMarkButton), findsNWidgets(4));

    await tester.pump();
    await tester.tap(find.byType(SettingsCheckMarkButton).last);
    await tester.pump();
    verify(() => mockObserver.didPop(any(), any()));
  });
}
