import 'package:api_client/api/user_api.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/api/api.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';

SettingsModel mockSettings;

class MockUserApi extends Mock implements UserApi {
  @override
  Observable<GirafUserModel> me() {
    return Observable<GirafUserModel>.just(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Observable<SettingsModel> getSettings(String id) {
    return Observable<SettingsModel>.just(mockSettings);
  }
}

void main() {
  Api api;
  SettingsBloc settingsBloc;
  ActivityBloc activityBloc;
  AuthBloc authBloc;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'Anders And', id: '101', role: Role.Guardian.toString());

  final PictogramModel pictogramModel = PictogramModel(
      id: 1,
      lastEdit: null,
      title: 'SomeTitle',
      accessLevel: null,
      imageUrl: 'http://any.tld',
      imageHash: null);

  final ActivityModel activityModel = ActivityModel(
      id: 1,
      pictogram: pictogramModel,
      order: null,
      state: ActivityState.Normal,
      isChoiceBoard: null);

  setUp(() {
    di.clearAll();
    api = Api('any');

    mockSettings = SettingsModel(
      orientation: null,
      completeMark: null,
      cancelMark: null,
      defaultTimer: null,
      theme: null,
      nrOfDaysToDisplay: 1,
      weekDayColors: null,
      lockTimerControl: false,
      pictogramText: false,
    );

    api.user = MockUserApi();
    settingsBloc = SettingsBloc(api);
    activityBloc = ActivityBloc(api);
    di.registerDependency<SettingsBloc>((_) => settingsBloc);
    di.registerDependency<ActivityBloc>((_) => activityBloc);

    authBloc = AuthBloc(api);
    di.registerDependency<AuthBloc>((_) => authBloc);
  });

  testWidgets(
      'Pictogram text is not displayed when false and not in guardian mode',
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

  testWidgets('Pictogram text is displayed when true and not in guardian mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = true;
    authBloc.setMode(WeekplanMode.citizen);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();
    //authBloc.setMode(WeekplanMode.citizen);

    expect(find.byType(AutoSizeText), findsOneWidget);
    final String title = pictogramModel.title;
    expect(find.text(title.toUpperCase()), findsOneWidget);
  });

  testWidgets('Pictogram text is displayed when true and in guardian mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = true;
    authBloc.setMode(WeekplanMode.guardian);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(AutoSizeText), findsOneWidget);
    final String title = pictogramModel.title;
    expect(find.text(title.toUpperCase()), findsOneWidget);
  });

  testWidgets('Pictogram text is displayed when false and in guardian mode',
      (WidgetTester tester) async {
    mockSettings.pictogramText = false;
    authBloc.setMode(WeekplanMode.guardian);

    await tester
        .pumpWidget(MaterialApp(home: PictogramText(activityModel, user)));
    await tester.pumpAndSettle();

    expect(find.byType(AutoSizeText), findsOneWidget);
    final String title = pictogramModel.title;
    expect(find.text(title.toUpperCase()), findsOneWidget);
  });
}
