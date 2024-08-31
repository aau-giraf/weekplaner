import 'package:weekplanner/models/model.dart';

/// Represents the week name
class WeekNameModel implements Model {
  /// Default constructor
  WeekNameModel({
    this.name,
    this.weekYear,
    this.weekNumber,
  });

  /// Construct from JSON
  WeekNameModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekNameModel]: Cannot initialize from null');
    }

    name = json['name'];
    weekYear = json['weekYear'];
    weekNumber = json['weekNumber'];
  }

  /// Construct from offline database JSON
  WeekNameModel.fromDatabase(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekNameModel]: Cannot initialize from null');
    }

    name = json['name'];
    weekYear = json['weekYear'];
    weekNumber = json['weekNumber'];
  }

  /// A Name describing the week.
  String? name;

  /// The year of the week.
  int? weekYear;

  /// The number of the week, 0 - 52 (53).
  /// If the year starts on a Thursday or is a leap year,
  /// that  year will have 53 numbered weeks.
  int? weekNumber;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'weekYear': weekYear,
        'weekNumber': weekNumber,
      };
}
