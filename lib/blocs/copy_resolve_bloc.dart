import 'dart:async';
import 'package:api_client/models/displayname_model.dart';
import 'package:flutter/material.dart';
import 'package:api_client/api/api.dart';
import 'package:api_client/models/week_model.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/screens/weekplan_selector_screen.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import '../routes.dart';
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
    super.onTitleChanged.add(weekModel.name);
    super.onYearChanged.add(weekModel.weekYear.toString());
    super.onWeekNumberChanged.add(weekModel.weekNumber.toString());
    super.onThumbnailChanged.add(weekModel.thumbnail);
  }

  /// Takes the content of the bloc and create a new weekplan
  /// and copies it to the chosen citizens
  Future<bool> copyContent(
      BuildContext context,
      WeekModel oldWeekModel,
      CopyWeekplanBloc copyBloc,
      DisplayNameModel currentUser,
      bool forThisCitizen) async {
    final WeekModel newWeekModel = WeekModel();
    newWeekModel.days = oldWeekModel.days;

    newWeekModel.thumbnail = super.thumbnailController.value;
    newWeekModel.name = super.titleController.value;
    newWeekModel.weekYear = int.parse(super.yearController.value);
    newWeekModel.weekNumber = int.parse(super.weekNoController.value);
    final int numberOfConflicts = await copyBloc.numberOfConflictingUsers(
        newWeekModel, currentUser, forThisCitizen);

    if (numberOfConflicts > 0) {
      _displayConflictDialog(context, newWeekModel.weekNumber,
              newWeekModel.weekYear, numberOfConflicts, currentUser)
          .then((bool toOverwrite) {
        if (toOverwrite) {
          copyBloc.copyWeekplan(newWeekModel, currentUser, forThisCitizen);
        }
      });
    } else {
      copyBloc.copyWeekplan(newWeekModel, currentUser, forThisCitizen);
      _returnToSelectorScreen(context, currentUser);
    }
    return true;
  }

  Future<bool> _displayConflictDialog(BuildContext context, int weekNumber,
      int year, int numberOfConflicts, DisplayNameModel currentUser) {
    final Completer<bool> dialogCompleter = Completer<bool>();
    showDialog<Center>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return GirafConfirmDialog(
            key: const Key('OverwriteCopyDialogKey'),
            title: 'Lav ny ugeplan til at kopiere',
            description: 'Der eksisterer allerede en ugeplan (uge: $weekNumber'
                ', år: $year) hos $numberOfConflicts af borgerne. '
                'Vil du overskrive '
                '${numberOfConflicts == 1 ? "denne ugeplan" :
                      "disse ugeplaner"} ?',
            confirmButtonText: 'Ja',
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/accept.png')),
            confirmOnPressed: () {
              dialogCompleter.complete(true);
              _returnToSelectorScreen(context, currentUser);
            },
            cancelOnPressed: () {
              dialogCompleter.complete(false);
            },
          );
        });

    return dialogCompleter.future;
  }

  void _returnToSelectorScreen(BuildContext context, DisplayNameModel user) {
    Routes.goHome(context);
    Routes.push(context, WeekplanSelectorScreen(user, waitAndUpdate: true));
  }
}