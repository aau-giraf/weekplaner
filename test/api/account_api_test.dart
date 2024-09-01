@Timeout(Duration(seconds: 5))

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/src/response.dart';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/http/http.dart' as http_r;
import 'package:weekplanner/http/http_mock.dart';
import 'package:weekplanner/models/enums/error_key.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/persistence/persistence_mock.dart';

void main() {
  HttpMock httpMock = HttpMock();
  PersistenceMock persistenceMock = PersistenceMock();
  AccountApi accountApi = AccountApi(httpMock, persistenceMock);

  setUp(() {
    httpMock = HttpMock();
    persistenceMock = PersistenceMock();
    accountApi = AccountApi(httpMock, persistenceMock);
  });

  test('Should call login endpoint', () {
    accountApi
        .login('username', 'password')
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/login', method: Method.post)
        .flush(<String, dynamic>{
      'data': 'TestToken',
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should throw on error', () {
    accountApi.login('username', 'password').listen((_) {},
        onError: expectAsync1((ApiException error) {
      expect(error.errorKey, ErrorKey.InvalidCredentials);
    }));

    httpMock.expectOne(url: '/login', method: Method.post).throwError(
            ApiException(
                http_r.Response(Response.bytes(<int>[], 200), <String, dynamic>{
          'success': false,
          'message': '',
          'errorKey': 'InvalidCredentials',
        })));
  });

  test('Should request reset password token', () {
    const String id = '1234';
    const String token = 'TestToken';

    accountApi.resetPasswordToken(id).listen(expectAsync1((String test) {
      expect(test, token);
    }));

    httpMock
        .expectOne(url: '/password-reset-token/$id', method: Method.get)
        .flush(<String, dynamic>{
      'data': token,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should register user', () {
    const String id = '1234';
    const String username = 'username';
    const String displayName = 'displayname';
    const String password = 'password';
    const Uint8List? profilePicture = null;
    const int departmentId = 123;
    const Role role = Role.Citizen;

    accountApi
        .register(username, displayName, password, profilePicture,
            departmentId: departmentId, role: role)
        .listen(expectAsync1((GirafUserModel res) {
      expect(res.username, username);
      expect(res.displayName, displayName);
      expect(res.department, departmentId);
      expect(res.role, role);
      expect(res.id, id);
    }));

    httpMock
        .expectOne(url: '/register', method: Method.post)
        .flush(<String, dynamic>{
      'data': <String, dynamic>{
        'role': 1,
        'roleName': 'Citizen',
        'id': id,
        'username': username,
        'displayName': 'displayname',
        'department': departmentId,
      },
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should request password change with oldpassword', () {
    const String id = '1234';
    const String oldPassword = '123';
    const String newPassword = '123';

    accountApi
        .changePasswordWithOld(id, oldPassword, newPassword)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/password/$id', method: Method.put)
        .flush(<String, dynamic>{
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should request password change with token', () {
    const String id = '1234';
    const String oldPassword = '123';
    const String token = '123';

    accountApi
        .changePassword(id, oldPassword, token)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/password/$id', method: Method.post)
        .flush(<String, dynamic>{
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should request account deletion', () {
    const String id = '1234';
    accountApi.delete(id).listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/user/$id', method: Method.delete, statusCode: 400)
        .flush(<String, dynamic>{
      'message': '',
      'errorKey': 'NoError',
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
