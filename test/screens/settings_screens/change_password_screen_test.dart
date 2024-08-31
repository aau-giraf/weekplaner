// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/settings_screens/change_password_screen.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

class MockUserApi extends Mock implements UserApi, NavigatorObserver {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }
}

//Mock of the AccountAPI to test the
//changePasswordWithOld-method bypassing http-complications
class MockAccountApi extends Mock implements AccountApi, NavigatorObserver {
  @override
  Stream<bool> changePasswordWithOld(
      String id, String oldPassword, String newPassword) {
    if (oldPassword == 'apiException') {
      return Stream<bool>.value(false);
    } else {
      return Stream<bool>.value(true);
    }
  }

  Future<Response> apiExceptionResponse(http.Response response) async {
    return Response(response, <String, dynamic>{
      'message': 'something went wrong',
      'details': 'api error',
      'errorKey': 'apiException'
    });
  }
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
    final bool status = username == 'test' && password == 'test';

    final bool statusEx = username == 'test' && password == 'apiException';
    // If there is a successful login, remove the loading spinner,
    // and push the status to the stream
    if (status) {
      loggedInUsername = username;
    } else if (statusEx) {
      loggedInUsername = username;
    }
    _loggedIn.add(status);
  }
}

class MockChangePasswordScreen extends ChangePasswordScreen {
  MockChangePasswordScreen(DisplayNameModel user) : super(user);
  @override
  void changePassword(
      DisplayNameModel user, String oldPassword, String newPassword) {
    final MockAccountApi account = MockAccountApi();
    authBloc.authenticate('test', currentPasswordCtrl.text);
    authBloc.loggedIn.listen((bool snapshot) {
      // var loginStatus = snapshot;
      if (snapshot == false) {
        createDialog('Forkert adgangskode.', 'The old password is wrong',
            const Key('WrongPassword'));
      } else if (snapshot) {
        account
            .changePasswordWithOld(user.id!, oldPassword, newPassword)
            .listen((bool response) {
          if (response) {
            createDialog('Kodeord ændret', 'Dit kodeord er blevet ændret',
                const Key('PasswordChanged'));
          } else {
            createDialog('Forkert adgangskode.', 'The old password is wrong',
                const Key('WrongPassword'));
          }
        });
      }
    });
  }
}

void main() {
  late Api api;

  final DisplayNameModel user = DisplayNameModel(
      displayName: 'John', role: Role.Citizen.toString(), id: '1');

  setUp(() {
    di.clearAll();
    api = Api('any');
    api.user = MockUserApi();
    api.account = MockAccountApi();

    di.registerDependency<AuthBloc>(() => MockAuthBloc());
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<Api>(() => api);
  });

  testWidgets('Checks if textfield is present', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen(user)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('OldPasswordKey')), findsOneWidget);
    expect(find.byKey(const Key('NewPasswordKey')), findsOneWidget);
    expect(find.byKey(const Key('RepeatedPasswordKey')), findsOneWidget);
  });

  testWidgets('Checks if the button is present', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen(user)));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialButton), findsOneWidget);
  });

  testWidgets('EMPTY new password ERROR', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen(user)));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('OldPasswordKey')), 'password');
    await tester.enterText(find.byKey(const Key('NewPasswordKey')), '');
    await tester.enterText(find.byKey(const Key('RepeatedPasswordKey')), '');
    await tester.tap(find.byKey(const Key('ChangePasswordBtnKey')));
    await tester.pump();

    expect(find.byType(GirafNotifyDialog), findsOneWidget);
    expect(find.byKey(const Key('NewPasswordEmpty')), findsOneWidget);
  });

  testWidgets('new password same as old password ERROR',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen(user)));
    await tester.pump();

    await tester.enterText(
        find.byKey(const Key('OldPasswordKey')), 'testPassword');
    await tester.enterText(
        find.byKey(const Key('NewPasswordKey')), 'testPassword');
    await tester.enterText(
        find.byKey(const Key('RepeatedPasswordKey')), 'testPassword');
    await tester.tap(find.byKey(const Key('ChangePasswordBtnKey')));
    await tester.pump();

    expect(find.byType(GirafNotifyDialog), findsOneWidget);
    expect(find.byKey(const Key('NewPasswordSameAsOld')), findsOneWidget);
  });

  testWidgets('repeated password same as new password ERROR',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen(user)));
    await tester.pump();

    await tester.enterText(
        find.byKey(const Key('OldPasswordKey')), 'testPassword');
    await tester.enterText(
        find.byKey(const Key('NewPasswordKey')), 'newTestPassword');
    await tester.enterText(
        find.byKey(const Key('RepeatedPasswordKey')), 'newTestPassword1');
    await tester.tap(find.byKey(const Key('ChangePasswordBtnKey')));
    await tester.pump();

    expect(find.byType(GirafNotifyDialog), findsOneWidget);
    expect(find.byKey(const Key('NewPasswordNotRepeated')), findsOneWidget);
  });

  testWidgets('test ChangePassword-method', (WidgetTester tester) async {
    final MockChangePasswordScreen screen = MockChangePasswordScreen(user);

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('OldPasswordKey')), 'test');
    await tester.enterText(
        find.byKey(const Key('NewPasswordKey')), 'newTestPassword');
    await tester.enterText(
        find.byKey(const Key('RepeatedPasswordKey')), 'newTestPassword');
    await tester.tap(find.byKey(const Key('ChangePasswordBtnKey')));
    await tester.pump();
    expect(find.byType(GirafNotifyDialog), findsOneWidget);

    expect(find.byKey(const Key('PasswordChanged')), findsOneWidget);
  });

  testWidgets('test ChangePassword-method | throws ApiException',
      (WidgetTester tester) async {
    final MockChangePasswordScreen screen = MockChangePasswordScreen(user);

    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('OldPasswordKey')), 'apiException');
    await tester.enterText(
        find.byKey(const Key('NewPasswordKey')), 'newTestPassword');
    await tester.enterText(
        find.byKey(const Key('RepeatedPasswordKey')), 'newTestPassword');
    await tester.tap(find.byKey(const Key('ChangePasswordBtnKey')));
    await tester.pump();
    expect(find.byType(GirafNotifyDialog), findsOneWidget);
    expect(find.byKey(const Key('WrongPassword')), findsOneWidget);
  });
}
