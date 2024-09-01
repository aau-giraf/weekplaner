import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';

late SettingsModel mockSettings;

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<SettingsModel> getSettings(String id) {
    return Stream<SettingsModel>.value(mockSettings);
  }
}

void main() {
  late Api api;
  late SettingsBloc settingsBloc;
  late ActivityBloc activityBloc;
  late AuthBloc authBloc;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'Anders And', id: '101', role: Role.Guardian.toString());

  final PictogramModel pictogramModel = PictogramModel(
      id: 1,
      lastEdit: DateTime(2020),
      title: 'SomeTitle',
      accessLevel: AccessLevel.PUBLIC,
      imageUrl: 'http://any.tld',
      imageHash: '');

  final ActivityModel activityModel = ActivityModel(
      id: 1,
      pictograms: <PictogramModel>[pictogramModel],
      order: 0,
      state: ActivityState.Normal,
      isChoiceBoard: false,
      title: pictogramModel.title);

  setUp(() {
    di.clearAll();
    api = Api('any');

    mockSettings = SettingsModel(
      orientation: null,
      completeMark: CompleteMark.Checkmark,
      cancelMark: null,
      defaultTimer: null,
      theme: null,
      weekDayColors: null,
      lockTimerControl: false,
      pictogramText: false,
    );

    api.user = MockUserApi();
    settingsBloc = SettingsBloc(api);
    activityBloc = ActivityBloc(api);
    di.registerDependency<SettingsBloc>(() => settingsBloc);
    di.registerDependency<ActivityBloc>(() => activityBloc);

    authBloc = AuthBloc(api);
    di.registerDependency<AuthBloc>(() => authBloc);
  });

  testWidgets('Pictogram text is not displayed when false and in Citizen mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = false;
    authBloc.setMode(WeekplanMode.citizen);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsOneWidget);
    final String title = pictogramModel.title;
    expect(find.text(title.toUpperCase()), findsNothing);
  });

  testWidgets('Pictogram text is displayed when true and in Citizen mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = true;
    authBloc.setMode(WeekplanMode.citizen);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(AutoSizeText), findsOneWidget);
    expect(find.text('Sometitle'), findsOneWidget);
  });

  testWidgets('Pictogram text is displayed when true and in guardian mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = true;
    authBloc.setMode(WeekplanMode.guardian);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(AutoSizeText), findsOneWidget);
    expect(find.text('Sometitle'), findsOneWidget);
  });

  testWidgets('Pictogram text is displayed when false and in guardian mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = true;
    authBloc.setMode(WeekplanMode.guardian);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(AutoSizeText), findsOneWidget);
    expect(find.text('Sometitle'), findsOneWidget);
  });
}
