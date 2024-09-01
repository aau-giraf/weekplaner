// ignore_for_file: lines_longer_than_80_chars

import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';

///A mock of the account api to use in the tests
class MockAccountApi extends Mock implements AccountApi {
  @override
  Stream<bool> login(String username, String password) {
    ///Returns true to mark the the user exists
    return Stream<bool>.value(true);
  }
}

///A mock of the user api to use in the tests
class MockUserApi extends Mock implements UserApi {
  @override
  Stream<int> role(String username) {
    ///Returns a role to check that authenticate works
    if (username.compareTo('Graatand') == 0) {
      return Stream<int>.value(Role.Guardian.index);
    } else if (username.compareTo('Chris') == 0) {
      return Stream<int>.value(Role.Trustee.index);
    } else if (username.compareTo('Janne') == 0) {
      return Stream<int>.value(Role.Citizen.index);
    }

    throw Exception;
  }
}

void main() {
  late Api _api;
  late AuthBloc authBloc;

  setUp(() {
    _api = Api('any');
    authBloc = AuthBloc(_api);
    _api.account = MockAccountApi();
    _api.user = MockUserApi();
  });

  test('Check if the mode defaults to guardian', async((DoneFn done) {
    authBloc.mode.listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.guardian);
      done();
    });
  }));

  test('Test if mode is changed to citizen when setMode is called with citizen',
      async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.citizen);
      done();
    });
    authBloc.setMode(WeekplanMode.citizen);
  }));

  test(
      'Test if mode is changed to guardian when setMode is called with guardian',
      async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.guardian);
      done();
    });
    authBloc.setMode(WeekplanMode.guardian);
  }));

  test(
      'Test if the mode is changed to trustee '
      'when setMode is called with trustee', async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.trustee);
      done();
    });
    authBloc.setMode(WeekplanMode.trustee);
  }));

  const String username = 'Graatand';
  const String password = 'password';
  test('Should check that authenticate works', async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.guardian);
      done();
    });
    authBloc.authenticate(username, password);
  }));

  const String username2 = 'Chris';
  test('Should check that authenticate works', async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.trustee);
      done();
    });
    authBloc.authenticate(username2, password);
  }));

  const String username3 = 'Janne';
  test('Should check that authenticate works', async((DoneFn done) {
    authBloc.mode.skip(1).listen((WeekplanMode mode) {
      expect(mode, WeekplanMode.citizen);
      done();
    });
    authBloc.authenticate(username3, password);
  }));
}
