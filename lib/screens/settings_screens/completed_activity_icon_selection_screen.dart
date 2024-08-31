import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_checkboxButton.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_item.dart';

import '../../di.dart';

/// Screen where the icon for completed activity can be chosen
class CompletedActivityIconScreen extends StatelessWidget {
  /// Constructor
  CompletedActivityIconScreen(DisplayNameModel user) : _user = user {
    _settingsBloc.loadSettings(_user);
  }

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
                final SettingsModel _settingsModel = settingsSnapshot.data!;

                return ListView(
                  children: <Widget>[
                    SettingsSection('Tegn for udførelse', <SettingsSectionItem>[
                      SettingsCheckMarkButton(0, _settingsModel.completeMark,
                          'Fjern aktiviteten for borgeren', () {
                        Routes().pop(context, CompleteMark.Removed);
                      }),
                      SettingsCheckMarkButton(
                          1, _settingsModel.completeMark, 'Flueben', () {
                        Routes().pop(context, CompleteMark.Checkmark);
                      }),
                      SettingsCheckMarkButton(
                          2, _settingsModel.completeMark, 'Lav aktiviteten grå',
                          () {
                        Routes().pop(context, CompleteMark.MovedRight);
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
}
