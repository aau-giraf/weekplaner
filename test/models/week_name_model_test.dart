import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/week_name_model.dart';

void main() {
  test('Throws on JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => WeekNameModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'name': 'uge 74',
      'weekYear': 2019,
      'weekNumber': 8
    };

    final WeekNameModel model = WeekNameModel.fromJson(json);
    expect(model.name, json['name']);
    expect(model.weekYear, json['weekYear']);
    expect(model.weekNumber, json['weekNumber']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'name': 'uge 74',
      'weekYear': 2019,
      'weekNumber': 8
    };

    expect(WeekNameModel.fromJson(json).toJson(), json);
  });
}
