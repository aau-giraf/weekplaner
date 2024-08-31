import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

/// Bloc to copy a weekplan to other users
class CopyWeekplanBloc extends ChooseCitizenBloc {
  /// Default constructor
  CopyWeekplanBloc(this._api) : super(_api);

  /// The stream that emits the marked activities
  Stream<List<DisplayNameModel>> get markedUserModels =>
      _markedUserModels.stream;

  final rx_dart.BehaviorSubject<List<DisplayNameModel>> _markedUserModels =
      rx_dart.BehaviorSubject<List<DisplayNameModel>>.seeded(
          <DisplayNameModel>[]);
  final Api _api;

  /// Copies weekplan to all selected citizens
  // ignore: avoid_void_async
  Future<List<bool>> copyWeekplan(List<WeekModel> weekModelList,
      DisplayNameModel currentUser, bool forThisCitizen) async {
    List<DisplayNameModel> users = <DisplayNameModel>[];
    if (forThisCitizen) {
      users.add(currentUser);
    } else {
      users = _markedUserModels.value;
    }

    final List<Future<bool>> callFutures = <Future<bool>>[];
    for (DisplayNameModel user in users) {
      for (WeekModel weekModel in weekModelList) {
        final Completer<bool> callCompleter = Completer<bool>();
        _api.week
            .update(
                user.id!, weekModel.weekYear, weekModel.weekNumber, weekModel)
            .take(1)
            .listen((WeekModel weekModel) {
          callCompleter.complete(true);
        });

        callFutures.add(callCompleter.future);
      }
    }
    return Future.wait(callFutures);
  }

  ///Checks whether a user has a conflict with a weekModel
  Future<bool> isConflictingUser(
      DisplayNameModel user, WeekModel weekModel) async {
    bool daysAreEmpty = true;

    final WeekModel response = await _api.week
        .get(user.id!, weekModel.weekYear, weekModel.weekNumber)
        .first;

    if (response.days == null) {
      return false;
    }

    for (WeekdayModel weekDay in response.days!) {
      daysAreEmpty = daysAreEmpty && weekDay.activities!.isEmpty;
    }

    ///Checks whether the name of the week model is different from the default
    /// created when no week exists
    if (daysAreEmpty) {
      final int weekYear = weekModel.weekYear;
      final int weekNumber = weekModel.weekNumber;
      daysAreEmpty = response.name!.compareTo('$weekYear - $weekNumber') == 0;
    }

    return !daysAreEmpty;
  }

  /// Returns a list of all users which already have a
  /// weekplan in the same week
  Future<List<DisplayNameModel>> getConflictingUsers(
      DisplayNameModel currentUser, WeekModel weekModel) async {
    final List<DisplayNameModel> users = _markedUserModels.value.isEmpty
        ? <DisplayNameModel>[currentUser]
        : _markedUserModels.value;
    final List<DisplayNameModel> conflictingUsers = <DisplayNameModel>[];

    for (DisplayNameModel user in users) {
      if (await isConflictingUser(user, weekModel)) {
        conflictingUsers.add(user);
      }
    }
    return conflictingUsers;
  }

  ///Returns a list with the names of all users with a conflict
  Future<List<String>> getAllConflictingUsers(
      DisplayNameModel currentUser, List<WeekModel> weekModelList) async {
    final List<String> result = <String>[];
    for (WeekModel weekModel in weekModelList) {
      await getConflictingUsers(currentUser, weekModel)
          .then((List<DisplayNameModel> nameList) {
        for (DisplayNameModel displayNameModel in nameList) {
          result.add(displayNameModel.displayName!);
        }
      });
    }
    return result;
  }

  /// Checks if any user has a conflicting weekplan
  Future<int> numberOfConflictingUsers(List<WeekModel> weekModelList,
      DisplayNameModel currentUser, bool forThisCitizen) async {
    int result = 0;
    for (WeekModel weekModel in weekModelList) {
      final List<DisplayNameModel> conflictingUsers =
          await getConflictingUsers(currentUser, weekModel);
      result += conflictingUsers.length;
    }
    return result;
  }

  /// Adds a new marked week model to the stream
  void toggleMarkedUserModel(DisplayNameModel user) {
    final List<DisplayNameModel> localMarkedUserModels =
        _markedUserModels.value;
    if (localMarkedUserModels.contains(user)) {
      localMarkedUserModels.remove(user);
    } else {
      localMarkedUserModels.add(user);
    }

    _markedUserModels.add(localMarkedUserModels);
  }
}
