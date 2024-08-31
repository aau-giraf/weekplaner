import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/copy_activities_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/widgets/copy_dialog_buttons_widget.dart';
import 'package:weekplanner/widgets/giraf_title_header.dart';
import '../style/custom_color.dart' as theme;

/// A dialog widget presented to the user to confirm an action based on
/// a list of checkboxes presented in the dialog. The dialog consists of a
/// title, a description, and two buttons and a dropdown menu. One button to
/// cancel the action and one button to accept and perform the action.
class GirafCopyActivitiesDialog extends StatelessWidget {
  /// The dialog displays the title and description, with two buttons and a
  /// list of checkboxes
  GirafCopyActivitiesDialog(
      {required Key key,
      required this.title,
      required this.description,
      required this.confirmButtonText,
      required this.confirmButtonIcon,
      required this.confirmOnPressed})
      : super(key: key);

  /// Bloc to keep track of which checkboxes are marked
  final CopyActivitiesBloc copyActivitiesBloc = di.get<CopyActivitiesBloc>();

  /// title of the [dialogBox], displayed in the header of the [dialogBox]
  final String title;

  /// description of the [dialogBox], displayed under the header
  final String description;

  /// text on the confirm button, describing the confirmed action
  final String confirmButtonText;

  /// icon on the confirm button, visualizing the confirmed action
  final ImageIcon confirmButtonIcon;

  /// the method to call when the confirmation button is pressed
  final void Function(List<bool>, BuildContext) confirmOnPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(0.0),
      shape:
          Border.all(color: theme.GirafColors.transparentDarkGrey, width: 5.0),
      title: Center(
          child: GirafTitleHeader(
        title: title,
        key: const ValueKey<String>('copyActivitiesKey'),
      )),
      content: StreamBuilder<List<bool>>(
          stream: copyActivitiesBloc.checkboxValues,
          initialData: List<bool>.filled(7, false),
          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                      ),
                    ))
                  ],
                ),
                _buildCheckboxes(snapshot.data!),
                CopyDialogButtons(
                    confirmButtonText: confirmButtonText,
                    confirmButtonIcon: confirmButtonIcon,
                    confirmOnPressed: confirmOnPressed,
                    checkMarkValues: snapshot.data!,
                    key: UniqueKey())
              ],
            );
          }),
    );
  }

  Container _buildCheckboxes(List<bool> checkMarkValues) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildLeftCheckboxRow(checkMarkValues),
            _buildRightCheckboxRow(checkMarkValues)
          ],
        ),
      ),
    );
  }

  Expanded _buildLeftCheckboxRow(List<bool> checkMarkValues) {
    return Expanded(
      flex: 5,
      child: Column(
        children: <Widget>[
          _buildCheckboxListTile(Weekday.Monday, const Key('MonCheckbox'),
              'Mandag', checkMarkValues[Weekday.Monday.index]),
          _buildCheckboxListTile(Weekday.Wednesday, const Key('WedCheckbox'),
              'Onsdag', checkMarkValues[Weekday.Wednesday.index]),
          _buildCheckboxListTile(Weekday.Friday, const Key('FriCheckbox'),
              'Fredag', checkMarkValues[Weekday.Friday.index]),
          _buildCheckboxListTile(Weekday.Sunday, const Key('SunCheckbox'),
              'Søndag', checkMarkValues[Weekday.Sunday.index])
        ],
      ),
    );
  }

  Expanded _buildRightCheckboxRow(List<bool> checkMarkValues) {
    return Expanded(
      flex: 5,
      child: Column(
        children: <Widget>[
          _buildCheckboxListTile(Weekday.Tuesday, const Key('TueCheckbox'),
              'Tirsdag', checkMarkValues[Weekday.Tuesday.index]),
          _buildCheckboxListTile(Weekday.Thursday, const Key('ThuCheckbox'),
              'Torsdag', checkMarkValues[Weekday.Thursday.index]),
          _buildCheckboxListTile(Weekday.Saturday, const Key('SatCheckbox'),
              'Lørdag', checkMarkValues[Weekday.Saturday.index])
        ],
      ),
    );
  }

  CheckboxListTile _buildCheckboxListTile(
      Weekday weekday, Key checkboxKey, String checkboxTitle, bool value) {
    return CheckboxListTile(
      key: checkboxKey,
      value: value,
      onChanged: (bool? value) =>
          copyActivitiesBloc.toggleCheckboxState(weekday.index),
      title: Text(checkboxTitle),
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: theme.GirafColors.checkboxColor,
    );
  }
}
