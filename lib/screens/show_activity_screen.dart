import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/default_timer_enum.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/settings_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/exceptions/custom_exceptions.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/enums/timer_running_mode.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/choiceboard_widgets/choice_board.dart';
import 'package:weekplanner/widgets/citizen_avatar_widget.dart';
import 'package:weekplanner/widgets/giraf_activity_time_picker_dialog.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';
import 'package:weekplanner/widgets/timer_widgets/timer_countdown.dart';
import 'package:weekplanner/widgets/timer_widgets/timer_hourglass.dart';
import 'package:weekplanner/widgets/timer_widgets/timer_piechart.dart';

import '../style/custom_color.dart' as theme;

/// Screen to show information about an activity, and change the state of it.
class ShowActivityScreen extends StatelessWidget {
  /// Constructor
  ShowActivityScreen(this._activity, this._girafUser, this._weekplanBloc,
      this._timerBloc, this._weekday,
      {required Key key})
      : super(key: key) {
    _pictoImageBloc.load(_activity.pictograms.first);
    _activityBloc.load(_activity, _girafUser);
    _activityBloc.accesWeekPlanBloc(_weekplanBloc, _weekday);
    _settingsBloc.loadSettings(_girafUser);
    _timerBloc.load(_activity, user: _girafUser);
    _timerBloc.setActivityBloc(_activityBloc);
    _timerBloc.addHandlerToRunningModeOnce();

    _activityBloc.addHandlerToActivityStateOnce();
  }

  final DisplayNameModel _girafUser;
  final ActivityModel _activity;

  final PictogramImageBloc _pictoImageBloc = di.get<PictogramImageBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();
  final ActivityBloc _activityBloc = di.get<ActivityBloc>();
  final AuthBloc _authBloc = di.get<AuthBloc>();
  final TimerBloc _timerBloc;

  final WeekplanBloc _weekplanBloc;
  final WeekdayModel _weekday;

  /// Textfield controller
  final TextEditingController tec = TextEditingController();

  /// Text style used for title.
  final TextStyle titleTextStyle =
      const TextStyle(fontSize: GirafFont.activity_screen_buttons);

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    _timerBloc.initTimer();

