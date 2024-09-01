import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import 'package:weekplanner/widgets/giraf_title_header.dart';

import '../style/custom_color.dart' as theme;

/// The acitivty time picker dialog is a dialog, asking for a duration input.
/// The duration should be inserted in the textfield, and the user can either
/// cancel the dialog, or confirm to create the timer for the activity.
class GirafActivityTimerPickerDialog extends StatelessWidget {
  /// The activity time picker takes the activity as input, to insert a timer
  /// to the given activity.
  GirafActivityTimerPickerDialog(
    this._activity,
    this._timerBloc, {
    required Key key,
  }) : super(key: key) {
    _timerBloc.load(_activity);
  }

  final ActivityModel _activity;
  final TimerBloc _timerBloc;

  final TextEditingController _textEditingControllerHours =
      TextEditingController();
  final TextEditingController _textEditingControllerMinutes =
      TextEditingController();
  final TextEditingController _textEditingControllerSeconds =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(0.0),
        titlePadding: const EdgeInsets.all(0.0),
        shape: Border.all(
            color: theme.GirafColors.transparentDarkGrey, width: 5.0),
        title: const Center(
            child: GirafTitleHeader(
          title: 'Vælg tid for aktivitet',
          key: ValueKey<String>('timePickerKey'),
        )),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  _timerTextField(
                      'Timer', _textEditingControllerHours, context),
                  _timerTextField(
                      'Minutter', _textEditingControllerMinutes, context),
                  _timerTextField(
                      'Sekunder', _textEditingControllerSeconds, context)
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                      child: GirafButton(
                        key: const Key('TimePickerDialogCancelButton'),
                        onPressed: () => Routes().pop(context),
                        icon: const ImageIcon(
                            AssetImage('assets/icons/cancel.png')),
                      )),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 10, 10),
                      child: GirafButton(
                        key: const Key('TimePickerDialogAcceptButton'),
                        onPressed: () {
                          _acceptInput(context);
                        },
                        icon: const ImageIcon(
                            AssetImage('assets/icons/accept.png')),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerTextField(String fieldName, TextEditingController textController,
      BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(fieldName),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: theme.GirafColors.grey, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: theme.GirafColors.white),
              child: TextField(
                  key: Key(fieldName + 'TextFieldKey'),
                  onSubmitted: (String s) {
                    _acceptInput(context);
                  },
                  controller: textController,
                  style: const TextStyle(
                    fontSize: GirafFont.timer,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  decoration: const InputDecoration.collapsed(
                    hintText: '',
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[0-9]*')),
                    LengthLimitingTextInputFormatter(2)
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptInput(BuildContext context) {
    final int hours = int.tryParse(_textEditingControllerHours.text) ?? 0;
    final int minutes = int.tryParse(_textEditingControllerMinutes.text) ?? 0;
    final int seconds = int.tryParse(_textEditingControllerSeconds.text) ?? 0;

    final Duration duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );

    if (duration.inSeconds != 0 && hours >= 0 && minutes >= 0 && seconds >= 0) {
      _timerBloc.addTimer(duration);
      Routes().pop(context);
    } else {
      showDialog<Center>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const GirafNotifyDialog(
              key: Key('TimerWrongInputKey'),
              title: 'Ugyldigt input',
              description: 'Den valgte tid må ikke være 0',
            );
          });
    }
  }
}
