import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/providers/api/api.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/username_model.dart';
import 'package:weekplanner/providers/api/user_api.dart';
import 'package:weekplanner/screens/choose_citizen_screen.dart';
import 'package:weekplanner/screens/weekplan_screen.dart';
import 'package:weekplanner/widgets/citizen_avatar_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_simple_widget.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Observable<GirafUserModel> me() {
    return Observable.just(GirafUserModel(id: "1", username: "test"));
  }

  @override
  Observable<List<UsernameModel>> getCitizens(String id) {
    List<UsernameModel> Output = List<UsernameModel>();
    Output.add(UsernameModel(name: "test1", role: "test1", id: id));
    Output.add(UsernameModel(name: "test1", role: "test1", id: id));
    Output.add(UsernameModel(name: "test1", role: "test1", id: id));
    Output.add(UsernameModel(name: "test1", role: "test1", id: id));

    return Observable.just(Output);
  }
}

void main() {
  ChooseCitizenBloc bloc;
  Api api;
  setUp(() {
    di.clearAll();
    api = Api("any");
    api.user = MockUserApi();
    bloc = ChooseCitizenBloc(api);
    di.registerDependency<ChooseCitizenBloc>((_) => bloc);
    di.registerDependency<SettingsBloc>((_) => SettingsBloc());
    di.registerDependency<AuthBloc>((_) => AuthBloc(api));
  });

  testWidgets('Renders ChooseCitizenScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
  });

  testWidgets("Has GirafAppBarSimple", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    expect(find.byType(GirafAppBarSimple), findsOneWidget);
  });

  testWidgets("Has Citizens Avatar", (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();

    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pump(Duration(seconds: 3));
    bloc.citizen.listen((List<UsernameModel> response) {
      expect(find.byType(CircleAvatar), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets("Has Citizens Text [Name] (4)", (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pump(Duration(seconds: 3));
    bloc.citizen.listen((List<UsernameModel> response) {
      expect(find.byType(AutoSizeText), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  //TODO: Test if the correct weekplanner screen is shown
  /*
  testWidgets("Click Citizen (Avatar)", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChooseCitizenScreen()));
    await tester.pump(Duration(seconds: 3));
    await tester.ensureVisible(find.byType(CitizenAvatar).first);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump(Duration(seconds: 3));
    expect(find.byType(WeekplanScreen), findsOneWidget);
  });
  */
}
