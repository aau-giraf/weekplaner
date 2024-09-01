import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';

import '../../di.dart';
import '../../routes.dart';
import '../../style/custom_color.dart' as theme;
import '../giraf_notify_dialog.dart';
import '../weekplanner_choiceboard_selector.dart';
import 'activity_card.dart';

/// Widget used to create a single column in the weekplan screen.
class WeekplanActivitiesColumn extends StatelessWidget {
  /// Constructor
  WeekplanActivitiesColumn({
    required this.dayOfTheWeek,
    required this.color,
    required this.user,
    required this.weekplanBloc,
    required this.streamIndex,
    required this.activitiesToDisplay,
  }) {
    _settingsBloc.loadSettings(user);
  }

  /// The day of the week
  final Weekday dayOfTheWeek;

  /// The color that the column should be painted
  final Color color;

  /// User that we need to get settings for
  final DisplayNameModel user;

  /// Week plan bloc us which is needed as input because it needs to be the
  /// same as the one for the weekplan screen so di does not work.
  final WeekplanBloc weekplanBloc;

  /// Index of the weekday in the weekdayStreams list
  final int streamIndex;

  /// The number of activities to display if the option to only show activities
  /// is enabled
  final int activitiesToDisplay;

  final AuthBloc _authBloc = di.get<AuthBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();
  final ActivityBloc _activityBloc = di.get<ActivityBloc>();
  final TimerBloc _timerBloc = di.get<TimerBloc>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeekdayModel>(
        stream: weekplanBloc.getWeekdayStream(streamIndex),
        builder: (BuildContext context, AsyncSnapshot<WeekdayModel> snapshot) {
          if (snapshot.hasData) {
            final WeekdayModel _dayModel = trimToActive(snapshot.data!);

            return Card(color: color, child: _day(_dayModel, context));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Column _day(WeekdayModel weekday, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ///_translateWeekDay(weekday.day),
        ///_buildDaySelectorButtons(context, weekday),
        _buildDayActivities(weekday),

        ///_buildAddActivityButton(weekday, context)
      ],
    );
  }

  /// Marks all activities for a given day
  void markAllDayActivities(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities!) {
      if (weekplanBloc.isActivityMarked(activity) == false) {
        weekplanBloc.addMarkedActivity(activity);
      }
    }
  }

