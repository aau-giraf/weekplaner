import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/new_citizen_bloc.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
        id: '1',
        department: 1,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Kirsten Birgit',
        username: 'kb7913'));
  }
}

class MockAccountApi extends Mock implements AccountApi {}

void main() {
  setUpAll(() {
    registerFallbackValue(Role.Unknown);
  });

  Api api = Api('any');
  NewCitizenBloc bloc = NewCitizenBloc(api);

  final GirafUserModel user = GirafUserModel(
      id: '1',
      department: 1,
      role: Role.Citizen,
      roleName: 'Citizen',
      displayName: 'Birgit',
      username: 'b1337');

  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    api.account = MockAccountApi();
    bloc = NewCitizenBloc(api);
    bloc.initialize();

    when(() => api.account.register(any(), any(), any(), any(),
        departmentId: any(named: 'departmentId'),
        role: any(named: 'role'))).thenAnswer((_) {
      return Stream<GirafUserModel>.value(user);
    });
  });

  test('Should save a new citizen', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.createCitizen();

    verify(() => bloc.createCitizen());
    done();
  }));

  test('Should save a new guardian', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.createGuardian();

    verify(() => bloc.createGuardian());
    done();
  }));

  test('Should save a new trustee', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.createTrustee();

    verify(() => bloc.createTrustee());
    done();
  }));

  test('All inputs are valid', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
    });
    done();
  }));

  test('No inputs are valid', async((DoneFn done) {
    bloc.onUsernameChange.add(null);
    bloc.onPasswordChange.add(null);
    bloc.onPasswordVerifyChange.add(null);
    bloc.onDisplayNameChange.add(null);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('resetBloc test', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.resetBloc();
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - password', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1224');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - password 2', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1224');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - username', async((DoneFn done) {
    bloc.onUsernameChange.add('my username');
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - Display name', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(null);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - username', async((DoneFn done) {
    bloc.onUsernameChange.add('');
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('All inputs are not valid - username', async((DoneFn done) {
    bloc.onUsernameChange.add('!!PeterMadsen??');
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
    });
    done();
  }));

  test('Username validation', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username);
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Username with space in front', async((DoneFn done) {
    bloc.onUsernameChange.add(' ' + user.username!);
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Username with space after', async((DoneFn done) {
    bloc.onUsernameChange.add(user.username! + ' ');
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Username with space', async((DoneFn done) {
    bloc.onUsernameChange.add('user name');
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('No username', async((DoneFn done) {
    bloc.onUsernameChange.add('');
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Username is null', async((DoneFn done) {
    bloc.onUsernameChange.add(null);
    bloc.validUsernameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Display name validation', async((DoneFn done) {
    bloc.onDisplayNameChange.add(user.displayName);
    bloc.validDisplayNameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Display name with space', async((DoneFn done) {
    bloc.onDisplayNameChange.add('Display Name');
    bloc.validDisplayNameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('No display name', async((DoneFn done) {
    bloc.onDisplayNameChange.add('');
    bloc.validDisplayNameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Display name is null', async((DoneFn done) {
    bloc.onDisplayNameChange.add(null);
    bloc.validDisplayNameStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Password validation', async((DoneFn done) {
    bloc.onPasswordChange.add('1234');
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Password with space in front', async((DoneFn done) {
    bloc.onPasswordChange.add(' 1234');
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Password with space in middel', async((DoneFn done) {
    bloc.onPasswordChange.add('12 34');
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Password with space last', async((DoneFn done) {
    bloc.onPasswordChange.add('1234 ');
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('No password', async((DoneFn done) {
    bloc.onPasswordChange.add('');
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Password is null', async((DoneFn done) {
    bloc.onPasswordChange.add(null);
    bloc.validPasswordStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification is null, but password is missing',
      async((DoneFn done) {
    bloc.onPasswordChange.add('');
    bloc.onPasswordVerifyChange.add(null);
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification is filled, but password is missing',
      async((DoneFn done) {
    bloc.onPasswordVerifyChange.add('abcd');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification is filled, but does not match password',
      async((DoneFn done) {
    bloc.onPasswordChange.add('4321');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification is filled, but password is empty',
      async((DoneFn done) {
    bloc.onPasswordChange.add('');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification is filled, but password is null',
      async((DoneFn done) {
    bloc.onPasswordChange.add(null);
    bloc.onPasswordVerifyChange.add('1234');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('PasswordVerification and password match 1', async((DoneFn done) {
    bloc.onPasswordChange.add('1234');
    bloc.onPasswordVerifyChange.add('1234');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('PasswordVerification and password match 2', async((DoneFn done) {
    bloc.onPasswordChange.add('abc123');
    bloc.onPasswordVerifyChange.add('abc123');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('PasswordVerification and password match 3', async((DoneFn done) {
    bloc.onPasswordChange.add(null);
    bloc.onPasswordVerifyChange.add(null);
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('PasswordVerification and password match 4', async((DoneFn done) {
    bloc.onPasswordChange.add('');
    bloc.onPasswordVerifyChange.add('');
    bloc.validPasswordVerificationStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));
}
