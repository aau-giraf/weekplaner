import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, dynamic> response = <String, dynamic>{
    'hexColor': '#067700',
    'day': 1
  };

  test('Can instantiate from JSON', () {
    final WeekdayColorModel weekdayColor = WeekdayColorModel.fromJson(response);

    expect(weekdayColor.hexColor, response['hexColor']);
    expect(weekdayColor.day, Weekday.values[response['day'] - 1]);
  });

  test('Throws exception if JSON input is null', () {
    expect(() => WeekdayColorModel.fromJson(null), throwsFormatException);
  });

  test('Can serialize to json', () {
    final WeekdayColorModel weekdayColor = WeekdayColorModel.fromJson(response);

    expect(weekdayColor.toJson(), response);
  });
}
