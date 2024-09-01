import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/user_week_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

/// Bloc that streams the currently chosen weekplan
class WeekplanBloc extends BlocBase {
  /// Constructor that initializes _api
  WeekplanBloc(this._api);

  /// The stream that emits the currently chosen weekplan
  Stream<UserWeekModel> get userWeek => _userWeek.stream;

  final List<rx_dart.BehaviorSubject<WeekdayModel>> _weekDayStreams =
      <rx_dart.BehaviorSubject<WeekdayModel>>[];

  /// The stream that emits whether in editMode or not
  Stream<bool> get editMode => _editMode.stream;

  /// The stream that emits the marked activities
  Stream<List<ActivityModel>> get markedActivities => _markedActivities!.stream;

  /// The current visibility of the activityPlaceholder-container.
  Stream<bool> get activityPlaceholderVisible =>
      _activityPlaceholderVisible.stream;

  /// Checks if there are no selected activities
  Stream<bool> get atLeastOneActivityMarked => _atLeastOneActivityMarked();

  /// The API
  final Api _api;
  final rx_dart.BehaviorSubject<bool> _editMode =
      rx_dart.BehaviorSubject<bool>.seeded(false);
  final rx_dart.BehaviorSubject<List<ActivityModel>>? _markedActivities =
      rx_dart.BehaviorSubject<List<ActivityModel>>.seeded(<ActivityModel>[]);
  final rx_dart.BehaviorSubject<UserWeekModel> _userWeek =
      rx_dart.BehaviorSubject<UserWeekModel>();
  final rx_dart.BehaviorSubject<bool> _activityPlaceholderVisible =
      rx_dart.BehaviorSubject<bool>.seeded(false);

  late WeekModel _week;

  int _daysToDisplay = 0;
  int _firstDay = 0;

  /// Set how many days are displayed and which day is the first
  void setDaysToDisplay(int numDays, int firstDay) {
    _daysToDisplay = numDays;
    _firstDay = firstDay;
  }

  /// Sink to set the currently chosen week
  Future<void> getWeek(WeekModel week, DisplayNameModel user) async {
    _api.week
        .get(user.id!, week.weekYear, week.weekNumber)
        .listen((WeekModel loadedWeek) {
      _week = loadedWeek;
      _userWeek.add(UserWeekModel(loadedWeek, user));
    }).onError((Object error) {
      return Future<void>.error(error);
    });
    return Future<void>.value();
  }

  /// Get the current week fresh from the api
  Future<void> loadWeek(DisplayNameModel user) async {
    _api.week
        .get(user.id!, _week.weekYear, _week.weekNumber)
        .listen((WeekModel loadedWeek) {
      _userWeek.add(UserWeekModel(loadedWeek, user));
      _week = loadedWeek;
      for (int i = 0; i < _daysToDisplay; i++) {
        _weekDayStreams[i].add(loadedWeek.days![i - _firstDay]);
      }
    }).onError((Object error) {
      return Future<void>.error(error);
    });
    return Future<void>.value();
  }

  /// Adds a new marked activity to the stream
  void addMarkedActivity(ActivityModel activityModel) {
    final List<ActivityModel> localMarkedActivities = _markedActivities!.value;

    localMarkedActivities.add(activityModel);
    _markedActivities.add(localMarkedActivities);
  }

  /// Removes a marked activity from the stream
  void removeMarkedActivity(ActivityModel activityModel) {
    final List<ActivityModel> localMarkedActivities = _markedActivities!.value;

    localMarkedActivities.remove(activityModel);
    _markedActivities.add(localMarkedActivities);
  }

  /// Clears marked activities
  void clearMarkedActivities() {
    _markedActivities!.add(<ActivityModel>[]);
  }

  /// Getter for weekdaystreams
  Stream<WeekdayModel> getWeekdayStream(int index) {
    return _weekDayStreams[index].stream;
  }

  /// Add a new weekdaystream
  void addWeekdayStream() {
    _weekDayStreams.add(rx_dart.BehaviorSubject<WeekdayModel>.seeded(
        _week.days![_firstDay + _weekDayStreams.length]));
  }

