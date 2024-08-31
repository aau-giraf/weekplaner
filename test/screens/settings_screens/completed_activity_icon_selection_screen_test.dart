import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/settings_screens/completed_activity_icon_selection_screen.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_checkboxButton.dart';

class MockRoute extends Mock implements Route<dynamic> {}

class MockUserApi extends Mock implements NavigatorObserver, UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<SettingsModel> getSettings(String id) {
    final SettingsModel settingsModel = SettingsModel(
        orientation: null,
        completeMark: CompleteMark.Checkmark,
        cancelMark: null,
        defaultTimer: null,
        theme: null,
        weekDayColors: null);

    return Stream<SettingsModel>.value(settingsModel);
  }
}

void main() {
  late Api api;
  late SettingsBloc settingsBloc;
  late NavigatorObserver mockObserver;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'Mickey Mouse', id: '2', role: Role.Citizen.toString());
  setUpAll(() {
    registerFallbackValue(MockRoute());
  });
  setUp(() {
    di.clearAll();
    api = Api('any');
    api.user = MockUserApi();

    settingsBloc = SettingsBloc(api);
    settingsBloc.loadSettings(user);

    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<SettingsBloc>(() => settingsBloc);

    mockObserver = MockUserApi();
  });

  testWidgets('Has completed activity screen been popped',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CompletedActivityIconScreen(user),
        // ignore: always_specify_types
        navigatorObservers: [mockObserver]));
    verify(() => mockObserver.didPush(any(), any()));

    await tester.pumpAndSettle();
    expect(find.byType(SettingsCheckMarkButton), findsNWidgets(3));

    await tester.pump();
    await tester.tap(find.byType(SettingsCheckMarkButton).first);
    await tester.pump();
    verify(() => mockObserver.didPop(any(), any()));
  });
}
