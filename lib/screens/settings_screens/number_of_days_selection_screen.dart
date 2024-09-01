// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_checkboxButton.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_item.dart';

import '../../di.dart';
import '../../routes.dart';

/// Screen where the user can select how many days to show for a citizen
/// This class is used for both the settings screen for portrait mode and for
/// landscape mode
class NumberOfDaysScreen extends StatelessWidget {
  /// Constructor
  NumberOfDaysScreen(
      DisplayNameModel user, bool isPortrait, SettingsModel? settingsModel)
      : _user = user {
    // Determines whether this settings screen is the one for portrait mode or
    // the one for landscape mode
    _isPortrait = isPortrait;
    _settingsModel = settingsModel;
    _settingsBloc.loadSettings(_user);
  }
  late SettingsModel? _settingsModel;
  late bool _isPortrait;
  final DisplayNameModel _user;

  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
            title: _user.displayName! + ': indstillinger', key: UniqueKey()),
        body: StreamBuilder<SettingsModel?>(
            stream: _settingsBloc.settings,
            builder: (BuildContext context,
                AsyncSnapshot<SettingsModel?> settingsSnapshot) {
              if (settingsSnapshot.hasData) {
                final int? _numberOfDaysToDisplay = _isPortrait
                    ? _settingsModel!.nrOfDaysToDisplayPortrait
                    : _settingsModel!.nrOfDaysToDisplayLandscape;

                return ListView(
                  children: <Widget>[
                    SettingsSection(
                        'Antal dage der vises når enheden er på langs',
                        <SettingsSectionItem>[
                          SettingsCheckMarkButton(
                              1, _numberOfDaysToDisplay, 'Vis i dag', () {
                            setDisplayDaysRelative(_settingsModel!, true);
                            Routes().pop(context, 1);
                          }),
                          SettingsCheckMarkButton(
                              2, _numberOfDaysToDisplay, 'Vis to dage', () {
                            setDisplayDaysRelative(_settingsModel!, true);
                            Routes().pop(context, 2);
                          }),
                          SettingsCheckMarkButton(5, _numberOfDaysToDisplay,
                              'Vis mandag til fredag', () {
                            setDisplayDaysRelative(_settingsModel!, false);
                            Routes().pop(context, 5);
                          }),
                          SettingsCheckMarkButton(7, _numberOfDaysToDisplay,
                              'Vis mandag til søndag', () {
                            setDisplayDaysRelative(_settingsModel!, false);
                            Routes().pop(context, 7);
                          }),
                        ]),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  /// Sets whether the number of days should be displayed relative to the
  /// current day
  void setDisplayDaysRelative(SettingsModel settingsModel, bool isRelative) {
    _isPortrait
        ? settingsModel.displayDaysRelativePortrait = isRelative
        : settingsModel.displayDaysRelativeLandscape = isRelative;
  }
}