  /// Clear weekdaystreams list
  void clearWeekdayStreams() {
    for (rx_dart.BehaviorSubject<WeekdayModel> i in _weekDayStreams) {
      i.close();
    }
    _weekDayStreams.clear();
  }

  /// Checks if an activity is marked
  bool isActivityMarked(ActivityModel activityModel) {
    if (_markedActivities?.value == null) {
      return false;
    }
    return _markedActivities!.value.contains(activityModel);
  }

  /// set the marked activities as canceled
  Future<void> cancelMarkedActivities() async {
    final List<WeekdayModel> daysToUpdate = <WeekdayModel>[];
    for (ActivityModel activity in _markedActivities!.value) {
      activity.state = ActivityState.Canceled;
      for (WeekdayModel day in _week.days!) {
        if (day.activities!.contains(activity)) {
          daysToUpdate.add(day);
        }
      }
    }
    clearMarkedActivities();
    updateWeekdays(daysToUpdate).catchError((Object error) {
      return Future<void>.error(error);
    });
  }

  /// Delete the marked activities when the trash button is clicked
  Future<void> deleteMarkedActivities() async {
    final List<WeekdayModel> daysToUpdate = <WeekdayModel>[];

    for (ActivityModel activity in _markedActivities!.value) {
      for (WeekdayModel day in _week.days!) {
        if (day.activities!.contains(activity)) {
          day.activities!.remove(activity);
          daysToUpdate.add(day);
        }
      }
    }
    clearMarkedActivities();
    updateWeekdays(daysToUpdate).catchError((Object error) {
      return Future<void>.error(error);
    });
  }

  /// Set the marked activities as resumed
  Future<void> undoMarkedActivities() async {
    final List<WeekdayModel> daysToUpdate = <WeekdayModel>[];
    for (ActivityModel activity in _markedActivities!.value) {
      activity.state = ActivityState.Active;
      for (WeekdayModel day in _week.days!) {
        if (day.activities!.contains(activity)) {
          daysToUpdate.add(day);
        }
      }
    }
    clearMarkedActivities();
    updateWeekdays(daysToUpdate).catchError((Object error) {
      return Future<void>.error(error);
    });
  }

  /// Set the marked activities as resumed
  // ignore: non_constant_identifier_names
  void UndoMarkedActivities() {
    final WeekModel week = _userWeek.value.week;
    final DisplayNameModel user = _userWeek.value.user;

    for (ActivityModel activity in _markedActivities!.value) {
      activity.state = ActivityState.Active;
    }

    _api.week
        .update(user.id!, week.weekYear, week.weekNumber, week)
        .listen((WeekModel newWeek) {
      _userWeek.add(UserWeekModel(newWeek, user));
    });

    clearMarkedActivities();
  }

  /// Copies the marked activities to the given days
  Future<void> copyMarkedActivities(List<bool> days) async {
    final List<WeekdayModel> daysToUpdate = <WeekdayModel>[];

    for (int dayOfWeek = 0; dayOfWeek < days.length; dayOfWeek++) {
      if (days[dayOfWeek]) {
        for (ActivityModel activity in _markedActivities!.value) {
          // Make a copy of the given activity with the state reset
          // and make sure it is added at as the last activity of the day.
          final ActivityModel newActivity = ActivityModel(
              id: activity.id,
              pictograms: activity.pictograms,
              order: _week.days![dayOfWeek].activities!.length,
              isChoiceBoard: activity.isChoiceBoard,
              state: ActivityState.Normal,
              title: activity.title,
              choiceBoardName: activity.choiceBoardName.toString(),
              timer: activity.timer);

          // Add the copy to the specified day

          _week.days![dayOfWeek].activities!.add(newActivity);
          daysToUpdate.add(_week.days![dayOfWeek]);
        }
      }
    }

    clearMarkedActivities();
    updateWeekdays(daysToUpdate).catchError((Object error) {
      return Future<void>.error(error);
    });
  }

  /// Toggles edit mode
  void toggleEditMode() {
    if (_editMode.value) {
      clearMarkedActivities();
    }
    _editMode.add(!_editMode.value);
  }

  /// Manually set edit mode
  void setEditMode(bool value) {
    if (_editMode.value) {
      clearMarkedActivities();
    }
    _editMode.add(value);
  }

