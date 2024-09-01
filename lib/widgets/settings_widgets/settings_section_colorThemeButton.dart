import 'package:flutter/material.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_item.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_theme_display_box.dart';

import '../../style/custom_color.dart' as theme;

/// Button used for the color theme settings
class SettingsColorThemeCheckMarkButton extends SettingsSectionItem {
  /// Constructor
  const SettingsColorThemeCheckMarkButton(
      this._expected, this._current, this.text, this._callback);

  final List<WeekdayColorModel> _expected, _current;

  /// Text on button
  final String text;

  final VoidCallback _callback;

  @override
  Widget build(BuildContext context) {
    Widget? trailing;
    if (hasCheckMark()) {
      trailing = const Icon(Icons.check, color: theme.GirafColors.black);
    } else {
      trailing = null;
    }

    return ListTile(
      title: Row(
        children: <Widget>[
          ThemeBox.fromHexValues(
              _expected[0].hexColor!, _expected[1].hexColor!),
          Text(text),
        ],
      ),
      trailing: trailing,
      onTap: () => _callback(),
    );
  }

  /// Checks if the button has been chosen
  bool hasCheckMark() {
    if (_expected.length == _current.length) {
      for (int i = 0; i < _expected.length; i++) {
        if (_expected[i].hexColor != _current[i].hexColor ||
            _expected[i].day != _current[i].day) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}
