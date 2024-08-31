import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => DisplayNameModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'displayName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
      'userIcon': null
    };

    final DisplayNameModel model = DisplayNameModel.fromJson(json);
    expect(model.id, json['userId']);
    expect(model.role, json['userRole']);
    expect(model.displayName, json['displayName']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'displayName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
      'userIcon': null
    };

    final DisplayNameModel model = DisplayNameModel.fromJson(json);

    expect(model.toJson(), json);
  });

  test('Can create from GirafUserModel', () {
    final GirafUserModel girafUser = GirafUserModel(
      roleName: Role.Guardian.toString(),
      displayName: 'User',
      id: '1',
    );

    final DisplayNameModel user = DisplayNameModel.fromGirafUser(girafUser);

    expect(user.role, girafUser.roleName);
    expect(user.displayName, girafUser.displayName);
    expect(user.id, girafUser.id);
  });

  test('Has username property', () {
    const String username = 'testUsername';
    final DisplayNameModel model =
        DisplayNameModel(displayName: username, role: null, id: null);
    expect(model.displayName, username);
  });

  test('Has role property', () {
    const String role = 'testRole';
    final DisplayNameModel model =
        DisplayNameModel(displayName: 'testRole', role: role, id: null);
    expect(model.role, role);
  });

  test('Has id property', () {
    const String id = 'testId';
    final DisplayNameModel model =
        DisplayNameModel(displayName: 'testId', role: null, id: id);
    expect(model.id, id);
  });

  test('Has displayName property', () {
    const String displayName = 'testDisplayName';
    final DisplayNameModel model =
        DisplayNameModel(displayName: displayName, role: null, id: 'testID');
    expect(model.displayName, displayName);
  });
}
