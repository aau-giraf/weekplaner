import 'dart:async';

import 'package:api_client/api/api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/copy_to_citizens_screen.dart';

import 'edit_weekplan_screen_test.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Observable<GirafUserModel> me() {
    return Observable<GirafUserModel>.just(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Observable<List<DisplayNameModel>> getCitizens(String id) {
    final List<DisplayNameModel> output = <DisplayNameModel>[];
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    return Observable<List<DisplayNameModel>>.just(output);
  }
}

class MockWeekApi extends Mock implements WeekApi {
  @override
  Observable<WeekModel> get(String id, int year, int weekNumber) {
    return Observable<WeekModel>.just(WeekModel(
        thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32));
  }

  @override
  Observable<WeekModel> update(
      String id, int year, int weekNumber, WeekModel weekModel) {
    return Observable<WeekModel>.just(weekModel);
  }
}

void main() {
  CopyWeekplanBloc bloc;
  ToolbarBloc toolbarBloc;
  Api api;
  setUp(() {
    di.clearAll();
    api = Api('any');
    api.user = MockUserApi();
    api.week = MockWeekApi();
    bloc = CopyWeekplanBloc(api);
    di.registerDependency<AuthBloc>((_) => AuthBloc(api));
    toolbarBloc = ToolbarBloc();
    di.registerDependency<CopyWeekplanBloc>((_) => bloc);
    di.registerDependency<SettingsBloc>((_) => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>((_) => toolbarBloc);
  });

  testWidgets('Renders CopyToCitizenScreen', (WidgetTester tester) async {
    final WeekModel weekplan1 = WeekModel(
        thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32);
    await tester.pumpWidget(
        MaterialApp(home: CopyToCitizensScreen(weekplan1, mockUser)));
    expect(find.byType(CopyToCitizensScreen), findsOneWidget);
  });

  testWidgets('Has Citizens Avatar', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(
        MaterialApp(home: CopyToCitizensScreen(mockWeek, mockUser)));
    await tester.pumpAndSettle();
    bloc.citizen.listen((List<DisplayNameModel> response) {
      expect(find.byType(CircleAvatar), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Has Accept and Cancel buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(home: CopyToCitizensScreen(mockWeek, mockUser)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('AcceptButton')), findsOneWidget);
    expect(find.byKey(const Key('CancelButton')), findsOneWidget);
  });


}