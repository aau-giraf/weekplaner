import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

/// Base model for a week
abstract class WeekBaseModel {
  /// [Thumbnail] id for pictogram
  /// [name] name for the weekmodel
  /// [days] List of weekday models for the week
  WeekBaseModel({this.thumbnail, this.name, this.days});

  /// Constructor from Json
  WeekBaseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekBaseModel]: Cannot initialize from null');
    }

    name = json['name'];

    // WeekModel sometimes don't have a thumbnail
    if (json['thumbnail'] != null) {
      thumbnail = PictogramModel.fromJson(json['thumbnail']);
    }

    // WeekModel sometimes dont have days
    if (json['days'] != null && json['days'] is List) {
      days = List<Map<String, dynamic>>.from(json['days'])
          .map((Map<String, dynamic> element) => WeekdayModel.fromJson(element))
          .toList();
    }
  }

  /// Creates a weekbase model from offline database json
  WeekBaseModel.fromDatabase(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[WeekBaseModel]: Cannot initialize from null');
    }

    name = json['name'];

    // WeekModel sometimes don't have a thumbnail
    if (json['thumbnail'] != null) {
      thumbnail = PictogramModel.fromJson(json['thumbnail']);
    }

    // WeekModel sometimes dont have days
    if (json['days'] != null && json['days'] is List) {
      days = List<Map<String, dynamic>>.from(json['days'])
          .map((Map<String, dynamic> element) =>
              WeekdayModel.fromDatabase(element))
          .toList();
    }
  }

  /// Id for a pictogram to be used as thumbnail
  PictogramModel? thumbnail;

  /// Name for the weekModel
  String? name;

  /// List of seven days connected to the week
  List<WeekdayModel>? days;
}
