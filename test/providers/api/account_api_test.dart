import 'package:test_api/test_api.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/role_enum.dart';
import 'package:weekplanner/providers/api/account_api.dart';
import 'package:weekplanner/providers/http/http_mock.dart';
import 'package:weekplanner/providers/peristence/persistence_mock.dart';

void main() {
  AccountApi accountApi;
  HttpMock httpMock;
  PersistenceMock persistenceMock;

  setUp(() {
    httpMock = HttpMock();
    persistenceMock = PersistenceMock();
    accountApi = AccountApi(httpMock, persistenceMock);
  });

  test("Should call login endpoint", () {
    accountApi
        .login("username", "password")
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock.expectOne(url: "/Account/login", method: Method.post).flush({
      "data": "TestToken",
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  test("Should request reset password token", () {
    String id = "1234";
    String token = "TestToken";

    accountApi.resetPasswordToken(id).listen(expectAsync1((String test) {
      expect(test, token);
    }));

    httpMock
        .expectOne(
            url: "/User/$id/Account/password-reset-token", method: Method.get)
        .flush({
      "data": token,
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  test("Should register user", () {
    const String id = "1234";
    const String username = "username";
    const String password = "password";
    const int departmentId = 123;
    const Role role = Role.Citizen;

    accountApi
        .register(username, password, departmentId: departmentId, role: role)
        .listen(expectAsync1((GirafUserModel res) {
      expect(res.username, username);
      expect(res.department, departmentId);
      expect(res.role, role);
      expect(res.id, id);
    }));

    httpMock.expectOne(url: "/Account/register", method: Method.post).flush({
      "data": {
        "role": 1,
        "roleName": "Citizen",
        "id": id,
        "username": username,
        "screenName": null,
        "department": departmentId,
      },
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  test("Should request password change with oldpassword", () {
    const String id = "1234";
    const String oldPassword = "123";
    const String newPassword = "123";

    accountApi
        .changePasswordWithOld(id, oldPassword, newPassword)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: "/User/$id/Account/password", method: Method.put)
        .flush({
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  test("Should request password change with token", () {
    const String id = "1234";
    const String oldPassword = "123";
    const String token = "123";

    accountApi
        .changePassword(id, oldPassword, token)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: "/User/$id/Account/password", method: Method.post)
        .flush({
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  test("Should request account deletion", () {
    const String id = "1234";
    accountApi.delete(id).listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock.expectOne(url: "/Account/user/$id", method: Method.delete).flush({
      "success": true,
      "errorProperties": [],
      "errorKey": "NoError",
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
