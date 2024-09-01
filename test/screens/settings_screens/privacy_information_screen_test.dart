import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/screens/settings_screens/privacy_information_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';

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

  setUpAll(() {
    registerFallbackValue(SettingsModel());
  });

  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    settingsBloc = SettingsBloc(api);

    mockSettings = SettingsModel(
        orientation: null,
        completeMark: null,
        cancelMark: null,
        defaultTimer: null,
        theme: null,
        pictogramText: false,
        lockTimerControl: false);

    when(() => api.user.updateSettings(any(), any())).thenAnswer((_) {
      return Stream<bool>.value(true);
    });

    di.clearAll();
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<SettingsBloc>(() => settingsBloc);
  });

  testWidgets('Renders  PrivacyInformationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PrivacyInformationScreen()));
    expect(find.byType(PrivacyInformationScreen), findsOneWidget);
  });

  testWidgets('Has GirafAppBar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PrivacyInformationScreen()));
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafAppBar && widget.title == 'Privatlivsinformation'),
        findsOneWidget);
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Has ScrollView', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PrivacyInformationScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
