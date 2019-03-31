import 'package:weekplanner/models/model.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';

/// Represents the weekday color
class WeekdayColorModel implements Model {
  /// Default constructor
  WeekdayColorModel({this.hexColor, this.day});

  /// Construct from JSON
  WeekdayColorModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw const FormatException(
          '[WeekdayColorModel]: Cannot initialize from null');
    }

    hexColor = json['hexColor'];
    day = Weekday.values[json['day'] - 1];
  }

  /// The color of the day in Hex format
  String hexColor;

  /// The day of the week
  Weekday day;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'hexColor': hexColor, 'day': day.index + 1};
  }
}
