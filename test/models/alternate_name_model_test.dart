import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/alternate_name_model.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => AlternateNameModel.fromJson(json), throwsFormatException);
  });

  test('Can covert from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'citizen': 'Test_Citizen',
      'pictogram': 5,
      'name': 'Test_name'
    };

    final AlternateNameModel model = AlternateNameModel.fromJson(json);

    expect(model.id, json['id']);
    expect(model.citizen, json['citizen']);
    expect(model.pictogram, json['pictogram']);
    expect(model.name, json['name']);
  });

  test('Can covert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'citizen': 'Test_Citizen',
      'pictogram': 5,
      'name': 'Test_name'
    };

    final AlternateNameModel model = AlternateNameModel.fromJson(json);
    expect(model.toJson(), json);
  });
}
