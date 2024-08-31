import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/blocs/new_pictogram_password_bloc.dart';

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
  Api api = Api('baseUrl');
  NewPictogramPasswordBloc bloc = NewPictogramPasswordBloc(api);

  final GirafUserModel user = GirafUserModel(
      id: '1',
      department: 1,
      role: Role.Citizen,
      roleName: 'Citizen',
      displayName: 'Birgit',
      username: 'b1337');

  setUpAll(() {
    registerFallbackValue(Role.Unknown);
  });

  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    api.account = MockAccountApi();
    bloc = NewPictogramPasswordBloc(api);
    bloc.initialize('testUser', 'testName', Uint8List(1));

    when(() => api.account.register(any(), any(), any(), any(),
        departmentId: any(named: 'departmentId'),
        role: any(named: 'role'))).thenAnswer((_) {
      return Stream<GirafUserModel>.value(user);
    });
  });

  test('Should save a new citien', async((DoneFn done) {
    bloc.onPictogramPasswordChanged.add('1111');
    bloc.createCitizen();

    verify(() => bloc.createCitizen());
    done();
  }));

  test('Valid pictogram password', async((DoneFn done) {
    bloc.onPictogramPasswordChanged.add('1111');
    bloc.validPictogramPasswordStream.listen((bool valid) {
      expect(valid, isNotNull);
      expect(valid, true);
    });
    done();
  }));

  test('Invalid pictogram password', async((DoneFn done) {
    bloc.onPictogramPasswordChanged.add(null);
    bloc.validPictogramPasswordStream.listen((bool valid) {
      expect(valid, isNotNull);
      expect(valid, false);
    });
    done();
  }));
}
