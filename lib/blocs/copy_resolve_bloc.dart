import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/week_model.dart';

import 'new_weekplan_bloc.dart';

/// This bloc has logic needed for the CopyResolveScreen
class CopyResolveBloc extends NewWeekplanBloc {
  /// Default constructor
  CopyResolveBloc(Api api) : super(api);

  /// This method should always be called before using the bloc, because
  /// it fills out the initial values of the week model object
  void initializeCopyResolverBloc(DisplayNameModel user, WeekModel weekModel) {
    super.initialize(user);
    // We just take the values out of the week model and put into our sink
    super.onTitleChanged.add(weekModel.name!);
    super.onYearChanged.add(weekModel.weekYear.toString());
    super.onWeekNumberChanged.add(weekModel.weekNumber.toString());
    super.onThumbnailChanged.add(weekModel.thumbnail);
  }

  /// This method is used to get the new week model based on the input fields
  WeekModel createNewWeekmodel(WeekModel oldWeekModel) {
    final WeekModel newWeekModel = WeekModel();
    newWeekModel.days = oldWeekModel.days;

    newWeekModel.thumbnail = super.thumbnailController.value;
    newWeekModel.name = super.titleController.value;
    newWeekModel.weekYear = int.parse(super.yearController.value!);
    newWeekModel.weekNumber = int.parse(super.weekNoController.value!);

    return newWeekModel;
  }
}
