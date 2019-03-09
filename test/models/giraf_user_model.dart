// Import the test package and Counter class
import 'dart:convert';

import 'package:test_api/test_api.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/role_enum.dart';

void main() {
    GirafUser user = GirafUser();

    test('Should contain a Role', () {
      user.role = Role.Department;

      expect(user.role, Role.Department);
    });

    test('Should contain a roleName', (){
      user.roleName = "Department";

      expect(user.roleName, "Department");
    });

    test('Should contain a username', (){
      user.username = "Graatand";

      expect(user.username, "Graatand");
    });

    test('Should contain a screenName', (){
      user.screenName = "Peter Graatand";

      expect(user.screenName, "Peter Graatand");
    });

    test('Should contain a department', (){
      user.department = 1;

      expect(user.department, 1);
    });

    test('Should be able to instatiate from JSON response', (){
      Map<String, dynamic> response = {
        "role": 3,
        "roleName": "Guardian",
        "id": "9ff3e3d9-07f6-4dc5-84d4-3e778aa977cc",
        "username": "Graatand",
        "screenName": null,
        "department": 1
      };


      GirafUser user2 = GirafUser.fromJson(response);

      expect(user2.role, Role.Guardian);
      expect(user2.roleName, "Guardian");
      expect(user2.id, "9ff3e3d9-07f6-4dc5-84d4-3e778aa977cc");
      expect(user2.username, "Graatand");
      expect(user2.screenName, isNull);
      expect(user2.department, 1);
    });

    test('Should be able to serialize into json', (){

      GirafUser user3 = GirafUser(
        id: "VALID-ID",
        role: Role.Department,
        roleName: "Department",
        username: "Graatand",
        screenName: "Peter Hansen",
        department: 1
      );

      Map<String, dynamic> json = user3.toJson();

      expect(json["role"], Role.Department.index);
      expect(json["roleName"], "Department");
      expect(json["id"], "VALID-ID");
      expect(json["username"], "Graatand");
      expect(json["screenName"], "Peter Hansen");
      expect(json["department"], 1);
    });

}