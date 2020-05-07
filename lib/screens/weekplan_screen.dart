import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/complete_mark_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/user_week_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';
import 'package:weekplanner/style/standard_week_colors.dart';
import 'package:weekplanner/widgets/bottom_app_bar_button_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_copy_activities_dialog.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';

import '../style/custom_color.dart' as theme;

/// <summary>
/// The WeekplanScreen is used to display a week
/// and all the activities that occur in it.
/// </summary>
class WeekplanScreen extends StatelessWidget {
  /// <summary>
  /// WeekplanScreen constructor
  /// </summary>
  /// <param name="key">Key of the widget</param>
  /// <param name="week">Week that should be shown on the weekplan</param>
  /// <param name="user">owner of the weekplan</param>
  WeekplanScreen(this._week, this._user, {Key key}) : super(key: key) {
    _weekplanBloc.loadWeek(_week, _user);
    _settingsBloc.loadSettings(_user);
  }

  final WeekplanBloc _weekplanBloc = di.getDependency<WeekplanBloc>();
  final SettingsBloc _settingsBloc = di.getDependency<SettingsBloc>();
  final AuthBloc _authBloc = di.getDependency<AuthBloc>();
  final DisplayNameModel _user;
  final WeekModel _week;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext context,
            AsyncSnapshot<WeekplanMode> weekModeSnapshot) {
          if (weekModeSnapshot.data == WeekplanMode.citizen) {
            _weekplanBloc.setEditMode(false);
          }
          return WillPopScope(
            onWillPop: () async =>
                weekModeSnapshot.data == WeekplanMode.guardian,
            child: Scaffold(
              appBar: GirafAppBar(
                title: _user.displayName + ' - ' + _week.name,
                appBarIcons: (weekModeSnapshot.data == WeekplanMode.guardian)
                    ? <AppBarIcon, VoidCallback>{
                        AppBarIcon.edit: () => _weekplanBloc.toggleEditMode(),
                        AppBarIcon.changeToCitizen: () {},
                        AppBarIcon.logout: () {},
                      }
                    : <AppBarIcon, VoidCallback>{
                        AppBarIcon.changeToGuardian: () {}
                      },
                isGuardian: weekModeSnapshot.data == WeekplanMode.guardian,
              ),
              body: StreamBuilder<UserWeekModel>(
                stream: _weekplanBloc.userWeek,
                initialData: null,
                builder: (BuildContext context,
                    AsyncSnapshot<UserWeekModel> snapshot) {
                  if (snapshot.hasData) {
                    return _buildWeeks(snapshot.data.week, context);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              bottomNavigationBar: StreamBuilder<WeekplanMode>(
                stream: _authBloc.mode,
                initialData: WeekplanMode.guardian,
                builder: (BuildContext context,
                    AsyncSnapshot<WeekplanMode> snapshot) {
                  return Visibility(
                    visible: snapshot.data == WeekplanMode.guardian,
                    child: StreamBuilder<bool>(
                      stream: _weekplanBloc.editMode,
                      initialData: false,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.data) {
                          return buildBottomAppBar(context);
                        } else {
                          return Container(width: 0.0, height: 0.0);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  /// Builds the BottomAppBar when in edit mode
  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Expanded(
              child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: <double>[
                        1 / 3,
                        2 / 3
                      ],
                          colors: <Color>[
                        theme.GirafColors.appBarYellow,
                        theme.GirafColors.appBarOrange,
                      ])),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      BottomAppBarButton(
                          buttonText: 'Aflys',
                          buttonKey: 'CancelActivtiesButton',
                          assetPath: 'assets/icons/cancel.png',
                          isEnabled: false,
                          isEnabledStream:
                              _weekplanBloc.atLeastOneActivityMarked,
                          dialogFunction: _buildCancelDialog),
                      BottomAppBarButton(
                          buttonText: 'Kopier',
                          buttonKey: 'CopyActivtiesButton',
                          assetPath: 'assets/icons/copy.png',
                          isEnabled: false,
                          isEnabledStream:
                              _weekplanBloc.atLeastOneActivityMarked,
                          dialogFunction: _buildCopyDialog),
                      BottomAppBarButton(
                          buttonText: 'Slet',
                          buttonKey: 'DeleteActivtiesButton',
                          assetPath: 'assets/icons/delete.png',
                          isEnabled: false,
                          isEnabledStream:
                              _weekplanBloc.atLeastOneActivityMarked,
                          dialogFunction: _buildRemoveDialog)
                    ],
                  )))
        ]));
  }

  void _copyActivities(List<bool> days, BuildContext context) {
    _weekplanBloc.copyMarkedActivities(days);
    Routes.pop(context);
    _weekplanBloc.toggleEditMode();
  }

  Future<Center> _buildCopyDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafCopyActivitiesDialog(
            title: 'Kopier aktiviteter',
            description: 'Vælg hvilke dage de markerede aktiviteter skal '
                'kopieres til',
            confirmButtonText: 'Kopier',
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/copy.png')),
            confirmOnPressed: _copyActivities,
          );
        });
  }

  /// Builds the dialog box to confirm marking activities as canceled
  Future<Center> _buildCancelDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Aflys aktiviteter',
              description: 'Vil du markere ' +
                  _weekplanBloc.getNumberOfMarkedActivities().toString() +
                  ' aktivitet(er) som aflyst',
              confirmButtonText: 'Bekræft',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/accept.png')),
              confirmOnPressed: () {
                _weekplanBloc.cancelMarkedActivities();
                _weekplanBloc.toggleEditMode();

                // Closes the dialog box
                Routes.pop(context);
              });
        });
  }

  /// Builds dialog box to confirm/cancel deletion
  Future<Center> _buildRemoveDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Slet aktiviteter',
              description: 'Vil du slette ' +
                  _weekplanBloc.getNumberOfMarkedActivities().toString() +
                  ' aktivitet(er)',
              confirmButtonText: 'Slet',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/delete.png')),
              confirmOnPressed: () {
                _weekplanBloc.deleteMarkedActivities();
                _weekplanBloc.toggleEditMode();

                // Closes the dialog box
                Routes.pop(context);
              });
        });
  }

  StreamBuilder<WeekplanMode> _buildWeeks(
      WeekModel weekModel, BuildContext context) {
    const List<Color> defaultWeekColors = <Color>[
      theme.GirafColors.mondayColor,
      theme.GirafColors.tuesdayColor,
      theme.GirafColors.wednesdayColor,
      theme.GirafColors.thursdayColor,
      theme.GirafColors.fridayColor,
      theme.GirafColors.saturdayColor,
      theme.GirafColors.sundayColor
    ];
    final List<Widget> weekDays = <Widget>[];

    final int _weekday = DateTime.now().weekday.toInt();
    int _weekdayCounter = 0;

    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext context,
            AsyncSnapshot<WeekplanMode> weekModeSnapshot) {
          if (weekModeSnapshot.hasData) {
            final WeekplanMode role = weekModeSnapshot.data;

            if (role == WeekplanMode.guardian) {
              weekDays.clear();
              for (int i = 0; i < weekModel.days.length; i++) {
                weekDays.add(Expanded(
                    child: Card(
                        color: defaultWeekColors[i],
                        child: _day(weekModel.days[i], context))));
              }
              return Row(children: weekDays);
            } else if (role == WeekplanMode.citizen) {
              return StreamBuilder<SettingsModel>(
                stream: _settingsBloc.settings,
                builder: (BuildContext context,
                    AsyncSnapshot<SettingsModel> settingsSnapshot) {
                  if (settingsSnapshot.hasData) {
                    final SettingsModel _settingsModel = settingsSnapshot.data;
                    final int _daysToDisplay = _settingsModel.nrOfDaysToDisplay;

                    // If the option of showing 1 day is chosen the
                    // _weekdayCounter must start from today's date
                    if (_daysToDisplay == 1) {
                      _weekdayCounter = _weekday - 1; // monday = 0, sunday = 6
                    }
                    // Adding the selected number of days to weekDays
                    weekDays.clear();
                    for (int i = 0; i < _daysToDisplay; i++) {
                      // Get color from the citizen's chosen color theme
                      final String dayColor = _settingsModel.weekDayColors
                          .where((WeekdayColorModel w) =>
                              w.day == Weekday.values[_weekdayCounter])
                          .single
                          .hexColor
                          .replaceFirst('#', '0xff');
                      weekDays.add(Expanded(
                          child: Card(
                              color: Color(int.parse(dayColor)),
                              child: _day(
                                  weekModel.days[_weekdayCounter], context))));
                      if (_weekdayCounter == 6) {
                        _weekdayCounter = 0;
                      } else {
                        _weekdayCounter += 1;
                      }
                    }
                  }
                  if (weekDays.length == 1) {
                    return Row(
                      key: const Key('SingleWeekdayRow'),
                      children: <Widget>[
                        const Spacer(flex: 2),
                        weekDays.first,
                        const Spacer(flex: 2),
                      ],
                    );
                  } else {
                    return Row(children: weekDays);
                  }
                },
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Row(children: weekDays);
        });
  }

  Column _day(WeekdayModel weekday, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _translateWeekDay(weekday.day),
        buildDaySelectorButtons(context, weekday),
        buildDayActivities(weekday.activities, weekday),
        Container(
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
                      child: RaisedButton(
                          key: const Key('AddActivityButton'),
                          child: Image.asset('assets/icons/add.png'),
                          color: theme.GirafColors.buttonColor,
                          onPressed: () async {
                            final PictogramModel newActivity =
                                await Routes.push(context, PictogramSearch());
                            if (newActivity != null) {
                              _weekplanBloc.addActivity(
                                  ActivityModel(
                                      id: newActivity.id,
                                      pictogram: newActivity,
                                      order: weekday.activities.length,
                                      state: ActivityState.Active,
                                      isChoiceBoard: false),
                                  weekday.day.index);
                            }
                          }),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  ///Builds the selector buttons day
  Container buildDaySelectorButtons(
      BuildContext context, WeekdayModel weekDay) {
    return Container(
        child: StreamBuilder<WeekplanMode>(
      stream: _authBloc.mode,
      initialData: WeekplanMode.guardian,
      builder: (BuildContext context, AsyncSnapshot<WeekplanMode> snapshot) {
        return Visibility(
          visible: snapshot.data == WeekplanMode.guardian,
          child: StreamBuilder<bool>(
            stream: _weekplanBloc.editMode,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data) {
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
    for (ActivityModel activity in weekdayModel.activities) {
      if (_weekplanBloc.isActivityMarked(activity) == false) {
        _weekplanBloc.addMarkedActivity(activity);
      }
    }
  }

  /// Unmarks all activities for a given day
  void unmarkAllDayActivities(WeekdayModel weekdayModel) {
    for (ActivityModel activity in weekdayModel.activities) {
      if (_weekplanBloc.isActivityMarked(activity) == true) {
        _weekplanBloc.removeMarkedActivity(activity);
      }
    }
  }

  /// Builds a day's activities
  StreamBuilder<List<ActivityModel>> buildDayActivities(
      List<ActivityModel> activities, WeekdayModel weekday) {
    return StreamBuilder<List<ActivityModel>>(
        stream: _weekplanBloc.markedActivities,
        builder: (BuildContext context,
            AsyncSnapshot<List<ActivityModel>> markedActivities) {
          return StreamBuilder<bool>(
              initialData: false,
              stream: _weekplanBloc.editMode,
              builder:
                  (BuildContext context, AsyncSnapshot<bool> editModeSnapshot) {
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      if (index == weekday.activities.length) {
                        return StreamBuilder<bool>(
                            stream: _weekplanBloc.activityPlaceholderVisible,
                            initialData: false,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return Visibility(
                                key: const Key('GreyDragVisibleKey'),
                                visible: snapshot.data,
                                child: _dragTargetPlaceholder(index, weekday),
                              );
                            });
                      } else {
                        return StreamBuilder<WeekplanMode>(
                            stream: _authBloc.mode,
                            initialData: WeekplanMode.guardian,
                            builder: (BuildContext context,
                                AsyncSnapshot<WeekplanMode> snapshot) {
                              if (snapshot.data == WeekplanMode.guardian) {
                                return _dragTargetPictogram(
                                    index, weekday, editModeSnapshot.data);
                              }
                              return _pictogramIconStack(context, index,
                                  weekday, editModeSnapshot.data);
                            });
                      }
                    },
                    itemCount: weekday.activities.length + 1,
                  ),
                );
              });
        });
  }

  /// Handles tap on an activity
  void handleOnTapActivity(bool inEditMode, bool isMarked, bool isCitizen,
      List<ActivityModel> activities, int index, Weekday weekDay,
      BuildContext context) {
    if (inEditMode) {
      if (isMarked) {
        _weekplanBloc.removeMarkedActivity(activities[index]);
      } else {
        _weekplanBloc.addMarkedActivity(activities[index]);
      }
    } else if (!(activities[index].state == ActivityState.Completed &&
        isCitizen)) {
      Routes.push(context, ShowActivityScreen(activities[index], _week, weekDay,
          _user));
    }
  }

  /// Builds activity card with a status icon if it is marked
  StatelessWidget buildIsMarked(bool isMarked, BuildContext context,
      WeekdayModel weekday, List<ActivityModel> activities, int index) {
    if (isMarked) {
      return Container(
          key: const Key('isSelectedKey'),
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width * 0.1)),
          child: _buildActivityCard(
            context,
            activities,
            index,
            weekday,
            activities[index].state,
          ));
    } else {
      return _buildActivityCard(
          context, activities, index, weekday, activities[index].state);
    }
  }

  // Returns the grayed out drag targets in the end of the columns.
  DragTarget<Tuple2<ActivityModel, Weekday>> _dragTargetPlaceholder(
      int dropTargetIndex, WeekdayModel weekday) {
    return DragTarget<Tuple2<ActivityModel, Weekday>>(
      key: const Key('DragTargetPlaceholder'),
      builder: (BuildContext context,
          List<Tuple2<ActivityModel, Weekday>> candidateData,
          List<dynamic> rejectedData) {
        return const AspectRatio(
          aspectRatio: 1,
          child: Card(
            color: theme.GirafColors.dragShadow,
            child: ListTile(),
          ),
        );
      },
      onWillAccept: (Tuple2<ActivityModel, Weekday> data) {
        // Draggable can be dropped on every drop target
        return true;
      },
      onAccept: (Tuple2<ActivityModel, Weekday> data) {
        _weekplanBloc.reorderActivities(
            data.item1, data.item2, weekday.day, dropTargetIndex);
      },
    );
  }

  // Returns the draggable pictograms, which also function as drop targets.
  DragTarget<Tuple2<ActivityModel, Weekday>> _dragTargetPictogram(
      int index, WeekdayModel weekday, bool inEditMode) {
    return DragTarget<Tuple2<ActivityModel, Weekday>>(
      key: const Key('DragTarget'),
      builder: (BuildContext context,
          List<Tuple2<ActivityModel, Weekday>> candidateData,
          List<dynamic> rejectedData) {
        return LongPressDraggable<Tuple2<ActivityModel, Weekday>>(
          data: Tuple2<ActivityModel, Weekday>(
              weekday.activities[index], weekday.day),
          dragAnchor: DragAnchor.pointer,
          child: _pictogramIconStack(context, index, weekday, inEditMode),
          childWhenDragging: Opacity(
              opacity: 0.5,
              child: _pictogramIconStack(context, index, weekday, inEditMode)),
          onDragStarted: () =>
              _weekplanBloc.setActivityPlaceholderVisible(true),
          onDragCompleted: () =>
              _weekplanBloc.setActivityPlaceholderVisible(false),
          onDragEnd: (DraggableDetails details) =>
              _weekplanBloc.setActivityPlaceholderVisible(false),
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
      onWillAccept: (Tuple2<ActivityModel, Weekday> data) {
        // Draggable can be dropped on every drop target
        return true;
      },
      onAccept: (Tuple2<ActivityModel, Weekday> data) {
        _weekplanBloc.reorderActivities(
            data.item1, data.item2, weekday.day, index);
      },
    );
  }

  // Returning a widget that stacks a pictogram and an status icon
  FittedBox _pictogramIconStack(
      BuildContext context, int index, WeekdayModel weekday, bool inEditMode) {
    final bool isMarked =
        _weekplanBloc.isActivityMarked(weekday.activities[index]);

    return FittedBox(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          StreamBuilder<WeekplanMode>(
              stream: _authBloc.mode,
              initialData: WeekplanMode.guardian,
              builder: (BuildContext context,
                  AsyncSnapshot<WeekplanMode> modeSnapshot) {
                return StreamBuilder<SettingsModel>(
                    stream: _settingsBloc.settings,
                    builder: (BuildContext context,
                        AsyncSnapshot<SettingsModel> settingsSnapshot) {
                      if (settingsSnapshot.hasData && modeSnapshot.hasData) {
                        double _width = 1;
                        final int _daysToDisplay =
                            settingsSnapshot.data.nrOfDaysToDisplay;

                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait) {
                          if (modeSnapshot.data == WeekplanMode.citizen) {
                            if (_daysToDisplay == 1) {
                              _width = 1;
                            }
                          }
                        } else if (MediaQuery.of(context).orientation ==
                            Orientation.landscape) {
                          if (modeSnapshot.data == WeekplanMode.citizen) {
                            if (_daysToDisplay == 1) {
                              _width = 1;
                            }
                          }
                        }
                        return SizedBox(
                            // MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / _width,
                            //  MediaQuery.of(context).size.width / 1,
                            child: Container(
                              child: GestureDetector(
                                key: Key(weekday.day.index.toString() +
                                    weekday.activities[index].id.toString()),
                                onTap: () {
                                  if (modeSnapshot.data ==
                                      WeekplanMode.guardian) {
                                    handleOnTapActivity(
                                        inEditMode,
                                        isMarked,
                                        false,
                                        weekday.activities,
                                        index,
                                        weekday.day,
                                        context);
                                  } else {
                                    handleOnTapActivity(false, false, true,
                                        weekday.activities, index, weekday.day,
                                        context);
                                  }
                                },
                                child:
                                    (modeSnapshot.data == WeekplanMode.guardian)
                                        ? buildIsMarked(isMarked, context,
                                            weekday, weekday.activities, index)
                                        : buildIsMarked(false, context, weekday,
                                            weekday.activities, index),
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

  Widget _getPictogram(ActivityModel activity) {
    final PictogramImageBloc bloc = di.getDependency<PictogramImageBloc>();
    bloc.loadPictogramById(activity.pictogram.id);
    return StreamBuilder<Image>(
      stream: bloc.image,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.data == null) {
          return const CircularProgressIndicator();
        }
        return Container(
            child: snapshot.data, key: const Key('PictogramImage'));
      },
    );
  }

  /// Builds card that displays the activity
  Container _buildActivityCard(
    BuildContext context,
    List<ActivityModel> activities,
    int index,
    WeekdayModel weekday,
    ActivityState activityState,
  ) {
    return Container(
        color: theme.GirafColors.white,
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      child: _getPictogram(activities[index]),
                    ),
                  ),
                  _buildActivityStateIcon(context, activityState, weekday),
                  _buildTimerIcon(context, activities[index]),
                ],
              ),
              PictogramText(activities[index].pictogram, _user),
            ],
          ),
        ));
  }

  /// Creates a cover for a completed activity, if choosing to not display them
  Container completedActivityColor(Color dayColor, BuildContext context) {
    return Container(
        color: dayColor,
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width);
  }

  /// Build activity state icon.
  Widget _buildActivityStateIcon(
      BuildContext context, ActivityState state, WeekdayModel weekday) {
    switch (state) {
      case ActivityState.Completed:
        return StreamBuilder<WeekplanMode>(
            stream: _authBloc.mode,
            builder: (BuildContext context,
                AsyncSnapshot<WeekplanMode> weekModeSnapshot) {
              if (weekModeSnapshot.hasData) {
                final WeekplanMode role = weekModeSnapshot.data;

                if (role == WeekplanMode.guardian) {
                  return Icon(
                    Icons.check,
                    key: const Key('IconComplete'),
                    color: theme.GirafColors.green,
                    size: MediaQuery.of(context).size.width,
                  );
                } else if (role == WeekplanMode.citizen) {
                  return StreamBuilder<SettingsModel>(
                      stream: _settingsBloc.settings,
                      builder: (BuildContext context,
                          AsyncSnapshot<SettingsModel> snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data.completeMark == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.data.completeMark ==
                            CompleteMark.Checkmark) {
                          return Icon(
                            Icons.check,
                            key: const Key('IconComplete'),
                            color: theme.GirafColors.green,
                            size: MediaQuery.of(context).size.width,
                          );
                        } else if (snapshot.data.completeMark ==
                            CompleteMark.MovedRight) {
                          return completedActivityColor(
                              theme.GirafColors.transparentGrey, context);
                        } else if (snapshot.data.completeMark ==
                            CompleteMark.Removed) {
                          return StreamBuilder<SettingsModel>(
                            stream: _settingsBloc.settings,
                            builder: (BuildContext buildContext,
                                AsyncSnapshot<SettingsModel> settingsSnapshot) {
                              Color c;

                              if (settingsSnapshot.data == null) {
                                c = Color(int.parse(
                                    WeekplanColorTheme.blueWhiteColorSetting()[
                                            weekday.day.index]
                                        .hexColor
                                        .replaceFirst('#', '0xff')));
                              } else {
                                c = Color(int.parse(settingsSnapshot.data
                                    .weekDayColors[weekday.day.index].hexColor
                                    .replaceFirst('#', '0xff')));
                              }

                              return completedActivityColor(c, context);
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });

      case ActivityState.Canceled:
        return Icon(
          Icons.clear,
          key: const Key('IconCanceled'),
          color: theme.GirafColors.red,
          size: MediaQuery.of(context).size.width,
        );
      default:
        return Container();
    }
  }

  /// Builds timer icon depending on activity has timer.
  Widget _buildTimerIcon(BuildContext context, ActivityModel activity) {
    final TimerBloc timerBloc = di.getDependency<TimerBloc>();
    timerBloc.load(activity, user: _user);
    return StreamBuilder<bool>(
        stream: timerBloc.timerIsInstantiated,
        builder:
            (BuildContext streamContext, AsyncSnapshot<bool> timerSnapshot) {
          if (timerSnapshot.hasData && timerSnapshot.data) {
            // Activities that are not overlayed.
            if (activity.state != ActivityState.Completed) {
              return _buildTimerAssetIcon();
            }
            // Activities that are overlayed.
            return StreamBuilder<WeekplanMode>(
                stream: _authBloc.mode,
                builder: (BuildContext roleContext,
                    AsyncSnapshot<WeekplanMode> role) {
                  if (role.data == WeekplanMode.guardian) {
                    return const ImageIcon(
                      AssetImage('assets/icons/redcircle.png'),
                      color: theme.GirafColors.red,
                      size: 250,
                    );
                  } else {
                    return StreamBuilder<SettingsModel>(
                        stream: _settingsBloc.settings,
                        builder: (BuildContext settingsContext,
                            AsyncSnapshot<SettingsModel> settings) {
                          if (!settings.hasData ||
                              settings.data.completeMark !=
                                  CompleteMark.Removed) {
                            return const ImageIcon(
                              AssetImage('assets/icons/redcircle.png'),
                              color: theme.GirafColors.red,
                              size: 250,
                            );
                          }

                          return Container();
                        });
                  }
                });
          }
          return Container();
        });
  }

  /// Build timer icon.
  ImageIcon _buildTimerAssetIcon() {
    return const ImageIcon(
      AssetImage('assets/icons/redcircle.png'),
      color: theme.GirafColors.red,
      size: 250,
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
        title: AutoSizeText(
          translation,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
