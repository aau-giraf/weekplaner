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
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:weekplanner/screens/settings_screens/color_theme_selection_screen.dart';
import 'package:weekplanner/screens/settings_screens/settings_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_arrow_button.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_colorThemeButton.dart';

class MockRoute extends Mock implements Route<dynamic> {}

class MockUserApi extends Mock implements UserApi, NavigatorObserver {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<SettingsModel> getSettings(String id) {
    return Stream<SettingsModel>.value(mockSettings);
  }

  static List<WeekdayColorModel> createWeekDayColors() {
    final List<WeekdayColorModel> weekDayColors = <WeekdayColorModel>[];
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Monday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Tuesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Wednesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Thursday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Friday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Saturday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FF0000', day: Weekday.Sunday));

    return weekDayColors;
  }
}

late SettingsModel mockSettings;

void main() {
  late Api api;
  late SettingsBloc settingsBloc;
  late NavigatorObserver mockObserver;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'Anders And', id: '101', role: Role.Guardian.toString());
  setUpAll(() {
    registerFallbackValue(SettingsModel());
    registerFallbackValue(MockRoute());
  });
  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    settingsBloc = SettingsBloc(api);
    mockObserver = MockUserApi();

    mockSettings = SettingsModel(
      orientation: null,
      completeMark: null,
      cancelMark: null,
      theme: GirafTheme.AndroidBlue,
      defaultTimer: DefaultTimer.Hourglass,
      lockTimerControl: false,
      pictogramText: false,
      showPopup: false,
      showOnlyActivities: false,
      showSettingsForCitizen: false,
      weekDayColors: MockUserApi.createWeekDayColors(),
    );

    when(() => api.user.updateSettings(any(), any())).thenAnswer((_) {
      return Stream<bool>.value(true);
    });

    di.clearAll();
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<SettingsBloc>(() => settingsBloc);
  });

  testWidgets('Renders  ColorThemeSelectorScreen', (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ColorThemeSelectorScreen(user: user)));
    expect(find.byType(ColorThemeSelectorScreen), findsOneWidget);
  });

  testWidgets('Has GirafAppBar', (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ColorThemeSelectorScreen(user: user)));
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Has three SettingsColorThemeCheckMarkButton',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ColorThemeSelectorScreen(user: user)));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsColorThemeCheckMarkButton), findsNWidgets(3));
  });

  testWidgets('The correct initial settings are loaded',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ColorThemeSelectorScreen(user: user)));

    settingsBloc.settings.listen((SettingsModel? response) {
      expect(response, isNotNull);

      final List<WeekdayColorModel> expectedList =
          MockUserApi.createWeekDayColors();

      for (int i = 0; i < response!.weekDayColors!.length; i++) {
        expect(response.weekDayColors?[i].hexColor == expectedList[i].hexColor,
            isTrue);
        expect(response.weekDayColors?[i].day == expectedList[i].day, isTrue);
      }
    });
  });

  testWidgets('The standard color theme button works',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(user)));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsArrowButton && widget.text == 'Farver på ugeplan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsColorThemeCheckMarkButton &&
        !widget.hasCheckMark() &&
        widget.text == 'Standard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farver på ugeplan'));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is SettingsColorThemeCheckMarkButton &&
            widget.hasCheckMark() &&
            widget.text == 'Standard'),
        findsOneWidget);
  });

  testWidgets('The blue white color theme button works',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(user)));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsArrowButton && widget.text == 'Farver på ugeplan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsColorThemeCheckMarkButton &&
        !widget.hasCheckMark() &&
        widget.text == 'Blå/Hvid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farver på ugeplan'));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is SettingsColorThemeCheckMarkButton &&
            widget.hasCheckMark() &&
            widget.text == 'Blå/Hvid'),
        findsOneWidget);
  });

  testWidgets('The grey white color theme button works',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(user)));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsArrowButton && widget.text == 'Farver på ugeplan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is SettingsColorThemeCheckMarkButton &&
        !widget.hasCheckMark() &&
        widget.text == 'Grå/Hvid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farver på ugeplan'));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is SettingsColorThemeCheckMarkButton &&
            widget.hasCheckMark() &&
            widget.text == 'Grå/Hvid'),
        findsOneWidget);
  });

  testWidgets('Has color theme selection screen been popped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: ColorThemeSelectorScreen(user: user),
        // ignore: always_specify_types
        navigatorObservers: [mockObserver]));
    verify(() => mockObserver.didPush(any(), any()));

    await tester.pumpAndSettle();
    expect(find.byType(SettingsColorThemeCheckMarkButton), findsNWidgets(3));

    await tester.pump();
    await tester.tap(find.byType(SettingsColorThemeCheckMarkButton).first);
    await tester.pump();
    verify(() => mockObserver.didPop(any(), any()));
  });
}
