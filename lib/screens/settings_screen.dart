import 'package:api_client/models/username_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/style/custom_color.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';

/// Shows all the users settings, and lets them change them
class SettingsScreen extends StatelessWidget {
  /// Constructor
  const SettingsScreen(UsernameModel user) : _user = user;

  final UsernameModel _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(title: 'Indstillinger'),
        appBar: GirafAppBar(title: 'Indstillinger'),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _buildAllSettings(),
            )
          ],
        ));
  }

  Widget _buildAllSettings() {
    return ListView(
      children: <Widget>[
        _buildThemeSection(),
        _buildOrientationSection(),
        _buildWeekPlanSection(),
        _buildUserSettings()
      ],
    );
  }

  /// Fix later. Must use bloc instead
  int daysToDisplay = 1;

  Widget _buildNumberOfDaysSection() {
    return ListView(children: <Widget>[
      const Text('Ugeplan visning'),
      ExpansionTile(
        key: const PageStorageKey<int>(3),
        title: const Text('Vælg visning'),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: const Text('Vis kun nuværende dag'),
                onPressed: () {
                  daysToDisplay = 1;
                },
              ),
              RaisedButton(
                child: const Text('Vis Man-Fre'),
                onPressed: () {
                  daysToDisplay = 5;
                },
              ),
              RaisedButton(
                child: const Text('Vis Man-Søn'),
                onPressed: () {
                  daysToDisplay = 7;
                },
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  // Not used in the current version (from 2019)
  Widget _buildThemeSection() {
    return Column(children: <Widget>[
      const ListTile(
        title: Text('Tema',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            )),
      ),
      SizedBox(
          width: double.infinity, child: _button(() {}, 'Farver på ugeplan')),
      SizedBox(
        width: double.infinity,
        child: _button(() {}, 'Tegn for udførelse'),
      )
    ]);
  }

  Widget _buildOrientationSection() {
    return Column(
      children: <Widget>[
        const ListTile(
          title: Text('Orientering',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              )),
        ),
        Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey[350])),
          child: CheckboxListTile(
            value: true,
            title: const Text('Landskab'),
            onChanged: (bool value) {},
          ),
        )
      ],
    );
  }

  Widget _buildWeekPlanSection() {
    return Column(
      children: <Widget>[
        const ListTile(
          title: Text('Ugeplan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              )),
        ),
        SizedBox(
          width: double.infinity,
          child: _button(() {}, 'Antal dage'),
        )
      ],
    );
  }

  Widget _buildUserSettings() {
    return Column(
      children: <Widget>[
        const ListTile(
          title: Text('Brugerindstillinger',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              )),
        ),
        SizedBox(
          width: double.infinity,
          child: _button(() {}, _user.name + 's indstillinger'),
        )
      ],
    );
  }

  OutlineButton _button(VoidCallback onPressed, String text) {
    return OutlineButton(
      padding: const EdgeInsets.all(15),
      onPressed: () => onPressed,
      child: Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward)),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ))
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      highlightedBorderColor: GirafColors.appBarOrange,
    );
  }
}