  /// Used to change the visibility of the activityPlaceholder container.
  void setActivityPlaceholderVisible(bool visibility) {
    _activityPlaceholderVisible.add(visibility);
  }

  /// Adds an activity to the given day.
  Future<void> addActivity(ActivityModel activity, int day) {
    final Completer<void> completer = Completer<void>();
    final DisplayNameModel user = _userWeek.value.user;
    _api.activity
        .add(activity, user.id!, _week.name!, _week.weekYear, _week.weekNumber,
            _week.days![day].day!)
        .listen((ActivityModel ac) {
      _week.days![day].activities!.add(ac);
      updateWeekdays(<WeekdayModel>[_week.days![day]])
          .catchError((Object error) {
        completer.completeError(error);
      });
      completer.complete();
    }).onError((Object error) {
      completer.completeError(error);
    });

    Future.wait(<Future<void>>[completer.future]);
    return completer.future;
  }

  /// Returns the number of marked activities
  int getNumberOfMarkedActivities() {
    return _markedActivities!.value.length;
  }

  /// Reorders activities between same or different days.
  Future<void> reorderActivities(ActivityModel activity, Weekday dayFrom,
      Weekday dayTo, int newOrder) async {
    // Removed from dayFrom, the day the pictogram is dragged from
    int dayLength = _week.days![dayFrom.index].activities!.length;

    final List<WeekdayModel> daysToUpdate = <WeekdayModel>[];
    for (int i = activity.order; i < dayLength; i++) {
      final ActivityModel activityAtIndex =
          _week.days![dayTo.index].activities![i];

      activityAtIndex.order = (activityAtIndex.order) - 1;
    }

    _week.days![dayFrom.index].activities!
        .removeWhere((ActivityModel a) => a.id == activity.id);
    daysToUpdate.add(_week.days![dayFrom.index]);

    activity.order = dayFrom == dayTo &&
            _week.days![dayTo.index].activities!.length == newOrder - 1
        ? newOrder - 1
        : newOrder;

    // Inserts into dayTo, the day that the pictogram is inserted to
    dayLength = _week.days![dayTo.index].activities!.length;

    for (int i = activity.order; i < dayLength; i++) {
      final ActivityModel activityAtIndex =
          _week.days![dayTo.index].activities![i];

      activityAtIndex.order = (activityAtIndex.order) + 1;
    }

    if (dayFrom != dayTo) {
      daysToUpdate.add(_week.days![dayTo.index]);
    }
    _week.days![dayTo.index].activities!.insert(activity.order, activity);

    updateWeekdays(daysToUpdate).catchError((Object error) {
      return Future<void>.error(error);
    });
    return Future<void>.value();
  }

  Stream<bool> _atLeastOneActivityMarked() {
    return _markedActivities!
        .map((List<ActivityModel> activities) => activities.isNotEmpty);
  }

  /// Method to get a single weekday from the api
  Future<void> getWeekday(Weekday day) async {
    final DisplayNameModel user = _userWeek.value.user;
    _api.week
        .getDay(user.id!, _week.weekYear, _week.weekNumber, day)
        .listen((WeekdayModel newDay) {
      _weekDayStreams[newDay.day!.index - _firstDay].add(newDay);
    }).onError((Object error) {
      return Future<void>.error(error);
    });

    return Future<void>.value();
  }

  /// Method to update a given list of weekdays
  Future<void> updateWeekdays(List<WeekdayModel> days) async {
    final DisplayNameModel user = _userWeek.value.user;
    for (WeekdayModel day in days) {
      _api.week
          .updateDay(user.id!, _week.weekYear, _week.weekNumber, day)
          .listen((WeekdayModel newDay) {
        _weekDayStreams[newDay.day!.index - _firstDay].add(newDay);
        _week.days![newDay.day!.index] = newDay;
      }).onError((Object error) {
        return Future<void>.error(error);
      });
    }
    return Future<void>.value();
  }

  @override
  void dispose() {
    clearWeekdayStreams();
    _userWeek.close();
    _activityPlaceholderVisible.close();
    _markedActivities!.close();
  }
}
