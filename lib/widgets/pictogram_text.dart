import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/style/font_size.dart';

/// This is a widget used to create text under the pictograms
class PictogramText extends StatelessWidget {
  /// Constructor
  PictogramText(this._activity, this._user, {this.minFontSize = 100}) {
    _settingsBloc.loadSettings(_user);
  }

  final ActivityModel _activity;
  final DisplayNameModel _user;

  /// The settings bloc which we get the settings from, you need to make sure
  /// you have loaded settings into it before hand otherwise text is never build
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();

  /// The authentication bloc that we get the current mode from (guardian/citizen)
  final AuthBloc _authBloc = di.get<AuthBloc>();

  /// Determines the minimum font size that text can scale down to
  final double minFontSize;

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
                if (settingsSnapshot.hasData && weekModeSnapshot.hasData) {
                  final WeekplanMode weekMode = weekModeSnapshot.data!;
                  final SettingsModel settings = settingsSnapshot.data!;
                  final bool pictogramTextIsEnabled = settings.pictogramText!;
                  if ((_isGuardianMode(weekMode) || pictogramTextIsEnabled) &&
                      settings.pictogramText == true) {
                    if (_activity.isChoiceBoard) {
                      return _buildPictogramText(
                          context, _activity.choiceBoardName!);
                    } else {
                      final String pictogramText = _activity.title!;
                      return _buildPictogramText(context, pictogramText);
                    }
                  }
                }
                return Container(width: 0, height: 0);
              });
        });
  }

  bool _isGuardianMode(WeekplanMode weekMode) {
    return weekMode == WeekplanMode.guardian;
  }

  SizedBox _buildPictogramText(BuildContext context, String pictogramText) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: null,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: AutoSizeText(
            pictogramText[0].toUpperCase() +
                pictogramText.substring(1).toLowerCase(),
            minFontSize: minFontSize,
            maxLines: textLines(pictogramText, context),
            textAlign: TextAlign.center,
            // creates a ... postfix if text overflows
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: GirafFont.pictogram),
          ),
        ));
  }
}

/// Try to calculate the actual size of the text, with the size of the screen
/// accounted for
double textWidth(String text, BuildContext context) {
  return (TextPainter(
          text: TextSpan(
              text: text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 120)),
          maxLines: 1,
          textScaler: MediaQuery.textScalerOf(context),
          textDirection: TextDirection.ltr)
        ..layout())
      .size
      .width;
}

/// Counts the amount of words by splitting by the spaces and count the result
/// if theres only 1 word then max lines is 1 else the max lines is 2
int textLines(String pictogramText, BuildContext context) {
  if (pictogramText.split(RegExp('\\s+')).length > 1) {
    return 2;
  } else {
    if (textWidth(pictogramText, context) >=
        MediaQuery.of(context).size.width) {
      return 2;
    } else {
      return 1;
    }
  }
}
