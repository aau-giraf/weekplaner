import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/timer_running_mode.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';
import 'package:weekplanner/widgets/timer_widgets/timer_piechart.dart';

import '../../di.dart';
import '../../style/custom_color.dart' as theme;

/// Widget used for activities in the weekplan screen.
class ActivityCard extends StatelessWidget {
  /// Constructor
  ActivityCard(this._activity, this._timerBloc, this._user) {
    _settingsBloc.loadSettings(_user);
  }

  final ActivityModel _activity;
  final TimerBloc _timerBloc;
  final DisplayNameModel _user;
  final AuthBloc _authBloc = di.get<AuthBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WeekplanMode>(
        stream: _authBloc.mode,
        builder: (BuildContext context,
            AsyncSnapshot<WeekplanMode> weekModeSnapshot) {
          return StreamBuilder<SettingsModel?>(
              stream: _settingsBloc.settings,
              builder: (BuildContext context,
                  AsyncSnapshot<SettingsModel?> settingsSnapshot) {
                return _buildActivityCard(
                    context, weekModeSnapshot, settingsSnapshot);
              });
        });
  }

  Widget _buildActivityCard(
      BuildContext context,
      AsyncSnapshot<WeekplanMode> weekModeSnapShot,
      AsyncSnapshot<SettingsModel?> settingsSnapShot) {
    final ActivityState? _activityState = _activity.state;
    if (!_activity.isChoiceBoard) {
      return Opacity(
        opacity: _shouldActivityBeVisible(weekModeSnapShot, settingsSnapShot)
            ? 1.0
            : 0,
        child: Container(
            color: theme.GirafColors.white,
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            child: FittedBox(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            child: FittedBox(
                              child: _getPictogram(_activity.pictograms.first),
                            ),
                          ),
                          _buildActivityStateIcon(context, _activityState!,
                              weekModeSnapShot, settingsSnapShot),
                          _buildTimerIcon(context, _activity),
                        ],
                      ),
                      Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: <Widget>[
                          _buildAvatarIcon(context),
                        ],
                      ),
                    ],
                  ),
                  PictogramText(_activity, _user),
                ],
              ),
            )),
      );
    } else {
      return buildChoiceBoardActivityCard(
          context, weekModeSnapShot, settingsSnapShot);
    }
  }

  bool _shouldActivityBeVisible(AsyncSnapshot<WeekplanMode> weekModeSnapShot,
      AsyncSnapshot<SettingsModel?> settingsSnapShot) {
    if (weekModeSnapShot.hasData && settingsSnapShot.hasData) {
      final WeekplanMode? weekMode = weekModeSnapShot.data;
      final SettingsModel? settings = settingsSnapShot.data;
      if (weekMode == WeekplanMode.citizen &&
          settings!.completeMark == CompleteMark.Removed &&
          _activity.state == ActivityState.Completed) {
        return false;
      }
    }
    return true;
  }

  ///This function builds the activity card
  Widget buildChoiceBoardActivityCard(
      BuildContext context,
      AsyncSnapshot<WeekplanMode> weekModeSnapShot,
      AsyncSnapshot<SettingsModel?> settingsSnapShot) {
    // Check for nullability before accessing data in settingsSnapshot
    if (!settingsSnapShot.hasData || settingsSnapShot.data == null) {
      return Container();
    }
    final ActivityState _activityState = _activity.state;
    final List<Widget> pictograms = <Widget>[];
    // Access non-nullable SettingsModel

    for (int i = 0; i < _activity.pictograms.length; i++) {
      pictograms.add(
        SizedBox.expand(
          child: FittedBox(child: _getPictogram(_activity.pictograms[i])),
        ),
      );
    }
    // Check if there is more than one activity in the choiceboard
    final bool multipleActivities =
        _activity.pictograms.length > 1 && _activity.isChoiceBoard;
    return Container(
      decoration: BoxDecoration(
        color: theme.GirafColors.white,
        border: Border.all(
          color: Colors.black,
          width: MediaQuery.of(context).size.width * 0.01,
        ),
      ),
      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: FittedBox(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      child: FittedBox(
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            SizedBox(
                              key: const Key('WeekPlanScreenChoiceBoard'),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              child: returnGridView(pictograms),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildActivityStateIcon(
                        context,
                        _activityState,
                        weekModeSnapShot,
                        settingsSnapShot),
                    _buildTimerIcon(context, _activity),
                  ],
                ),
                // Remove avatar icon if there are multiple activities in the
                // choiceboard
                multipleActivities == false
                    ? Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: <Widget>[
                    _buildAvatarIcon(context),
                  ],
                )
                    : Container(),
              ],
            ),
            PictogramText(_activity, _user),
          ],
        ),
      ),
    );
  }


  ///Returns the correct gridview
  Center returnGridView(List<Widget> list) {
    return Center(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        children: List<Widget>.generate(
          list.length,
          (int index) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.black,
                  width: 5,
                )),
                child: list[index],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getPictogram(PictogramModel _pictogram) {
    final PictogramImageBloc bloc = di.get<PictogramImageBloc>();
    bloc.loadPictogramById(_pictogram.id);
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

  Widget _buildActivityStateIcon(
      BuildContext context,
      ActivityState? state,
      AsyncSnapshot<WeekplanMode> weekModeSnapShot,
      AsyncSnapshot<SettingsModel?> settingsSnapShot) {
    return StreamBuilder<TimerRunningMode>(
        stream: _timerBloc.timerRunningMode,
        builder:
            (BuildContext context, AsyncSnapshot<TimerRunningMode> snapshot1) {
          if (weekModeSnapShot.hasData && settingsSnapShot.hasData) {
            final WeekplanMode? role = weekModeSnapShot.data;
            final SettingsModel? settings = settingsSnapShot.data;

            switch (state) {
              case ActivityState.Normal:
                if (snapshot1.hasData &&
                    snapshot1.data != TimerRunningMode.running) {
                  break;
                }
                return Container(
                    child: TimerPiechart(_timerBloc),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height);
              case ActivityState.Completed:
                if (role == WeekplanMode.guardian) {
                  return Icon(
                    Icons.check,
                    key: const Key('IconComplete'),
                    color: theme.GirafColors.green,
                    size: MediaQuery.of(context).size.width,
                  );
                } else if (role == WeekplanMode.citizen) {
                  if (settings!.completeMark == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (settings.completeMark == CompleteMark.Checkmark) {
                    return Icon(
                      Icons.check,
                      key: const Key('IconComplete'),
                      color: theme.GirafColors.green,
                      size: MediaQuery.of(context).size.width,
                    );
                  } else if (settings.completeMark == CompleteMark.MovedRight) {
                    return Container(
                        key: const Key('GreyOutBox'),
                        color: theme.GirafColors.transparentGrey,
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width);
                  } else if (settings.completeMark == CompleteMark.Removed) {
                    //This case should be handled by _shouldActivityBeVisiblei
                    return Container(
                      width: 0,
                      height: 0,
                    );
                  }
                }

                return const Center(child: CircularProgressIndicator());
              case ActivityState.Canceled:
                return Icon(
                  Icons.clear,
                  key: const Key('IconCanceled'),
                  color: theme.GirafColors.red,
                  size: MediaQuery.of(context).size.width,
                );
              case ActivityState.Active:
                if (role == WeekplanMode.guardian ||
                    role == WeekplanMode.trustee) {
                  return Icon(
                    Icons.brightness_1_outlined,
                    key: const Key('IconActive'),
                    color: theme.GirafColors.amber,
                    size: MediaQuery.of(context).size.width,
                  );
                }
                if (role == WeekplanMode.citizen &&
                    settings!.nrOfActivitiesToDisplay! > 1) {
                  return Icon(
                    Icons.brightness_1_outlined,
                    key: const Key('IconActive'),
                    color: theme.GirafColors.amber,
                    size: MediaQuery.of(context).size.width,
                  );
                } else {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }

              default:
                return Container(
                  width: 0,
                  height: 0,
                );
            }
          }
          //If no settings/role have been loaded then we just make an empty overlay
          return Container(
            width: 0,
            height: 0,
          );
        });
  }

  Widget _buildTimerIcon(BuildContext context, ActivityModel activity) {
    final TimerBloc timerBloc = di.get<TimerBloc>();
    timerBloc.load(activity, user: _user);
    return StreamBuilder<bool>(
        stream: timerBloc.timerIsInstantiated,
        builder:
            (BuildContext streamContext, AsyncSnapshot<bool> timerSnapshot) {
          if (timerSnapshot.hasData && timerSnapshot.data!) {
            return _buildTimerAssetIcon();
          }
          return Container();
        });
  }

  /// Build timer icon.
  Widget _buildTimerAssetIcon() {
    return StreamBuilder<SettingsModel?>(
        stream: _settingsBloc.settings,
        builder: (BuildContext context,
            AsyncSnapshot<SettingsModel?> settingsSnapshot) {
          late String _iconPath;

          if (settingsSnapshot.hasData) {
            if (settingsSnapshot.data!.defaultTimer == DefaultTimer.PieChart) {
              _iconPath = 'assets/timer/piechart_icon.png';
            } else if (settingsSnapshot.data!.defaultTimer ==
                DefaultTimer.Hourglass) {
              _iconPath = 'assets/timer/hourglass_icon.png';
            } else if (settingsSnapshot.data!.defaultTimer ==
                DefaultTimer.Numeric) {
              _iconPath = 'assets/timer/countdowntimer_icon.png';
            }
          } else {
            return const CircularProgressIndicator();
          }
          return Image(
            image: AssetImage(_iconPath),
            height: 250,
            width: 250,
          );
        });
  }

  Widget _buildAvatarIcon(BuildContext context) {
    return Container(
        width: 400,
        height: 400,
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
          child: const CircleAvatar(
              key: Key('PlaceholderAvatar'),
              radius: 20,
              backgroundImage:
                  AssetImage('assets/login_screen_background_image.png')),
        ));
  }
}
