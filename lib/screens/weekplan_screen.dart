// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'package:api_client/api/api_exception.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_color_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/user_week_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/settings_screens/settings_screen.dart';
import 'package:weekplanner/widgets/bottom_app_bar_button_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_copy_activities_dialog.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import 'package:weekplanner/widgets/weekplan_screen_widgets/weekplan_activities_column.dart';
import 'package:weekplanner/widgets/weekplan_screen_widgets/weekplan_day_column.dart';

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
  WeekplanScreen(this._week, this._user, {required Key key}) : super(key: key) {
    _weekplanBloc.getWeek(_week, _user);
    _settingsBloc.loadSettings(_user);
  }

  final WeekplanBloc _weekplanBloc = di.get<WeekplanBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();
  final AuthBloc _authBloc = di.get<AuthBloc>();
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
          return StreamBuilder<SettingsModel?>(
              stream: _settingsBloc.settings,
              builder: (BuildContext context,
                  AsyncSnapshot<SettingsModel?> settingsSnapshot) {
                if (settingsSnapshot.hasData) {
                  final SettingsModel? _settingsModel = settingsSnapshot.data;
                  return PopScope(
                    child: Scaffold(
                      appBar: GirafAppBar(
                        key: const ValueKey<String>('settings'),
                        title: _user.displayName! + ' - ' + _week.name!,
                        appBarIcons: (weekModeSnapshot.data ==
                                WeekplanMode.guardian)
                            ? <AppBarIcon, VoidCallback>{
                                // Show icons for guardian role
                                AppBarIcon.edit: () =>
                                    _weekplanBloc.toggleEditMode(),
                                AppBarIcon.changeToCitizen: () {},
                                AppBarIcon.settings: () => Routes()
                                    .push<WeekModel>(
                                        context, SettingsScreen(_user))
                                    .then((WeekModel? newWeek) =>
                                        _settingsBloc.loadSettings(_user)),
                                AppBarIcon.logout: () {}
                              }
                            : (weekModeSnapshot.data == WeekplanMode.trustee)
                                ? <AppBarIcon, VoidCallback>{
                                    // Show icons for trustee role
                                    AppBarIcon.edit: () =>
                                        _weekplanBloc.toggleEditMode(),
                                    AppBarIcon.changeToCitizen: () {},
                                    AppBarIcon.settings: () => Routes()
                                        .push<WeekModel>(
                                            context, SettingsScreen(_user))
                                        .then((WeekModel? newWeek) =>
                                            _settingsBloc.loadSettings(_user)),
                                    AppBarIcon.logout: () {}
                                  }
                                : (weekModeSnapshot.data ==
                                            WeekplanMode.citizen &&
                                        _settingsModel!
                                                .showSettingsForCitizen ==
                                            true)
                                    ? <AppBarIcon, VoidCallback>{
                                        AppBarIcon.changeToGuardian: () {},
                                        AppBarIcon.settings: () => Routes()
                                            .push<WeekModel>(
                                                context, SettingsScreen(_user))
                                            .then((WeekModel? newWeek) =>
                                                _settingsBloc
                                                    .loadSettings(_user)),
                                        AppBarIcon.logout: () {}
                                      }
                                    : <AppBarIcon, VoidCallback>{
                                        // Show icons for citizen role
                                        AppBarIcon.changeToGuardian: () {},
                                        AppBarIcon.logout: () {},
                                      },
                      ),
                      body: StreamBuilder<UserWeekModel>(
                        stream: _weekplanBloc.userWeek,
                        initialData: null,
                        builder: (BuildContext context,
                            AsyncSnapshot<UserWeekModel> snapshot) {
                          if (snapshot.hasData) {
                            return _buildWeeks(snapshot.data!.week, context);
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
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                if (snapshot.data!) {
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
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
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
                        buttonText: 'Genoptag',
                        buttonKey: 'GenoptagActivtiesButton',
                        assetPath: 'assets/icons/undo.png',
                        isEnabled: false,
                        isEnabledStream: _weekplanBloc.atLeastOneActivityMarked,
                        dialogFunction: _buildUndoDialog,
                        key: UniqueKey(),
                      ),
                      BottomAppBarButton(
                        buttonText: 'Aflys',
                        buttonKey: 'CancelActivtiesButton',
                        assetPath: 'assets/icons/cancel.png',
                        isEnabled: false,
                        isEnabledStream: _weekplanBloc.atLeastOneActivityMarked,
                        dialogFunction: _buildCancelDialog,
                        key: UniqueKey(),
                      ),
                      BottomAppBarButton(
                        buttonText: 'Kopier',
                        buttonKey: 'CopyActivtiesButton',
                        assetPath: 'assets/icons/copy.png',
                        isEnabled: false,
                        isEnabledStream: _weekplanBloc.atLeastOneActivityMarked,
                        dialogFunction: _buildCopyDialog,
                        key: UniqueKey(),
                      ),
                      BottomAppBarButton(
                        buttonText: 'Slet',
                        buttonKey: 'DeleteActivtiesButton',
                        assetPath: 'assets/icons/delete.png',
                        isEnabled: false,
                        isEnabledStream: _weekplanBloc.atLeastOneActivityMarked,
                        dialogFunction: _buildRemoveDialog,
                        key: UniqueKey(),
                      )
                    ],
                  )))
        ]));
  }

  void _copyActivities(List<bool> days, BuildContext context) {
    _weekplanBloc.copyMarkedActivities(days).catchError((Object error) {
      buildErrorDialog(context, error);
    });
    Routes().pop(context);
    _weekplanBloc.toggleEditMode();
  }

  Future<Center?> _buildCopyDialog(BuildContext context) {
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
            key: const ValueKey<String>('weekplanKey'),
          );
        });
  }

  /// Builds the dialog box to confirm marking activities as canceled
  Future<Center?> _buildCancelDialog(BuildContext context) {
    return showDialog<Center>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GirafConfirmDialog(
            title: 'Aflys aktiviteter',
            description: 'Vil du markere ' +
                _weekplanBloc.getNumberOfMarkedActivities().toString() +
                '${_weekplanBloc.getNumberOfMarkedActivities() == 1 ? ' aktivitet' : ' aktiviteter'} som aflyst?',
            confirmButtonText: 'Bekræft',
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/accept.png')),
            confirmOnPressed: () {
              _weekplanBloc.cancelMarkedActivities().catchError((Object error) {
                buildErrorDialog(context, error);
              });
              _weekplanBloc.toggleEditMode();

              // Closes the dialog box
              Routes().pop(context);
            },
            key: UniqueKey());
      },
    );
  }

  Future<Center?> _buildUndoDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Genoptag',
              description: 'Vil du genoptage ' +
                  _weekplanBloc.getNumberOfMarkedActivities().toString() +
                  '${_weekplanBloc.getNumberOfMarkedActivities() == 1 ? ' aktivitet' : ' aktiviteter'}?',
              confirmButtonText: 'Genoptag',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/undo.png')),
              confirmOnPressed: () {
                _weekplanBloc.undoMarkedActivities().catchError((Object error) {
                  buildErrorDialog(context, error);
                });
                _weekplanBloc.toggleEditMode();

                // Closes the dialog box
                Routes().pop(context);
              },
              key: UniqueKey());
        });
  }

  /// Builds dialog box to confirm/cancel deletion
  Future<Center?> _buildRemoveDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Slet aktiviteter',
              description: 'Vil du slette ' +
                  _weekplanBloc.getNumberOfMarkedActivities().toString() +
                  '${_weekplanBloc.getNumberOfMarkedActivities() == 1 ? ' aktivitet' : ' aktiviteter'}?',
              confirmButtonText: 'Slet',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/delete.png')),
              confirmOnPressed: () {
                _weekplanBloc
                    .deleteMarkedActivities()
                    .catchError((Object error) {
                  buildErrorDialog(context, error);
                });
                _weekplanBloc.toggleEditMode();

                // Closes the dialog box
                Routes().pop(context);
              },
              key: UniqueKey());
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
    final Orientation orientation = MediaQuery.of(context).orientation;
    final int _weekday = DateTime.now().weekday - 1; // monday = 0, sunday = 6

    final List<Widget> dailyActivities = <Widget>[];
    int _weekdayCounter = 0;

    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext context,
            AsyncSnapshot<WeekplanMode> weekModeSnapshot) {
          if (weekModeSnapshot.hasData) {
            final WeekplanMode? role = weekModeSnapshot.data;

            if (role == WeekplanMode.guardian) {
              _weekplanBloc.clearWeekdayStreams();
              _weekplanBloc.setDaysToDisplay(7, 0);

              for (int i = 0; i < weekModel.days!.length; i++) {
                addDayToWeek(weekDays, i, defaultWeekColors[i]);
              }
              return Row(children: weekDays);
            } else if (role == WeekplanMode.citizen) {
              return StreamBuilder<SettingsModel?>(
                stream: _settingsBloc.settings,
                builder: (BuildContext context,
                    AsyncSnapshot<SettingsModel?> settingsSnapshot) {
                  if (settingsSnapshot.hasData) {
                    final SettingsModel? _settingsModel = settingsSnapshot.data;
                    late int _daysToDisplay;
                    late bool _displayDaysRelative;
                    if (orientation == Orientation.portrait) {
                      _daysToDisplay =
                          _settingsModel!.nrOfDaysToDisplayPortrait!;
                      _displayDaysRelative =
                          _settingsModel.displayDaysRelativePortrait!;
                    } else if (orientation == Orientation.landscape) {
                      _daysToDisplay =
                          _settingsModel!.nrOfDaysToDisplayLandscape!;
                      _displayDaysRelative =
                          _settingsModel.displayDaysRelativeLandscape!;
                    }
                    final int? _activitiesToDisplay =
                        _settingsModel!.nrOfActivitiesToDisplay;
                    // If the option of showing 1 or 2 days is chosen the
                    // _weekdayCounter must start from today's date
                    if (_displayDaysRelative) {
                      _weekdayCounter = _weekday;
                    } else {
                      //otherwise it starts from monday
                      _weekdayCounter = 0;
                    }
                    // Adding the selected number of days to weekDays
                    _weekplanBloc.clearWeekdayStreams();
                    _weekplanBloc.setDaysToDisplay(
                        _daysToDisplay, _weekdayCounter);
                    for (int i = 0;
                        i < _daysToDisplay;
                        i++, _weekdayCounter++) {
                      // Get color from the citizen's chosen color theme
                      final String dayColor = _settingsModel.weekDayColors!
                          .where((WeekdayColorModel w) =>
                              w.day == Weekday.values[_weekdayCounter])
                          .single
                          .hexColor!
                          .replaceFirst('#', '0xff');
                      addDayToWeek(weekDays, i, Color(int.parse(dayColor)));
                      if (_daysToDisplay == 2 && _weekdayCounter == 6) {
                        break;
                        /* If the user wants two days to display
                         * and today is sunday then it only shows one day
                         */
                      }
                    }
                    if (_settingsModel.showOnlyActivities == false) {
                      if (weekDays.length == 1) {
                        return Row(
                          key: const Key('SingleWeekdayRow'),
                          children: <Widget>[
                            const Spacer(flex: 1),
                            weekDays.first,
                            const Spacer(flex: 1),
                          ],
                        );
                      } else {
                        return Row(children: weekDays);
                      }
                    } else {
                      final int today = DateTime.now().weekday - 1;
                      dailyActivities.add(Expanded(
                          child: WeekplanActivitiesColumn(
                        dayOfTheWeek: Weekday.values[today],
                        color: Colors.amber,
                        weekplanBloc: _weekplanBloc,
                        user: _user,
                        streamIndex: today,
                        activitiesToDisplay: _activitiesToDisplay!,
                      )));
                      return Row(
                        key: const Key('SingleWeekdayRow'),
                        children: <Widget>[
                          const Spacer(flex: 1),
                          dailyActivities.first,
                          const Spacer(flex: 1),
                        ],
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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

  /// Function that creates the notify dialog,
  void buildErrorDialog(BuildContext context, Object error) {
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

  /// adds a single day to a week based on the specific day
  /// and the specified color
  void addDayToWeek(List<Widget> weekDays, int nthDayToAdd, Color dayColor) {
    weekDays.add(Expanded(
        child: WeekplanDayColumn(
      color: dayColor,
      weekplanBloc: _weekplanBloc,
      user: _user,
      streamIndex: nthDayToAdd,
    )));
    _weekplanBloc.addWeekdayStream();
  }
}
