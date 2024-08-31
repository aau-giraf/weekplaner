import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/weekday_color_model.dart';

/// Class containing the three standard color settings for weekplan_screen
class WeekplanColorTheme {
  /// Standard color setting
  List<WeekdayColorModel> standardColorSetting() {
    final List<WeekdayColorModel> weekDayColors = <WeekdayColorModel>[];
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#08A045', day: Weekday.Monday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#540D6E', day: Weekday.Tuesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#F77F00', day: Weekday.Wednesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#004777', day: Weekday.Thursday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#F9C80E', day: Weekday.Friday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#DB2B39', day: Weekday.Saturday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Sunday));

    return weekDayColors;
  }

  /// Standard blue white color setting
  List<WeekdayColorModel> blueWhiteColorSetting() {
    final List<WeekdayColorModel> weekDayColors = <WeekdayColorModel>[];
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#2196F3', day: Weekday.Monday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Tuesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#2196F3', day: Weekday.Wednesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Thursday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#2196F3', day: Weekday.Friday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Saturday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#2196F3', day: Weekday.Sunday));

    return weekDayColors;
  }

  /// Standard grey white color setting
  List<WeekdayColorModel> greyWhiteColorSetting() {
    final List<WeekdayColorModel> weekDayColors = <WeekdayColorModel>[];
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#9E9E9E', day: Weekday.Monday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Tuesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#9E9E9E', day: Weekday.Wednesday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Thursday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#9E9E9E', day: Weekday.Friday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#FFFFFF', day: Weekday.Saturday));
    weekDayColors
        .add(WeekdayColorModel(hexColor: '#9E9E9E', day: Weekday.Sunday));

    return weekDayColors;
  }
}
