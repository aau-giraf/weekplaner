import 'dart:async';

import 'package:weekplanner/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/login_screen.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

class MockLoginScreenStateAutoLogin extends LoginScreenState {
  @override
  void loginAction(BuildContext context) {}
}

class MockLoginScreenState extends LoginScreenState {
  @override
  void loginAction(BuildContext context) {
    currentContext = context;
    authBloc.authenticate(usernameCtrl.value.text, passwordCtrl.value.text);

    authBloc.loggedIn.listen((bool snapshot) {
      loginStatus = snapshot;
      if (snapshot == false) {
        if (!loginStatus) {
          creatingNotifyDialog('Forkert brugernavn og/eller adgangskode',
              'WrongUsernameOrPassword');
        }
      }
    });
  }

  /// Function that creates the notify dialog,
  /// depeninding which login error occured
  @override
  void creatingNotifyDialog(String description, String key) {
    /// Remove the loading spinner
    Routes().pop(currentContext);

    /// Show the new NotifyDialog
    showDialog<Center>(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: 'Fejl', description: description, key: Key(key));
        });
  }
}

class MockLoginScreen extends LoginScreen {
  @override
  LoginScreenState createState() => MockLoginScreenState();
}

class MockLoginScreenAutoLogin extends LoginScreen {
  @override
  LoginScreenState createState() => MockLoginScreenStateAutoLogin();
}

class MockAuthBloc extends Mock implements AuthBloc {
  @override
  Stream<bool> get loggedIn => _loggedIn.stream;
  final rx_dart.BehaviorSubject<bool> _loggedIn =
      rx_dart.BehaviorSubject<bool>.seeded(false);

  late String loggedInUsername;

  @override
  Future<void> authenticate(String username, String password) async {
    // Mock the API and allow these 2 users to ?login?
    final bool status = (username == 'test' && password == 'test') ||
        (username == 'Graatand' && password == 'password');
    // If there is a successful login, remove the loading spinner,
    // and push the status to the stream
    if (status) {
      loggedInUsername = username;
    }
    _loggedIn.add(status);
  }
}

void main() {
  late MockAuthBloc bloc;
  setUp(() {
    bloc = MockAuthBloc();
    di.clearAll();
    di.registerDependency<AuthBloc>(() => bloc);
    di.registerDependency<ChooseCitizenBloc>(
        () => ChooseCitizenBloc(Api('Any')));
  });

  testWidgets('Has Auto-Login button in DEBUG mode',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byKey(const Key('AutoLoginKey')), findsOneWidget);
  });

  testWidgets('Has NO Auto-Login button in PRODUCTION mode',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'false';
    final LoginScreen loginScreen = LoginScreen();
    await tester.pumpWidget(MaterialApp(home: loginScreen));
    expect(find.byKey(const Key('AutoLoginKey')), findsNothing);
  });

  testWidgets('Renders LoginScreen (DEBUG)', (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Renders LoginScreen (PROD)', (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'false';
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Auto-Login fills username if pressed',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: MockLoginScreenAutoLogin()));
    await tester.tap(find.byKey(const Key('AutoLoginKey')));
    expect(find.text('Graatand'), findsOneWidget);
  });

  testWidgets('Auto-Login fills password if pressed',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: MockLoginScreenAutoLogin()));
    await tester.tap(find.byKey(const Key('AutoLoginKey')));
    expect(find.text('password'), findsOneWidget);
  });

  testWidgets('Auto-Login fills username and password if pressed',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: MockLoginScreenAutoLogin()));
    await tester.tap(find.byKey(const Key('AutoLoginKey')));
    expect(find.text('Graatand'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);
  });

  testWidgets('Auto-Login does not fill username if not pressed',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.text('Graatand'), findsNothing);
  });

  testWidgets('Auto-Login does not fill password if not pressed',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    expect(find.text('password'), findsNothing);
  });

  testWidgets('Logging in works (PROD)', (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'false';
    final Completer<bool> done = Completer<bool>();

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byKey(const Key('UsernameKey')), 'test');
    await tester.enterText(find.byKey(const Key('PasswordKey')), 'test');
    await tester.tap(find.byKey(const Key('LoginBtnKey')));
    await tester.pump(const Duration(seconds: 5));

    bloc.loggedIn.listen((bool success) async {
      await tester.pump();
      expect(success, equals(true));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Logging in works (DEBUG)', (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'true';
    final Completer<bool> done = Completer<bool>();

    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byKey(const Key('UsernameKey')), 'test');
    await tester.enterText(find.byKey(const Key('PasswordKey')), 'test');
    await tester.tap(find.byKey(const Key('LoginBtnKey')));
    await tester.pump(const Duration(seconds: 5));

    bloc.loggedIn.listen((bool success) async {
      await tester.pump();
      expect(success, true);
      done.complete(true);
    });
    await done.future;
  });

  testWidgets(
      'Logging in with wrong information should show a GirafNotifyDialog',
      (WidgetTester tester) async {
    dotenv.env['ENV_VARIABLE'] = 'false';

    await tester.pumpWidget(MaterialApp(home: MockLoginScreen()));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('UsernameKey')), 'SomeWrongUsername');
    await tester.enterText(
        find.byKey(const Key('PasswordKey')), 'SomeWrongPassword');
    await tester.pump();
    await tester.tap(find.byKey(const Key('LoginBtnKey')));
    await tester.pump();
    expect(find.byType(GirafNotifyDialog), findsOneWidget);
    expect(find.byKey(const Key('WrongUsernameOrPassword')), findsOneWidget);
  });
}
