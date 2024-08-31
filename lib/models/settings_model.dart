import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart';
import 'package:weekplanner/models/model.dart';
import 'package:weekplanner/models/weekday_color_model.dart';

/// A model used to store settings values
class SettingsModel implements Model {
  /// Constructor
  SettingsModel(
      {this.orientation,
      this.completeMark,
      this.cancelMark,
      this.defaultTimer,
      this.timerSeconds,
      this.activitiesCount,
      this.theme,
      this.nrOfDaysToDisplayPortrait,
      this.displayDaysRelativePortrait,
      this.nrOfDaysToDisplayLandscape,
      this.displayDaysRelativeLandscape,
      this.greyscale,
      this.lockTimerControl,
      this.pictogramText,
      this.showPopup,
      this.nrOfActivitiesToDisplay,
      this.showOnlyActivities,
      this.showSettingsForCitizen,
      this.weekDayColors});

  /// Another constructor used to create from json.
  SettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[SettingModel]: Cannot initialize from null');
    }

    orientation = Orientation.values[(json['orientation']) - 1];
    completeMark = CompleteMark.values[(json['completeMark']) - 1];
    cancelMark = CancelMark.values[(json['cancelMark']) - 1];
    defaultTimer = DefaultTimer.values[(json['defaultTimer']) - 1];
    timerSeconds = json['timerSeconds'];
    activitiesCount = json['activitiesCount'];
    theme = GirafTheme.values[(json['theme']) - 1];
    nrOfDaysToDisplayPortrait = json['nrOfDaysToDisplayPortrait'];
    displayDaysRelativePortrait = json['displayDaysRelativePortrait'];
    nrOfDaysToDisplayLandscape = json['nrOfDaysToDisplayLandscape'];
    displayDaysRelativeLandscape = json['displayDaysRelativeLandscape'];
    greyscale = json['greyScale'];
    lockTimerControl = json['lockTimerControl'];
    pictogramText = json['pictogramText'];
    showPopup = json['showPopup'];
    nrOfActivitiesToDisplay = json['nrOfActivitiesToDisplay'];
    showOnlyActivities = json['showOnlyActivities'];
    showSettingsForCitizen = json['showSettingsForCitizen'];
    if (json['weekDayColors'] != null && json['weekDayColors'] is List) {
      weekDayColors = List<Map<String, dynamic>>.from(json['weekDayColors'])
          .map(
              (Map<String, dynamic> value) => WeekdayColorModel.fromJson(value))
          .toList();
    } else {
      // TODO(TobiasPalludan): Throw appropriate error.
    }
  }

  /// Create a Settingsmodel from json from the database
  SettingsModel.fromDatabase(Map<String, dynamic>? settingsJson,
      List<Map<String, dynamic>>? weekdayColorsJson) {
    if (settingsJson == null) {
      throw const FormatException(
          '[SettingModel]: Cannot initialize from null');
    }

    orientation = Orientation.values[settingsJson['orientation']];
    completeMark = CompleteMark.values[settingsJson['completeMark']];
    cancelMark = CancelMark.values[settingsJson['cancelMark']];
    defaultTimer = DefaultTimer.values[settingsJson['defaultTimer']];
    timerSeconds = settingsJson['timerSeconds'];
    activitiesCount = settingsJson['activitiesCount'];
    theme = GirafTheme.values[settingsJson['theme']];
    nrOfDaysToDisplayPortrait = settingsJson['nrOfDaysToDisplayPortrait'];
    displayDaysRelativePortrait =
        settingsJson['displayDaysRelativePortrait'] == 1;
    nrOfDaysToDisplayLandscape = settingsJson['nrOfDaysToDisplayLandscape'];
    displayDaysRelativeLandscape =
        settingsJson['displayDaysRelativeLandscape'] == 1;
    greyscale = settingsJson['greyScale'] == 1;
    lockTimerControl = settingsJson['lockTimerControl'] == 1;
    pictogramText = settingsJson['pictogramText'] == 1;
    showPopup = settingsJson['showPopup'] == 1;
    nrOfActivitiesToDisplay = settingsJson['nrOfActivitiesToDisplay'];
    showOnlyActivities = settingsJson['showOnlyActivities'] == 0;
    showSettingsForCitizen = settingsJson['showSettingsForCitizen'] == 0;
    if (weekdayColorsJson != null) {
      weekDayColors = weekdayColorsJson
          .map((Map<String, dynamic> value) =>
              WeekdayColorModel.fromDatabase(value))
          .toList();
    } else {
      // TODO(TobiasPalludan): Throw appropriate error.
    }
  }

  /// Preferred orientation of device/screen
  Orientation? orientation;

  /// Preferred appearance of checked resources
  CompleteMark? completeMark;

  /// Preferred appearance of cancelled resources
  CancelMark? cancelMark;

  /// Preferred appearance of timer
  DefaultTimer? defaultTimer;

  /// Number of seconds for timer
  int? timerSeconds;

  /// Number of activities
  int? activitiesCount;

  /// The preferred theme
  GirafTheme? theme;

  /// Defines the number of days to display in portrait mode
  /// for a user in a weekplan
  int? nrOfDaysToDisplayPortrait;

  /// true: if the first day shown in the weekplanner in portrait mode
  /// should be today
  /// false: if the first day shown in the weekplanner in portrait mode
  /// should be monday
  bool? displayDaysRelativePortrait;

  /// Defines the number of days to display in landscape mode
  /// for a user in a weekplan
  int? nrOfDaysToDisplayLandscape;

  /// true: if the first day shown in the weekplanner in landscape mode
  /// should be today
  /// false: if the first day shown in the weekplanner in landscape mode
  /// should be monday
  bool? displayDaysRelativeLandscape;

  /// Defines the number of activities to display for a user in a weekschedule
  int? nrOfActivitiesToDisplay;

  /// Flag for indicating whether or not greyscale is enabled
  bool? greyscale;

  /// Defines if the user can stop/pause/restart a timer once started
  bool? lockTimerControl;

  /// Defines if text should be shown alongside the pictograms in the weekplan
  bool? pictogramText;

  /// Defines if a popup should be shown on the choice board and activity timers
  bool? showPopup;

  /// Flag for only showing activities instead of days
  bool? showOnlyActivities;

  /// Defines if settings should be shown for a citizen
  bool? showSettingsForCitizen;

  /// List of weekday colors shown in the weekplan
  List<WeekdayColorModel>? weekDayColors;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'orientation': orientation!.index + 1,
      'completeMark': completeMark!.index + 1,
      'cancelMark': cancelMark!.index + 1,
      'defaultTimer': defaultTimer!.index + 1,
      'timerSeconds': timerSeconds,
      'activitiesCount': activitiesCount,
      'theme': theme!.index + 1,
      'nrOfDaysToDisplayPortrait': nrOfDaysToDisplayPortrait,
      'displayDaysRelativePortrait': displayDaysRelativePortrait,
      'nrOfDaysToDisplayLandscape': nrOfDaysToDisplayLandscape,
      'displayDaysRelativeLandscape': displayDaysRelativeLandscape,
      'greyScale': greyscale,
      'lockTimerControl': lockTimerControl,
      'pictogramText': pictogramText,
      'showPopup': showPopup,
      'nrOfActivitiesToDisplay': nrOfActivitiesToDisplay,
      'showOnlyActivities': showOnlyActivities,
      'showSettingsForCitizen': showSettingsForCitizen,
      'weekDayColors':
          weekDayColors?.map((WeekdayColorModel e) => e.toJson()).toList()
    };
  }
}
