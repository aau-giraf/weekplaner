import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/widgets/settings_widgets/settings_section_item.dart';

import '../../style/custom_color.dart' as theme;

/// SettingSection CheckMarkButton class
class SettingsCheckMarkButton extends SettingsSectionItem {
  /// Constructor
  const SettingsCheckMarkButton(
      this.expected, this.current, this.text, this.callback,
      [this.timer]);

  /// Constructor to create CheckMarkButton from a boolean value
  factory SettingsCheckMarkButton.fromBoolean(
      bool shouldBeChecked, String text, VoidCallback callback) {
    if (shouldBeChecked) {
      return SettingsCheckMarkButton(1, 1, text, callback);
    }
    return SettingsCheckMarkButton(1, 2, text, callback);
  }

  /// Values used to keep track of, if the check should be shown
  final dynamic expected;

  /// Prøver lige
  final dynamic current;

  /// Text on button
  final String text;

  /// Function to run on tap
  final VoidCallback callback;

  /// Optional timer parameter for timer settings
  final DefaultTimer? timer;

  @override
  ListTile build(BuildContext context) {
    Widget? trailing;
    if (expected == current) {
      trailing = const Icon(Icons.check, color: theme.GirafColors.black);
    } else {
      trailing = null;
    }

    ListTile checkBoxButton;

    if (timer == null) {
      checkBoxButton = ListTile(
        title: Text(text),
        trailing: trailing,
        onTap: () => callback(),
      );
    } else {
      String _imagePath;
      if (timer == DefaultTimer.PieChart) {
        _imagePath = 'assets/timer/piechart_icon.png';
      } else if (timer == DefaultTimer.Hourglass) {
        _imagePath = 'assets/timer/hourglass_icon.png';
      } else if (timer == DefaultTimer.Numeric) {
        _imagePath = 'assets/timer/countdowntimer_icon.png';
      } else {
        _imagePath = '';
      }

      checkBoxButton = ListTile(
          title: Text(text),
          leading: Image(image: AssetImage(_imagePath)),
          trailing: trailing,
          onTap: () => callback());
    }

    return checkBoxButton;
  }
}
