import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/edit_weekplan_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/input_fields_weekplan.dart';

///This screen is called when you edit a week plan
class EditWeekPlanScreen extends StatelessWidget {
  /// Screen for editing a weekplan.
  /// Requires a [UsernameModel] to be able to save the new weekplan.
  EditWeekPlanScreen({
    @required UsernameModel user,
    @required this.weekModel,
    @required this.selectorBloc,
  }) : _bloc = di.getDependency<EditWeekplanBloc>() {
    _bloc.initializeEditBloc(user, weekModel);
  }

  /// The current week model that should be edited
  final WeekModel weekModel;

  /// This bloc is the bloc from the week plan selector screen it is needed in
  /// in order to delete the week plan
  final WeekplansBloc selectorBloc;

  final EditWeekplanBloc _bloc;

  @override
  Widget build(BuildContext context) {
    final GirafButton editButton = GirafButton(
      icon: const ImageIcon(AssetImage('assets/icons/edit.png')),
      text: 'Gem ændringer',
      isEnabled: false,
      isEnabledStream: _bloc.allInputsAreValidStream,
      onPressed: () {
        _bloc
            .editWeekPlan(weekModel, selectorBloc)
            .listen((WeekModel response) {
          if (response != null) {
            Routes.pop<WeekModel>(context, response);
          }
        });
      },
    );

    return Scaffold(
      appBar: GirafAppBar(title: 'Rediger ugeplan'),
      body: InputFieldsWeekPlan(
        bloc: _bloc,
        button: editButton,
        weekModel: weekModel,
      ),
    );
  }
}