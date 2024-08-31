import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';

/// Pictogram endpoints
class ActivityApi {
  /// Default constructor
  ActivityApi(this._http);

  final Http _http;

  /// Adds the specified activity
  ///
  /// [activity] Activity to add.
  /// [userId] User ID
  /// [weekplanName] Name of the week plan
  /// [weekYear] Year of the week
  /// [weekNumber] Week number of the week
  /// [weekDay] Day of the week that the activity should be added to
  Stream<ActivityModel> add(ActivityModel activity, String userId,
      String weekplanName, int weekYear, int weekNumber, Weekday weekDay) {
    return _http
        .post(
            '/$userId/$weekplanName/$weekYear/$weekNumber/${weekDay.index + 1}',
            activity.toJson())
        .map((Response res) {
      return ActivityModel.fromJson(res.json['data']);
    });
  }

  /// Updates the activity with the specified ID
  ///
  /// [activity] Activity with an id that updates values in the database
  /// [userId] User ID
  Stream<ActivityModel> update(ActivityModel activity, String userId) {
    return _http.put('/$userId/update', activity.toJson()).map((Response res) {
      return ActivityModel.fromJson(res.json['data']);
    });
  }

  /// Deletes the activity with the specified ID
  ///
  /// [activityId] ID of the activity to delete
  /// [userID] User ID
  Stream<bool> delete(int activityId, String userId) {
    return _http.delete('/$userId/delete/$activityId').map((Response res) {
      return res.success();
    });
  }

  /// Updates the activitys timer with the specified ID
  ///
  /// [activity] Activity with an id that updates values in the database
  /// [userId] User ID
  Stream<ActivityModel> updateTimer(ActivityModel activity, String userId) {
    return _http
        .put('/$userId/updatetimer', activity.toJson())
        .map((Response res) {
      return ActivityModel.fromJson(res.json['data']);
    });
  }
}