    ///Used to check if the keyboard is visible
    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext context, AsyncSnapshot<WeekplanMode> snapshot) {
          return buildScreenFromOrientation(
              orientation, context, snapshot.data);
        });
  }

  /// Build the activity screens in a row or column
  /// depending on the orientation of the device.
  Scaffold buildScreenFromOrientation(
      Orientation orientation, BuildContext context, WeekplanMode? mode) {
    late Widget childContainer;

    mode ??= WeekplanMode.citizen;

    try {
      if (orientation == Orientation.portrait) {
        childContainer = Column(
          children: buildScreen(context, mode),
        );
      } else if (orientation == Orientation.landscape) {
        childContainer = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buildScreen(context, mode),
        );
      }
    } catch (err) {
      throw OrientationException(
          'Something is wrong with the screen orientation'
          '\n Error: ',
          err.toString());
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: GirafAppBar(
          title: 'Aktivitet',
          appBarIcons: (mode == WeekplanMode.guardian)
              ? <AppBarIcon, VoidCallback>{AppBarIcon.changeToCitizen: () {}}
              : <AppBarIcon, VoidCallback>{AppBarIcon.changeToGuardian: () {}},
          key: UniqueKey(),
        ),
        body: childContainer);
  }

  /// Builds the activity.
  List<Widget> buildScreen(BuildContext context, WeekplanMode mode) {
    final List<Widget> list = <Widget>[];
    list.add(
      Expanded(
        flex: 2,
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: buildActivity(context),
          ),
        ),
      ),
    );

    // All the buttons excluding the activity itself
    final List<Widget> buttons = <Widget>[];
    buttons.add(Container(
        margin: const EdgeInsets.all(10),
        width: 120,
        height: 120,
        child: CitizenAvatar(
          displaynameModel: _girafUser,
        )));
    buttons.add(
      StreamBuilder<ActivityModel>(
          stream: _activityBloc.activityModelStream,
          builder: (BuildContext context,
              AsyncSnapshot<ActivityModel> activitySnapshot) {
            return (activitySnapshot.hasData &&
                    (activitySnapshot.data!.state == ActivityState.Canceled ||
                        activitySnapshot.data!.state ==
                            ActivityState.Completed))
                ? _resetTimerAndBuildEmptyContainer()
                : _buildTimer(context);
          }),
    );

    buttons.add(StreamBuilder<ActivityModel>(
        stream: _activityBloc.activityModelStream,
        builder: (BuildContext context,
            AsyncSnapshot<ActivityModel> activitySnapshot) {
          return StreamBuilder<WeekplanMode>(
              stream: _authBloc.mode,
              builder: (BuildContext context,
                  AsyncSnapshot<WeekplanMode> authSnapshot) {
                if (authSnapshot.hasData &&
                    activitySnapshot.hasData &&
                    authSnapshot.data != WeekplanMode.citizen &&
                    (activitySnapshot.data!.state != ActivityState.Canceled &&
                        activitySnapshot.data!.state !=
                            ActivityState.Completed)) {
                  return _buildChoiceBoardButton(context);
                } else {
                  return _buildEmptyContainer();
                }
              });
        }));

    final Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      list.add(Expanded(
        child: Column(
          children: buttons,
        ),
      ));
    } else if (orientation == Orientation.portrait) {
      list.add(
        Expanded(
          child: Row(
            children: buttons,
          ),
        ),
      );
    }

    return list;
  }

  Container _resetTimerAndBuildEmptyContainer() {
    _timerBloc.stopTimer();
    return Container(width: 0, height: 0);
  }

  Container _buildEmptyContainer() {
    return Container(
      width: 0,
      height: 0,
    );
  }

  /// Builds the AddChoiceBoardButton widget.
  StreamBuilder<WeekplanMode> _buildChoiceBoardButton(BuildContext context) {
    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext modeContext,
            AsyncSnapshot<WeekplanMode> modeSnapshot) {
          return Expanded(
            flex: 4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    key: const Key('AddChoiceBoardButtonKey'),
                    child: InkWell(
                      onTap: () async {
                        await Routes()
                            .push(
                                context,
                                PictogramSearch(
                                  user: _girafUser,
                                ))
                            .then((Object? object) {
                          if (object is PictogramModel) {
                            _activityBloc.load(_activity, _girafUser);
                            final PictogramModel newPictogram = object;
                            _activity.isChoiceBoard = true;
                            _activity.pictograms.add(newPictogram);
                            _activityBloc.update();
                          }
                        });
                      },
                      child: Column(children: <Widget>[
                        // The title of the choiceBoard widget
                        Center(
                            key: const Key('ChoiceboardTitleKey'),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: StreamBuilder<ActivityModel>(
                                  stream: _activityBloc.activityModelStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<ActivityModel>
                                          activitySnapshot) {
                                    return const Text('Tilføj valgmulighed',
                                        textAlign: TextAlign.center);
                                  }),
                            )),
                        const Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: FittedBox(
                              child: Icon(
                                Icons.add,
                                color: theme.GirafColors.black,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  /// Builds the timer widget.
  StreamBuilder<WeekplanMode> _buildTimer(BuildContext overallContext) {
    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext modeContext,
            AsyncSnapshot<WeekplanMode> modeSnapshot) {
          return StreamBuilder<bool>(
              stream: _timerBloc.timerIsInstantiated,
              builder: (BuildContext timerInitContext,
                  AsyncSnapshot<bool> timerInitSnapshot) {
                // If a timer is not initiated, and the app is in citizen mode,
                // nothing is shown
                return Visibility(
                  visible: (timerInitSnapshot.hasData && modeSnapshot.hasData)
                      ? timerInitSnapshot.data! ||
                          (!timerInitSnapshot.data! &&
                              modeSnapshot.data == WeekplanMode.guardian)
                      : false,
                  child: Expanded(
                    flex: 4,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Card(
                            child: Material(
                              child: InkWell(
                                key: const Key('OverallTimerBoxKey'),
                                onTap: () {
                                  //Build timer dialog on
                                  //tap if timer has no data
                                  if (!timerInitSnapshot.data!) {
                                    _buildTimerDialog(overallContext);
                                  }
                                },
                                //hide splash/highlight color when timer exists
                                highlightColor: timerInitSnapshot.data ==
                                            null ||
                                        !timerInitSnapshot.data!
                                    ? Theme.of(overallContext).highlightColor
                                    : Colors.transparent,
                                splashColor: timerInitSnapshot.data == null ||
                                        !timerInitSnapshot.data!
                                    ? Theme.of(overallContext).splashColor
                                    : Colors.transparent,
                                child: Column(children: <Widget>[
                                  // The title of the timer widget
                                  const Center(
                                      key: Key('TimerTitleKey'),
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text('Timer',
                                            textAlign: TextAlign.center),
                                      )),
                                  Expanded(
                                      // Depending on whether
                                      // a timer is initiated,
                                      // different widgets are shown.
                                      child: (timerInitSnapshot.hasData
                                              ? timerInitSnapshot.data!
                                              : false)
                                          ? _timerIsInitiatedWidget()
                                          : _timerIsNotInitiatedWidget(
                                              overallContext, modeSnapshot)),
                                  _timerButtons(overallContext,
                                      timerInitSnapshot, modeSnapshot)
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  /// Button style for the choice board
  final ButtonStyle choiceBoardStyle = ElevatedButton.styleFrom(
    backgroundColor: theme.GirafColors.gradientDefaultOrange,
    disabledForegroundColor:
        theme.GirafColors.gradientDisabledOrange.withOpacity(0.38),
    disabledBackgroundColor:
        theme.GirafColors.gradientDisabledOrange.withOpacity(0.12),
    padding: const EdgeInsets.all(10.0),
  );

  /// Builds the activity widget.
  Card buildActivity(BuildContext context) {
    String inputtext = _activity.choiceBoardName!;
    return Card(
        child: Column(children: <Widget>[
      const Center(child: Padding(padding: EdgeInsets.all(20.0))),
      Visibility(
        visible: _activity.isChoiceBoard,
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                key: const Key('ChoiceBoardNameText'),
                initialValue: _activity.choiceBoardName == ' '
                    ? ''
                    : _activity.choiceBoardName,
                textAlign: TextAlign.center,
                onChanged: (String text) {
                  inputtext = text.isNotEmpty ? text : ' ';
                  _activity.choiceBoardName = text;
                },
                onFieldSubmitted: (String text) {
                  _activity.choiceBoardName = inputtext;
                  _activityBloc.update();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              style: choiceBoardStyle,
              key: const Key('ChoiceBoardNameButton'),
              onPressed: () {
                _activity.choiceBoardName = inputtext;
                _activityBloc.update();
              },
              child:
                  const Text('Godkend', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      Expanded(
        child: FittedBox(
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.GirafColors.blueBorderColor, width: 0.25)),
                child: StreamBuilder<ActivityModel>(
                    stream: _activityBloc.activityModelStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<ActivityModel> snapshot1) {
                      return StreamBuilder<TimerRunningMode>(
                          stream: _timerBloc.timerRunningMode,
                          builder: (BuildContext context,
                              AsyncSnapshot<TimerRunningMode> snapshot2) {
                            if (snapshot1.data == null) {
                              return const CircularProgressIndicator();
                            }
                            return Column(
                              children: <Widget>[
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width,
                                        child: _activity.isChoiceBoard
                                            ? ChoiceBoard(_activity,
                                                _activityBloc, _girafUser)
                                            : buildLoadPictogramImage()),
                                    _buildActivityStateIcon(context,
                                        snapshot1.data!.state, snapshot2.data!),
                                  ],
                                ),
                                Visibility(
                                  visible: !_activity.isChoiceBoard,
                                  child: PictogramText(_activity, _girafUser,
                                      minFontSize: 50),
                                ),
                              ],
                            );
                          });
                    }))),
      ),
      buildButtonBar(),
      _activityBloc.getActivity().isChoiceBoard
          ? Container()
          : buildInputField(context)
    ]));
  }

  /// The widget to show, in the case that a timer has been initiated,
  /// showing the progression for the timer in both citizen and guardian mode.
  Widget _timerIsInitiatedWidget() {
    return StreamBuilder<SettingsModel?>(
        stream: _settingsBloc.settings,
        builder: (BuildContext context,
            AsyncSnapshot<SettingsModel?> settingsSnapshot) {
          late Widget _returnWidget;

          if (settingsSnapshot.hasData) {
            if (settingsSnapshot.data!.defaultTimer == DefaultTimer.PieChart) {
              _returnWidget = TimerPiechart(_timerBloc);
            } else if (settingsSnapshot.data!.defaultTimer ==
                DefaultTimer.Hourglass) {
              _returnWidget = TimerHourglass(_timerBloc);
            } else if (settingsSnapshot.data!.defaultTimer ==
                DefaultTimer.Numeric) {
              _returnWidget = TimerCountdown(_timerBloc);
            }
          } else {
            _returnWidget = const CircularProgressIndicator();
          }

          return _returnWidget;
        });
  }

  /// The widget to show, in the case that a timer has not been initiated
  /// for the activity. When in guardian mode, an "addTimer" button is shown,
  /// as citizen, nothing is shown.
  Widget _timerIsNotInitiatedWidget(
      BuildContext overallContext, AsyncSnapshot<WeekplanMode> modeSnapshot) {
    return (modeSnapshot.hasData
            ? (modeSnapshot.data == WeekplanMode.guardian)
            : false)
        ? FittedBox(
            key: const Key('TimerNotInitGuardianKey'),
            child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: const ImageIcon(
                      AssetImage('assets/icons/addTimerHighRes.png')),
                  key: const Key('AddTimerButtonKey'),
                )))
        : Container(
            key: const Key('TimerNotInitCitizenKey'),
          );
  }

  /// The buttons for the timer. Depending on whether the application is in
  /// citizen or guardian mode, certain buttons are displayed.
  /// Buttons are: Play/Pause, Stop and Delete
  Widget _timerButtons(
      BuildContext overallContext,
      AsyncSnapshot<bool> timerInitSnapshot,
      AsyncSnapshot<WeekplanMode> modeSnapshot) {
    return StreamBuilder<SettingsModel?>(
      stream: _settingsBloc.settings,
      builder: (BuildContext timerButtonsContext,
          AsyncSnapshot<SettingsModel?> settingsSnapshot) {
        return Visibility(
          visible: timerInitSnapshot.hasData ? timerInitSnapshot.data! : false,
          key: const Key('TimerOverallButtonVisibilityKey'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Row(
                key: const Key('TimerButtonRow'),
                children: <Widget>[
                  _playPauseButton(overallContext, timerInitSnapshot,
                      modeSnapshot, settingsSnapshot),
                  _stopButton(overallContext, timerInitSnapshot, modeSnapshot,
                      settingsSnapshot),
                  _deleteButton(overallContext, timerInitSnapshot, modeSnapshot,
                      settingsSnapshot),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _playPauseButton(
      BuildContext overallContext,
      AsyncSnapshot<bool> timerInitSnapshot,
      AsyncSnapshot<WeekplanMode> modeSnapshot,
      AsyncSnapshot<SettingsModel?> settingsSnapshot) {
    return StreamBuilder<TimerRunningMode>(
        stream: _timerBloc.timerRunningMode,
        builder: (BuildContext timerRunningContext,
            AsyncSnapshot<TimerRunningMode> timerRunningSnapshot) {
          return Visibility(
            visible: modeSnapshot.data == WeekplanMode.guardian ||
                ((settingsSnapshot.hasData &&
                        !settingsSnapshot.data!.lockTimerControl!)
                    ? true
                    : (timerRunningSnapshot.hasData &&
                        (timerRunningSnapshot.data ==
                            TimerRunningMode.initialized))),
            child: Flexible(
              // Button has different icons and press logic
              // depending on whether the timer is running.
              child: GirafButton(
                key: (timerRunningSnapshot.hasData
                        ? timerRunningSnapshot.data == TimerRunningMode.running
                        : false)
                    ? const Key('TimerPauseButtonKey')
                    : const Key('TimerPlayButtonKey'),
                onPressed: () {
                  if (!timerRunningSnapshot.hasData) {
                    throw Exception('Error');
                  }
                  switch (timerRunningSnapshot.data) {
                    case TimerRunningMode.initialized:
                    case TimerRunningMode.stopped:
                    case TimerRunningMode.paused:
                      {
                        _timerBloc.playTimer();
                        break;
                      }
                    case TimerRunningMode.running:
                      {
                        _timerBloc.pauseTimer();
                        break;
                      }
                    case TimerRunningMode.not_initialized:
                      {
                        break;
                      }
                    case TimerRunningMode.completed:
                      {
                        _timerBloc.stopTimer();
                        break;
                      }
                    default:
                      break;
                  }
                },
                icon: (timerRunningSnapshot.hasData
                        ? timerRunningSnapshot.data == TimerRunningMode.running
                        : false)
                    ? const ImageIcon(AssetImage('assets/icons/pause.png'))
                    : const ImageIcon(AssetImage('assets/icons/play.png')),
              ),
            ),
          );
        });
  }

  Widget _stopButton(
      BuildContext overallContext,
      AsyncSnapshot<bool> timerInitSnapshot,
      AsyncSnapshot<WeekplanMode> modeSnapshot,
      AsyncSnapshot<SettingsModel?> settingsSnapshot) {
    return Visibility(
      visible: modeSnapshot.data == WeekplanMode.guardian ||
          (settingsSnapshot.hasData &&
              !settingsSnapshot.data!.lockTimerControl!),
      child: Flexible(
        child: GirafButton(
          key: const Key('TimerStopButtonKey'),
          onPressed: () {
            // Directly perform actions without showing the confirmation dialog
            _timerBloc.stopTimer();
            _showToast('Timeren er blevet stoppet.');
          },
          icon: const ImageIcon(AssetImage('assets/icons/stop.png')),
        ),
      ),
    );
  }

  // Give message after stopping timer
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  Widget _deleteButton(
      BuildContext overallContext,
      AsyncSnapshot<bool> timerInitSnapshot,
      AsyncSnapshot<WeekplanMode> modeSnapshot,
      AsyncSnapshot<SettingsModel?> settingsSnapshot) {
    return Visibility(
      // The delete button is only visible when in guardian mode,
      // since a citizen should not be able to delete the timer.
      visible: modeSnapshot.data == WeekplanMode.guardian,
      child: Flexible(
        child: GirafButton(
          key: const Key('TimerDeleteButtonKey'),
          onPressed: () {
            showDialog<Center>(
                context: overallContext,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  // A confirmation dialog is
                  // shown to delete the timer.
                  return GirafConfirmDialog(
                    key: const Key('TimerDeleteConfirmDialogKey'),
                    title: 'Slet timer',
                    description: 'Vil du slette timeren?',
                    confirmButtonText: 'Slet',
                    confirmButtonIcon:
                        const ImageIcon(AssetImage('assets/icons/delete.png')),
                    confirmOnPressed: () {
                      _timerBloc.deleteTimer();
                      Routes().pop(context);
                    },
                  );
                });
          },
          icon: const ImageIcon(AssetImage('assets/icons/delete.png')),
        ),
      ),
    );
  }

  /// Returns a dialog where time can be decided for an activity(timer)
  void _buildTimerDialog(BuildContext context) {
    showDialog<Center>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GirafActivityTimerPickerDialog(
            _activity,
            _timerBloc,
            key: UniqueKey(),
          );
        });
  }

  /// Builds the button that changes the state of the activity. The content
  /// of the button depends on whether it is in guardian or citizen mode.
  ButtonBar buildButtonBar() {
    return ButtonBar(
      // Key used for testing widget.
      key: const Key('ButtonBarRender'),
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<WeekplanMode>(
          stream: _authBloc.mode,
          builder: (BuildContext context,
              AsyncSnapshot<WeekplanMode> weekplanModeSnapshot) {
            return StreamBuilder<ActivityModel>(
              stream: _activityBloc.activityModelStream,
              builder: (BuildContext context,
                  AsyncSnapshot<ActivityModel> activitySnapshot) {
                if (activitySnapshot.data == null) {
                  return const CircularProgressIndicator();
                }

                ActivityState activityState = activitySnapshot.data!.state;
                final bool isComplete = activityState != ActivityState.Canceled;
                final bool isCanceled =
                    activityState != ActivityState.Completed;

                final bool showCancelButton =
                    weekplanModeSnapshot.data == WeekplanMode.guardian &&
                        isCanceled;
                final bool showCompleteButton = isComplete;

                final GirafButton completeButton = GirafButton(
                  key: const Key('CompleteStateToggleButton'),
                  onPressed: showCompleteButton
                      ? () {
                          _activityBloc.completeActivity();
                          activityState = _activityBloc.getActivity().state;
                        }
                      : null,
                  text: isCanceled ? 'Afslut' : 'Fortryd',
                  icon: isCanceled
                      ? const ImageIcon(
                          AssetImage('assets/icons/accept.png'),
                          color: theme.GirafColors.green,
                        )
                      : const ImageIcon(
                          AssetImage('assets/icons/undo.png'),
                          color: theme.GirafColors.blue,
                        ),
                );

                final GirafButton cancelButton = GirafButton(
                  key: const Key('CancelStateToggleButton'),
                  onPressed: showCancelButton
                      ? () {
                          _activityBloc.cancelActivity();
                          activityState = _activityBloc.getActivity().state;
                        }
                      : null,
                  text: isComplete ? 'Aflys' : 'Fortryd',
                  icon: isComplete
                      ? const ImageIcon(
                          AssetImage('assets/icons/cancel.png'),
                          color: theme.GirafColors.red,
                        )
                      : const ImageIcon(
                          AssetImage('assets/icons/undo.png'),
                          color: theme.GirafColors.blue,
                        ),
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: showCompleteButton,
                      child: completeButton,
                    ),
                    const SizedBox(width: 15),
                    Visibility(
                      visible: showCancelButton,
                      child: cancelButton,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Builds the input field and buttons for changing the description of
  /// the pictogram for a specific citizen
  Column buildInputField(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder<WeekplanMode>(
            stream: _authBloc.mode,
            builder: (BuildContext context,
                AsyncSnapshot<WeekplanMode> weekplanModeSnapshot) {
              return StreamBuilder<ActivityModel>(
                  stream: _activityBloc.activityModelStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<ActivityModel> activitySnapshot) {
                    if (activitySnapshot.data == null) {
                      return const CircularProgressIndicator();
                    }
                    if (weekplanModeSnapshot.data == WeekplanMode.guardian) {
                      return Container(
                          child: Column(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 20, 30),
                            child: TextField(
                              key: const Key('AlternateNameTextField'),
                              controller: tec,
                              style: const TextStyle(
                                  fontSize: 28,
                                  height: 1.3,
                                  color: theme.GirafColors.black),
                              decoration: InputDecoration(
                                  hintText: _activity.title,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GirafButton(
                            key: const Key('SavePictogramTextForCitizenBtn'),
                            onPressed: () {
                              _activityBloc.setAlternateName(tec.text);
                            },
                            text: 'Gem til borger',
                          ),
                        ),
                        GirafButton(
                          key: const Key(
                              'GetStandardPictogramTextForCitizenBtn'),
                          onPressed: () {
                            _activityBloc.getStandardTitle();
                          },
                          text: 'Hent standard',
                        )
                      ]));
                    } else {
                      return Container();
                    }
                  });
            }),
      ],
    );
  }

  /// Creates a pictogram image from the streambuilder
  Widget buildLoadPictogramImage() {
    _pictoImageBloc.load(_activityBloc.getActivity().pictograms.first);
    return StreamBuilder<Image>(
      stream: _pictoImageBloc.image,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        return FittedBox(
            child: Container(
              child: snapshot.data,
            ),
            // Key is used for testing the widget.
            key: Key(_activity.id.toString()));
      },
    );
  }

  /// Builds the icon that displays the activity's state
  Stack _buildActivityStateIcon(
      BuildContext context, ActivityState state, TimerRunningMode timemode) {
    if (state == ActivityState.Completed ||
        TimerRunningMode.completed == timemode) {
      return Stack(children: <Widget>[
        Container(
          child: Icon(
            Icons.check,
            key: const Key('IconComplete'),
            color: theme.GirafColors.green,
            size: MediaQuery.of(context).size.width,
          ),
        ),
        Container(
          child: ImageIcon(
            const AssetImage('assets/icons/gallery.png'),
            key: const Key('IconCompletedBorder'),
            color: theme.GirafColors.green,
            size: MediaQuery.of(context).size.width,
          ),
        )
      ]);
    } else if (state == ActivityState.Canceled) {
      return Stack(children: <Widget>[
        Container(
          child: ImageIcon(
            const AssetImage('assets/icons/bigCancelBorder.png'),
            key: const Key('IconCanceledBorder'),
            color: theme.GirafColors.black,
            size: MediaQuery.of(context).size.width,
          ),
        ),
        Container(
          child: ImageIcon(
            const AssetImage('assets/icons/bigCancel.png'),
            key: const Key('IconCanceled'),
            color: theme.GirafColors.red,
            size: MediaQuery.of(context).size.width,
          ),
        ),
      ]);
    } else {
      return Stack(children: <Widget>[Container()]);
    }
  }
}
