import 'package:weekplanner/models/department_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => DepartmentModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> userJson = <String, dynamic>{
      'displayName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
      'userIcon': null
    };

    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'name': 'testName',
      'members': <Map<String, dynamic>>[userJson],
      'resources': <int>[1, 2, 3],
    };

    final DepartmentModel model = DepartmentModel.fromJson(json);
    expect(model.id, json['id']);
    expect(model.name, json['name']);
    expect(model.members!.map((DisplayNameModel val) => val.toJson()),
        <Map<String, dynamic>>[userJson]);
    expect(model.resources, json['resources']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> userJson = <String, dynamic>{
      'displayName': 'testUsername',
      'userRole': 'testRole',
      'userId': 'testID',
      'userIcon': null
    };

    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'name': 'testName',
      'members': <Map<String, dynamic>>[userJson],
      'resources': <int>[1, 2, 3],
    };

    final DepartmentModel model = DepartmentModel.fromJson(json);

    expect(model.toJson(), json);
  });
}
