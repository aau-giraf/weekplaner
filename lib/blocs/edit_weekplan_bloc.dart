import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/new_weekplan_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/week_model.dart';

///This bloc is used to control the information when editing week plan
class EditWeekplanBloc extends NewWeekplanBloc {
  /// Constructor
  EditWeekplanBloc(Api api) : super(api);

  /// This method should always be called before using the bloc, because
  /// it fills out the initial values of the week model object
  void initializeEditBloc(DisplayNameModel user, WeekModel weekModel) {
    super.initialize(user);
    // We just take the values out of the week model and put into our sink
    super.onTitleChanged.add(weekModel.name!);
    super.onYearChanged.add(weekModel.weekYear.toString());
    super.onWeekNumberChanged.add(weekModel.weekNumber.toString());
    super.onThumbnailChanged.add(weekModel.thumbnail);
  }

  /// This method allows one to save the new information stored in the week
  /// model object and also deletes the old object if necessary
  Future<WeekModel> editWeekPlan(
      {required BuildContext? screenContext,
      required WeekModel oldWeekModel,
      required WeekplansBloc selectorBloc}) async {
    final WeekModel newWeekModel = WeekModel();

    // We copy the activities from the old week model.
    newWeekModel.days = oldWeekModel.days;

    // Getting the values from the input fields
    newWeekModel.thumbnail = super.thumbnailController.value;
    newWeekModel.name = super.titleController.value;
    newWeekModel.weekYear = int.parse(super.yearController.value!);
    newWeekModel.weekNumber = int.parse(super.weekNoController.value!);

    bool doOverwrite = true;

    if (oldWeekModel.weekYear != newWeekModel.weekYear ||
        oldWeekModel.weekNumber != newWeekModel.weekNumber) {
      // Check if we changed week or year to those of an existing plan.

      final bool hasExistingMatch = await hasExisitingMatchingWeekplan(
          existingWeekPlans: selectorBloc.weekNameModels,
          year: newWeekModel.weekYear,
          weekNumber: newWeekModel.weekNumber);

      // If there is a match, ask the user if we should overwrite.
      if (hasExistingMatch) {
        doOverwrite = await displayOverwriteDialog(
            screenContext!, newWeekModel.weekNumber, newWeekModel.weekYear);
      }

      // Here we delete the old week plan (we had to do this because of the way
      // the keys work for the put method does not allow us to change year
      // and week number.
      if (doOverwrite) {
        selectorBloc.deleteWeekModel(oldWeekModel);
      }
    }

    final Completer<WeekModel> updateCompleter = Completer<WeekModel>();

    if (doOverwrite) {
      weekApi.week
          .update(super.weekUser!.id!, newWeekModel.weekYear,
              newWeekModel.weekNumber, newWeekModel)
          .take(1)
          .listen(updateCompleter.complete);
    } else {
      // ignore: null_argument_to_non_null_type
      updateCompleter.complete(null);
    }

    return updateCompleter.future;
  }
}
