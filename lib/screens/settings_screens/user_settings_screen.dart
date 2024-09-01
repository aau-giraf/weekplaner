import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/settings_screens/change_password_screen.dart';
import 'package:weekplanner/screens/settings_screens/change_username_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_arrow_button.dart';
import 'package:weekplanner/widgets/settings_widgets/'
    'settings_section_item.dart';

import '../../di.dart';

/// Shows all the Guardian and Trustee users settings, and lets them change them
class UserSettingsScreen extends StatelessWidget {
  final ChooseCitizenBloc _cBloc = di.get<ChooseCitizenBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(title: 'Indstillinger', key: UniqueKey()),
        body: _buildAllSettings(context));
  }

  Widget _buildAllSettings(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildUserSettings(),
      ],
    );
  }

  Widget _buildUserSettings() {
    return StreamBuilder<GirafUserModel>(
        stream: _cBloc.guardian,
        builder:
            (BuildContext context, AsyncSnapshot<GirafUserModel> snapshot) {
          if (snapshot.hasData) {
            print('Snapshot has Girafuser: ' + snapshot.data!.username!);
            final DisplayNameModel user =
                DisplayNameModel.fromGirafUser(snapshot.data!);
            return SettingsSection(
                snapshot.data!.username! + ' - skift personlig information',
                <SettingsSectionItem>[
                  SettingsArrowButton('Skift brugernavn', () {
                    Routes().push(context, ChangeUsernameScreen(user));
                  }),
                  SettingsArrowButton('Skift kodeord', () {
                    Routes().push(context, ChangePasswordScreen(user));
                  }),
                ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
