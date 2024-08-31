import 'package:weekplanner/models/department_name_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => DepartmentNameModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'name': 'testName',
    };

    final DepartmentNameModel model = DepartmentNameModel.fromJson(json);
    expect(model.id, json['id']);
    expect(model.name, json['name']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'name': 'testName',
    };

    expect(DepartmentNameModel.fromJson(json).toJson(), json);
  });
}
