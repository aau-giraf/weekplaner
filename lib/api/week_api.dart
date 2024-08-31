import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

/// Week endpoints
class WeekApi {
  /// Default constructor
  WeekApi(this._http);

  final Http _http;

  /// Get week names from the user with the given ID
  ///
  /// [id] User ID
  Stream<List<WeekNameModel>?> getNames(String id) {
    return _http.get('/$id/weekName').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>?>.from(res.json['data'])
            .map((Map<String, dynamic>? json) => WeekNameModel.fromJson(json))
            .toList();
      } else {
        return <WeekNameModel>[];
      }
    });
  }

  /// Gets the Week with the specified week number and year for the user with
  /// the given id.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekModel> get(String id, int year, int weekNumber) {
    return _http.get('/$id/$year/$weekNumber').map((Response res) {
      return WeekModel.fromJson(res.json['data']);
    });
  }

  /// Get a single weekday from the specified week
  ///
  /// [id] User ID
  /// [year] The year of the week
  /// [weekNumber] The number of the week
  /// [day] The day of the week
  Stream<WeekdayModel> getDay(
      String id, int year, int weekNumber, Weekday day) {
    return _http.get('/$id/$year/$weekNumber/${day.index}').map((Response res) {
      return WeekdayModel.fromJson(res.json['data']);
    });
  }

  /// Updates the entire information of the week with the given year and week
  /// number.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekModel> update(
      String id, int year, int weekNumber, WeekModel week) {
    return _http
        .put('/$id/$year/$weekNumber', week.toJson())
        .map((Response res) {
      return WeekModel.fromJson(res.json['data']);
    });
  }

  /// Updates a single weekday
  ///
  /// [id] User Id
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<WeekdayModel> updateDay(
      String id, int year, int weekNumber, WeekdayModel weekday) {
    return _http
        .put('/day/$id/$year/$weekNumber', weekday.toJson())
        .map((Response res) {
      return WeekdayModel.fromJson(res.json['data']);
    });
  }

  /// Deletes all information for the entire week with the given year and week
  /// number.
  ///
  /// [id] User ID
  /// [year] Year the week is in
  /// [weekNumber] The week-number of the week
  Stream<bool> delete(String id, int year, int weekNumber) {
    return _http.delete('/$id/$year/$weekNumber').map((Response res) {
      return res.success();
    });
  }
}
