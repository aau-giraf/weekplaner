import 'dart:async';

import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/copy_resolve_bloc.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/weekplan_selector_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/input_fields_weekplan.dart';

/// Screen for creating a new weekplan.
// ignore: must_be_immutable
class CopyResolveScreen extends StatelessWidget {
  /// Screen for creating a new weekplan.
  /// Requires a [UsernameModel] to be able to save the new weekplan.
  CopyResolveScreen({
    @required this.currentUser,
    @required this.weekModel,
    @required this.forThisCitizen,
    this.copyBloc,
  }) : _bloc = di.getDependency<CopyResolveBloc>() {
    _bloc.initializeCopyResolverBloc(currentUser, weekModel);
    copyBloc ??= di.getDependency<CopyWeekplanBloc>();
  }

  final CopyResolveBloc _bloc;

  /// Tell us whether to copy to this citizen or to others
  final bool forThisCitizen;

  /// An instance of the copyWeekplanBloc.
  CopyWeekplanBloc copyBloc;

  /// The user that is being copied from
  final DisplayNameModel currentUser;

  /// The weekModel that is being copied
  final WeekModel weekModel;

  @override
  Widget build(BuildContext context) {
    final GirafButton saveButton = GirafButton(
      icon: const ImageIcon(AssetImage('assets/icons/save.png')),
      key: const Key('CopyResolveSaveButton'),
      text: 'Kopier ugeplan',
      isEnabled: false,
      isEnabledStream: _bloc.allInputsAreValidStream,
      onPressed: () async {
        WeekModel newWeekModel = _bloc.createNewWeekmodel(weekModel);

        final int numberOfConflicts = await copyBloc.numberOfConflictingUsers(
            newWeekModel, currentUser, forThisCitizen);

        bool toCopy = true;
        if (numberOfConflicts > 0) {
          toCopy = await _displayConflictDialog(
              context,
              newWeekModel.weekNumber,
              newWeekModel.weekYear,
              numberOfConflicts,
              currentUser);
        }

        if (toCopy) {
          copyBloc
              .copyWeekplan(newWeekModel, currentUser, forThisCitizen)
              .then((_) {
            Routes.goHome(context);
            Routes.push(context, WeekplanSelectorScreen(currentUser));
          });
        }
      },
    );

    return Scaffold(
      appBar: GirafAppBar(title: 'Ny ugeplan'),
      body: InputFieldsWeekPlan(
          bloc: _bloc, button: saveButton, weekModel: weekModel),
    );

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
                '${numberOfConflicts == 1 ? "denne ugeplan" : "disse ugeplaner"} ?',
            confirmButtonText: 'Ja',
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/accept.png')),
            confirmOnPressed: () {
              dialogCompleter.complete(true);
            },
            cancelOnPressed: () {
              dialogCompleter.complete(false);
            },
          );
        });

    return dialogCompleter.future;
  }
}
