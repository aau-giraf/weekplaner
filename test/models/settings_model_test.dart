import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, dynamic> response = <String, dynamic>{
    'orientation': 1,
    'completeMark': 2,
    'cancelMark': 2,
    'defaultTimer': 2,
    'timerSeconds': 900,
    'activitiesCount': null,
    'theme': 1,
    'nrOfDaysToDisplayPortrait': 1,
    'displayDaysRelativePortrait': true,
    'nrOfDaysToDisplayLandscape': 7,
    'displayDaysRelativeLandscape': false,
    'lockTimerControl': false,
    'greyScale': false,
    'pictogramText': false,
    'showPopup': false,
    'nrOfActivitiesToDisplay': 0,
    'showOnlyActivities': false,
    'showSettingsForCitizen': false,
    'weekDayColors': <dynamic>[
      <String, dynamic>{'hexColor': '#067700', 'day': 1},
      <String, dynamic>{'hexColor': '#8c1086', 'day': 2},
      <String, dynamic>{'hexColor': '#ff7f00', 'day': 3},
      <String, dynamic>{'hexColor': '#0017ff', 'day': 4},
      <String, dynamic>{'hexColor': '#ffdd00', 'day': 5},
      <String, dynamic>{'hexColor': '#ff0102', 'day': 6},
      <String, dynamic>{'hexColor': '#ffffff', 'day': 7}
    ]
  };

  test('Can instantiate from JSON', () {
    final SettingsModel settings = SettingsModel.fromJson(response);

    expect(
        settings.orientation, Orientation.values[response['orientation'] - 1]);
    expect(settings.completeMark,
        CompleteMark.values[response['completeMark'] - 1]);
    expect(settings.cancelMark, CancelMark.values[response['cancelMark'] - 1]);
    expect(settings.defaultTimer,
        DefaultTimer.values[response['defaultTimer'] - 1]);
    expect(settings.timerSeconds, response['timerSeconds']);
    expect(settings.activitiesCount, response['activitiesCount']);
    expect(settings.theme, GirafTheme.values[response['theme'] - 1]);
    expect(settings.nrOfDaysToDisplayPortrait, 1);
    expect(settings.displayDaysRelativePortrait, true);
    expect(settings.nrOfDaysToDisplayLandscape, 7);
    expect(settings.displayDaysRelativeLandscape, false);
    expect(settings.lockTimerControl, false);
    expect(settings.pictogramText, false);
    expect(settings.showPopup, false);
    expect(settings.greyscale, false);
    expect(settings.nrOfActivitiesToDisplay, 0);
    expect(settings.showOnlyActivities, false);
    expect(settings.showSettingsForCitizen, false);
    expect(settings.weekDayColors!.length, 7);
    expect(settings.weekDayColors![0].toJson(), response['weekDayColors'][0]);
    expect(settings.weekDayColors![1].toJson(), response['weekDayColors'][1]);
    expect(settings.weekDayColors![2].toJson(), response['weekDayColors'][2]);
    expect(settings.weekDayColors![3].toJson(), response['weekDayColors'][3]);
    expect(settings.weekDayColors![4].toJson(), response['weekDayColors'][4]);
    expect(settings.weekDayColors![5].toJson(), response['weekDayColors'][5]);
    expect(settings.weekDayColors![6].toJson(), response['weekDayColors'][6]);
  });

  test('Will throw exception when JSON is null', () {
    expect(() => SettingsModel.fromJson(null), throwsFormatException);
  });

  test('Can serialize into JSON', () {
    final SettingsModel settings = SettingsModel.fromJson(response);

    expect(settings.toJson(), response);
  });
}
