import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';

import '../../di.dart';
import '../../routes.dart';
import '../../style/custom_color.dart' as theme;
import '../giraf_button_widget.dart';
import '../giraf_notify_dialog.dart';
import '../weekplanner_choiceboard_selector.dart';
import 'activity_card.dart';

/// Widget used to create a single column in the weekplan screen.
class WeekplanDayColumn extends StatelessWidget {
  /// Constructor
  WeekplanDayColumn(
      {required this.color,
      required this.user,
      required this.weekplanBloc,
      required this.streamIndex}) {
    _settingsBloc.loadSettings(user);
  }

  /// The color that the column should be painted
  final Color color;

  /// User that we need to get settings for
  final DisplayNameModel user;

  /// Week plan bloc us which is needed as input because it needs to be the
  /// same as the one for the weekplan screen so di does not work.
  final WeekplanBloc weekplanBloc;

  /// Index of the weekday in the weekdayStreams list
  final int streamIndex;

  final AuthBloc _authBloc = di.get<AuthBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();
  final ActivityBloc _activityBloc = di.get<ActivityBloc>();
  final List<TimerBloc> _timerBloc = <TimerBloc>[];

  /// Method used to create TimerBlocs.
  void createTimerBlocs(int numOfTimeBlocs) {
    for (int i = 0; i <= numOfTimeBlocs - _timerBloc.length; i++) {
      _timerBloc.add(di.get<TimerBloc>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeekdayModel>(
        stream: weekplanBloc.getWeekdayStream(streamIndex),
        builder: (BuildContext context, AsyncSnapshot<WeekdayModel> snapshot) {
          if (snapshot.hasData) {
            final WeekdayModel _dayModel = snapshot.data!;
            createTimerBlocs(_dayModel.activities!.length);
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
        _translateWeekDay(weekday.day!),
        _buildDaySelectorButtons(context, weekday),
        _buildDayActivities(weekday),
        _buildAddActivityButton(weekday, context)
      ],
    );
  }

  Card _translateWeekDay(Weekday day) {
    String translation;
    switch (day) {
      case Weekday.Monday:
        translation = 'Mandag';
        break;
      case Weekday.Tuesday:
        translation = 'Tirsdag';
        break;
      case Weekday.Wednesday:
        translation = 'Onsdag';
        break;
      case Weekday.Thursday:
        translation = 'Torsdag';
        break;
      case Weekday.Friday:
        translation = 'Fredag';
        break;
      case Weekday.Saturday:
        translation = 'Lørdag';
        break;
      case Weekday.Sunday:
        translation = 'Søndag';
        break;
      default:
        translation = '';
        break;
    }

    return Card(
      key: Key(translation),
      color: theme.GirafColors.buttonColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0.0), // Sets padding in cards
        title: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Stroked text as border.
            AutoSizeText(
              translation,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isToday(day) ? 40 : 30,
                foreground: Paint()
                  ..style =
                      isToday(day) ? PaintingStyle.stroke : PaintingStyle.fill
                  ..strokeWidth = 5
                  ..color = Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            // Solid text as fill.
            AutoSizeText(
              translation,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isToday(day) ? 40 : 30,
                color: isToday(day)
                    ? Color(int.parse('0xffffffff'))
                    : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  ///Builds the selector buttons day
  Container _buildDaySelectorButtons(
      BuildContext context, WeekdayModel weekDay) {
    return Container(
        child: StreamBuilder<WeekplanMode>(
      stream: _authBloc.mode,
      initialData: WeekplanMode.guardian,
      builder: (BuildContext context, AsyncSnapshot<WeekplanMode> snapshot) {
        return Visibility(
          visible: snapshot.data == WeekplanMode.guardian,
          child: StreamBuilder<bool>(
            stream: weekplanBloc.editMode,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data!) {
                return Container(
                  child: Column(children: <Widget>[
                    GirafButton(
                      text: 'Vælg alle',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 35,
                      width: 110,
                      key: const Key('SelectAllButton'),
                      onPressed: () {
                        markAllDayActivities(weekDay);
                      },
                    ),
                    const SizedBox(height: 3.5),
                    GirafButton(
                      text: 'Fravælg alle',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 35,
                      width: 110,
                      key: const Key('DeselectAllButton'),
                      onPressed: () {
                        unmarkAllDayActivities(weekDay);
                      },
                    ),
                  ]),
                );
              } else {
                return Container(width: 0.0, height: 0.0);
              }
            },
          ),
        );
      },
    ));
  }

  /// Marks all activities for a given day
  void markAllDayActivities(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities!) {
      if (weekplanBloc.isActivityMarked(activity) == false) {
        weekplanBloc.addMarkedActivity(activity);
      }
    }
  }

  /// Returns true if the field dayOfTheWeek matches with today's date
  /// This function is mainly used for highlighting today's date on the weekplan
  bool isToday(Weekday weekday) {
    return DateTime.now().weekday.toInt() - 1 == weekday.index;
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
    if (isToday(weekdayModel.day!)) {
      for (ActivityModel activity in weekdayModel.activities!) {
        if (activity.state == ActivityState.Normal) {
          activity.state = ActivityState.Active;
          break;
        }
      }
    }
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
                                    if (snapshot.data ==
                                        WeekplanMode.guardian) {
                                      return _dragTargetPictogram(
                                          index,
                                          weekday,
                                          editModeSnapshot.data!,
                                          context);
                                    }
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

  DragTarget<Tuple2<ActivityModel, Weekday>> _dragTargetPlaceholder(
      int dropTargetIndex, WeekdayModel weekday) {
    return DragTarget<Tuple2<ActivityModel, Weekday>>(
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
      onWillAccept: (Tuple2<ActivityModel, Weekday?>? data) {
        // Draggable can be dropped on every drop target
        return true;
      },
      onAccept: (Tuple2<ActivityModel, Weekday?> data) {
        weekplanBloc.reorderActivities(
            data.item1, data.item2!, weekday.day!, dropTargetIndex);
      },
    );
  }

  // Returns the draggable pictograms, which also function as drop targets.
  DragTarget<Tuple2<ActivityModel, Weekday>> _dragTargetPictogram(
      int index, WeekdayModel weekday, bool inEditMode, BuildContext context) {
    return DragTarget<Tuple2<ActivityModel, Weekday>>(
      key: const Key('DragTarget'),
      builder: (BuildContext context,
          List<Tuple2<ActivityModel, Weekday>?> candidateData,
          List<dynamic> rejectedData) {
        return LongPressDraggable<Tuple2<ActivityModel, Weekday>>(
          data: Tuple2<ActivityModel, Weekday>(
              weekday.activities![index], weekday.day!),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          child: _pictogramIconStack(context, index, weekday, inEditMode),
          childWhenDragging: Opacity(
              opacity: 0.5,
              child: _pictogramIconStack(context, index, weekday, inEditMode)),
          onDragStarted: () => weekplanBloc.setActivityPlaceholderVisible(true),
          onDragCompleted: () =>
              weekplanBloc.setActivityPlaceholderVisible(false),
          onDragEnd: (DraggableDetails details) =>
              weekplanBloc.setActivityPlaceholderVisible(false),
          feedback: Container(
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.4
                  : MediaQuery.of(context).size.height * 0.4,
              child: _pictogramIconStack(context, index, weekday, inEditMode)),
        );
      },
      onWillAccept: (Tuple2<ActivityModel, Weekday>? data) {
        // Draggable can be dropped on every drop target
        return true;
      },
      onAccept: (Tuple2<ActivityModel, Weekday> data) {
        weekplanBloc
            .reorderActivities(data.item1, data.item2, weekday.day!, index)
            .catchError((Object error) {
          creatingNotifyDialog(error, context);
        });
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
                            width: MediaQuery.of(context).size.width / _width,
                            child: Container(
                              child: GestureDetector(
                                key: Key(weekday.day!.index.toString() +
                                    currActivity.id.toString()),
                                onTap: () {
                                  if (modeSnapshot.data ==
                                          WeekplanMode.guardian ||
                                      modeSnapshot.data ==
                                          WeekplanMode.trustee) {
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

  void _handleActivity(
      List<ActivityModel> activities, int index, WeekdayModel weekday) {
    final ActivityModel activistModel = activities[index];
    if (activistModel.state == ActivityState.Completed ||
        (activistModel.timer != null && activistModel.timer!.paused == false)) {
      return;
    }
    _activityBloc.load(activistModel, user);
    _activityBloc.accesWeekPlanBloc(weekplanBloc, weekday);
    _timerBloc[index].load(activistModel, user: user);
    _timerBloc[index].setActivityBloc(_activityBloc);
    _activityBloc.addHandlerToActivityStateOnce();
    _timerBloc[index].addHandlerToRunningModeOnce();
    _timerBloc[index].initTimer();

    if (activistModel.timer == null) {
      _activityBloc.completeActivity();
    } else {
      _timerBloc[index].playTimer();
    }
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
    } else if (isCitizen) {
      _handleActivity(activities, index, weekday);
    } else if (!inEditMode) {
      Routes()
          .push(
              context,
              ShowActivityScreen(activities[index], user, weekplanBloc,
                  _timerBloc[index], weekday,
                  key: UniqueKey()))
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
          child: ActivityCard(activities[index], _timerBloc[index], user));
    } else {
      return ActivityCard(activities[index], _timerBloc[index], user);
    }
  }

  /// Button style for the add activity screen
  final ButtonStyle addActivityStyle = ElevatedButton.styleFrom(
    backgroundColor: theme.GirafColors.buttonColor,
  );

  Container _buildAddActivityButton(
      WeekdayModel weekday, BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.width * 0.01
                    : MediaQuery.of(context).size.height * 0.01),
        child: ButtonTheme(
          child: SizedBox(
            width: double.infinity,
            child: StreamBuilder<WeekplanMode>(
                stream: _authBloc.mode,
                builder: (BuildContext context,
                    AsyncSnapshot<WeekplanMode> snapshot) {
                  return Visibility(
                    visible: snapshot.data == WeekplanMode.guardian,
                    child: ElevatedButton(
                        style: addActivityStyle,
                        key: const Key('AddActivityButton'),
                        child: Image.asset('assets/icons/add.png'),
                        onPressed: () async {
                          Routes()
                              .push(
                                  context,
                                  PictogramSearch(
                                    user: user,
                                  ))
                              .then((Object? object) {
                            if (object is PictogramModel) {
                              final PictogramModel newPictogram = object;
                              weekplanBloc.addActivity(
                                  ActivityModel(
                                      id: newPictogram.id!,
                                      pictograms: <PictogramModel>[
                                        newPictogram
                                      ],
                                      order: weekday.activities!.length,
                                      state: ActivityState.Normal,
                                      isChoiceBoard: false,
                                      title: object.title),
                                  weekday.day!.index);
                            }
                          });
                        }),
                  );
                }),
          ),
        ));
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
