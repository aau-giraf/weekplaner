import 'package:flutter/material.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_title_header.dart';
import '../style/custom_color.dart' as theme;

/// An AlertDialog for notifications, with a title and description as input.
/// The only action that the dialog can do is pressing okay, as the
/// dialog is intended to only notify the user.
/// Other dialogs can be seen at: https://aau-giraf.github.io/wiki/UI_Design/Design_Guide/dialog/
class GirafNotifyDialog extends StatelessWidget implements PreferredSizeWidget {
  ///The dialog displays the title and description, with a button
  ///to conform the notification, which simply closes the dialog.
  const GirafNotifyDialog(
      {required Key key,
      required this.title,
      this.description = 'Ingen beskrivelse'})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  ///title of the dialogBox, displayed in the header of the dialogBox
  final String title;

  ///description of the dialogBox, displayed under the header, describing the
  ///encountered problem
  final String description;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(0.0),
      shape:
          Border.all(color: theme.GirafColors.transparentDarkGrey, width: 5.0),
      title: Center(
          child: GirafTitleHeader(
        key: const ValueKey<String>('girafTitle'),
        title: title,
      )),
      content: Column(
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
                  //if description is null, its replaced with empty.
                  description,
                  textAlign: TextAlign.center,
                ),
              ))
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: OverflowBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  GirafButton(
                    key: const Key('NotifyDialogOkayButton'),
                    text: 'Okay',
                    icon: const ImageIcon(
                      AssetImage('assets/icons/accept.png'),
                      color: theme.GirafColors.transparentBlack,
                    ),
                    onPressed: () {
                      Routes().pop(context);
                    },
                  )
                ],
              ))
        ],
      ),
    );
  }
}
