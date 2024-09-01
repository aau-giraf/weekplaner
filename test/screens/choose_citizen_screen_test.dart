import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/screens/choose_citizen_screen.dart';
import 'package:weekplanner/widgets/citizen_avatar_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    final List<DisplayNameModel> output = <DisplayNameModel>[];
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    return Stream<List<DisplayNameModel>>.value(output);
  }
}

class MockCitizens extends Mock implements UserApi {}

void main() {
  late ChooseCitizenBloc bloc;
  late ToolbarBloc toolbarBloc;
  late Api api;
  late AuthBloc authBloc;
  setUp(() {
    di.clearAll();
    api = Api('any');
    authBloc = AuthBloc(api);
    authBloc.loggedInUser = GirafUserModel(
        id: '1',
        role: Role.Guardian,
        roleName: 'guardian',
        username: 'testUsername',
        displayName: 'testDisplayname',
        department: 1);
    api.user = MockUserApi();
    bloc = ChooseCitizenBloc(api);
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => authBloc);
    toolbarBloc = ToolbarBloc();
    di.registerDependency<ChooseCitizenBloc>(() => bloc);
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>(() => toolbarBloc);
  });

  testWidgets('Renders ChooseCitizenScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    expect(find.byType(ChooseCitizenScreen), findsOneWidget);
  });

  testWidgets('Has GirafAppBar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Has Citizens Avatar', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pumpAndSettle();
    bloc.citizen.listen((List<DisplayNameModel> response) {
      expect(find.byType(CircleAvatar), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Has Citizens Text [Name] (4)', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pumpAndSettle();
    bloc.citizen.listen((List<DisplayNameModel> response) {
      expect(find.byType(CitizenAvatar), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Has add citizen button', (WidgetTester tester) async {
    final Role role = authBloc.loggedInUser.role!;
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pumpAndSettle();
    if (role == Role.Guardian) {
      expect(find.byType(TextButton), findsNWidgets(1));
    } else {
      expect(find.byType(TextButton), findsNWidgets(0));
    }
  });
}
