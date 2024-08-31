import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/model.dart';

/// Represents the Weekday
class WeekdayModel implements Model {
  /// Default constructor
  WeekdayModel({required this.day, required this.activities});

  /// Construct from JSON
  WeekdayModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekdayModel]: Cannot instantiate from null');
    }

    day = Weekday.values[json['day'] - 1];
    if (json['activities'] is List) {
      activities = List<Map<String, dynamic>>.from(json['activities'])
          .map((Map<String, dynamic> val) => ActivityModel.fromJson(val))
          .toList();
    } else {
      // TODO(boginw): throw appropriate error
    }
  }

  /// Construct from Database
  WeekdayModel.fromDatabase(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekdayModel]: Cannot instantiate from null');
    }

    day = Weekday.values[json['day']];
    if (json['activities'] is List) {
      activities = List<Map<String, dynamic>>.from(json['activities'])
          .map((Map<String, dynamic> val) => ActivityModel.fromDatabase(val))
          .toList();
    }
  }

  /// Day of the week
  Weekday? day;

  /// List of activities for the day
  List<ActivityModel>? activities;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'day': day!.index + 1,
        'activities':
            activities!.map((ActivityModel val) => val.toJson()).toList(),
      };
}