  /// Unmarks all activities for a given day
  void unmarkAllDayActivities(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities!) {
      if (weekplanBloc.isActivityMarked(activity) == true) {
        weekplanBloc.removeMarkedActivity(activity);
      }
    }
  }

  /// Marks the first Normal activity to Active
  void markCurrent(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities!) {
      if (activity.state == ActivityState.Normal) {
        activity.state = ActivityState.Active;
        break;
      }
    }
  }

  /// Find the first active activity and gets its index
  int findActiveIndex(WeekdayModel weekdayModel) {
    resetActiveMarks(weekdayModel);
    markCurrent(weekdayModel);
    int index = 0;
    for (ActivityModel activity in weekdayModel.activities!) {
      if (activity.state == ActivityState.Active) {
        return index;
      }
      index++;
    }
    return index;
  }

  /// Returns a modified WeekdayModel that only contains activities from the
  /// first active activity
  WeekdayModel trimToActive(WeekdayModel weekday) {
    final List<ActivityModel> activities = <ActivityModel>[];
    final int activeIndex = findActiveIndex(weekday);
    for (int i = activeIndex;
        i < weekday.activities!.length && i < activeIndex + activitiesToDisplay;
        i++) {
      activities.add(weekday.activities![i]);
    }
    weekday.activities = activities;
    return weekday;
  }

  /// Sets all activites to Normal state
  void resetActiveMarks(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities!) {
      if (activity.state == ActivityState.Active) {
        activity.state = ActivityState.Normal;
      }
    }
  }

  /// Builds a day's activities
  StreamBuilder<List<ActivityModel>> _buildDayActivities(WeekdayModel weekday) {
    return StreamBuilder<List<ActivityModel>>(
        stream: weekplanBloc.markedActivities,
        builder: (BuildContext context,
            AsyncSnapshot<List<ActivityModel>> markedActivities) {
          return StreamBuilder<bool>(
              initialData: false,
              stream: weekplanBloc.editMode,
              builder:
                  (BuildContext context, AsyncSnapshot<bool> editModeSnapshot) {
                return StreamBuilder<SettingsModel?>(
                    stream: _settingsBloc.settings,
                    builder: (BuildContext context,
                        AsyncSnapshot<SettingsModel?> settingsSnapshot) {
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            resetActiveMarks(weekday);
                            markCurrent(weekday);
                            if (index >= weekday.activities!.length) {
                              return StreamBuilder<bool>(
                                  stream:
                                      weekplanBloc.activityPlaceholderVisible,
                                  initialData: false,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<bool> snapshot) {
                                    return Visibility(
                                      key: const Key('GreyDragVisibleKey'),
                                      visible: snapshot.data!,
                                      child: _dragTargetPlaceholder(
                                          index, weekday),
                                    );
                                  });
                            } else {
                              return StreamBuilder<WeekplanMode>(
                                  stream: _authBloc.mode,
                                  initialData: WeekplanMode.guardian,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<WeekplanMode> snapshot) {
                                    return _pictogramIconStack(context, index,
                                        weekday, editModeSnapshot.data!);
                                  });
                            }
                          },
                          itemCount: weekday.activities!.length + 1,
                        ),
                      );
                    });
              });
        });
  }

  DragTarget<Tuple2<ActivityModel, Weekday?>> _dragTargetPlaceholder(
      int dropTargetIndex, WeekdayModel weekday) {
    return DragTarget<Tuple2<ActivityModel, Weekday?>>(
      key: const Key('DragTargetPlaceholder'),
      builder: (BuildContext context,
          List<Tuple2<ActivityModel, Weekday?>?> candidateData,
          List<dynamic> rejectedData) {
        return const AspectRatio(
          aspectRatio: 1,
          child: Card(
            color: theme.GirafColors.dragShadow,
            child: ListTile(),
          ),
        );
      },
      onWillAcceptWithDetails:
          (DragTargetDetails<Tuple2<ActivityModel, Weekday?>> details) {
        // Draggable can be dropped on every drop target
        return true;
      },
      onAcceptWithDetails:
          (DragTargetDetails<Tuple2<ActivityModel, Weekday?>> details) {
        final Tuple2<ActivityModel, Weekday?> data = details.data;
        weekplanBloc.reorderActivities(
            data.item1, data.item2!, weekday.day!, dropTargetIndex);
      },
    );
  }

  // Returning a widget that stacks a pictogram and an status icon
  FittedBox _pictogramIconStack(
      BuildContext context, int index, WeekdayModel weekday, bool inEditMode) {
    final ActivityModel currActivity = weekday.activities![index];

    final bool isMarked = weekplanBloc.isActivityMarked(currActivity);

    return FittedBox(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          StreamBuilder<WeekplanMode>(
              stream: _authBloc.mode,
              initialData: WeekplanMode.guardian,
              builder: (BuildContext context,
                  AsyncSnapshot<WeekplanMode> modeSnapshot) {
                return StreamBuilder<SettingsModel?>(
                    stream: _settingsBloc.settings,
                    builder: (BuildContext context,
                        AsyncSnapshot<SettingsModel?> settingsSnapshot) {
                      if (settingsSnapshot.hasData && modeSnapshot.hasData) {
                        const double _width = 1;

                        return SizedBox(
                            // MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / _width,
                            //  MediaQuery.of(context).size.width / 1,
                            child: Container(
                              child: GestureDetector(
                                key: Key(weekday.day!.index.toString() +
                                    currActivity.id.toString()),
                                onTap: () {
                                  if (modeSnapshot.data ==
                                      WeekplanMode.guardian) {
                                    _handleOnTapActivity(
                                        inEditMode,
                                        isMarked,
                                        false,
                                        weekday.activities!,
                                        index,
                                        context,
                                        weekday);
                                  } else {
                                    _handleOnTapActivity(
                                        false,
                                        false,
                                        true,
                                        weekday.activities!,
                                        index,
                                        context,
                                        weekday);
                                  }
                                },
                                child:
                                    (modeSnapshot.data == WeekplanMode.guardian)
                                        ? _buildIsMarked(isMarked, context,
                                            weekday, weekday.activities!, index)
                                        : _buildIsMarked(
                                            false,
                                            context,
                                            weekday,
                                            weekday.activities!,
                                            index),
                              ),
                            ));
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    });
              }),
        ],
      ),
    );
  }

  /// Handles tap on an activity
  void _handleOnTapActivity(
      bool inEditMode,
      bool isMarked,
      bool isCitizen,
      List<ActivityModel> activities,
      int index,
      BuildContext context,
      WeekdayModel weekday) {
    build(context);
    if (inEditMode) {
      if (isMarked) {
        weekplanBloc.removeMarkedActivity(activities[index]);
      } else {
        weekplanBloc.addMarkedActivity(activities[index]);
      }
    } else if (activities[index].isChoiceBoard &&
        isCitizen &&
        !(activities[index].state == ActivityState.Canceled)) {
      showDialog<Center>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WeekplannerChoiceboardSelector(
                activities[index], _activityBloc, user);
          });
    } else if (!inEditMode) {
      Routes()
          .push(
              context,
              ShowActivityScreen(
                activities[index],
                user,
                weekplanBloc,
                _timerBloc,
                weekday,
                key: UniqueKey(),
              ))
          .whenComplete(() {
        weekplanBloc.getWeekday(weekday.day!).catchError((Object error) {
          creatingNotifyDialog(error, context);
        });
      });
    }
  }

  /// Builds activity card with a status icon if it is marked
  StatelessWidget _buildIsMarked(bool isMarked, BuildContext context,
      WeekdayModel weekday, List<ActivityModel> activities, int index) {
    if (index >= activities.length) {
      return Container(child: const CircularProgressIndicator());
    }
    if (isMarked) {
      return Container(
          key: const Key('isSelectedKey'),
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width * 0.1)),
          child: ActivityCard(activities[index], _timerBloc, user));
    } else {
      return ActivityCard(activities[index], _timerBloc, user);
    }
  }

  /// Function that creates the notify dialog,
  /// depeninding which error occured
  void creatingNotifyDialog(Object error, BuildContext context) {
    /// Show the new NotifyDialog
    String message = '';
    Key key;
    if (error is ApiException) {
      message = error.errorMessage ?? 'No error defined';
      // ignore: avoid_as
      key = error.errorKey as Key;
    } else {
      message = error.toString();
      key = const Key('UnknownError');
    }
    showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: 'Fejl', description: message, key: key);
        });
  }
}
