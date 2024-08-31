// ignore_for_file: always_specify_types

import 'package:weekplanner/models/pictogram_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

/// Shows the currently picked pictograms in either making pictogram code
/// or logging in with it
class PictogramInputField extends StatefulWidget {
  /// Shows the currently picked pictograms in either making pictogram code
  /// or logging in with it
  const PictogramInputField({required Key key, required this.onPasswordChanged})
      : super(key: key);

  /// Function called when an input is changed to update save button
  /// usability
  final Function onPasswordChanged;

  @override
  PictogramInputFieldState createState() => PictogramInputFieldState();
}

/// The maximum width that is shared by both gridviews
const double MAXWIDTH = 500;

/// State for PassWordInputField
class PictogramInputFieldState extends State<PictogramInputField> {
  late List<PictogramModel?> _inputCode;
  @override
  void initState() {
    _inputCode = List<PictogramModel?>.filled(4, null);
    super.initState();
  }

  ///Called when one of the possible pictograms are pressed
  ///and adds it to the code
  void addToPass(PictogramModel pictogram) {
    final int index = _inputCode.indexOf(null);
    if (index == -1) {
      return;
    }
    _inputCode[index] = pictogram;
    widget.onPasswordChanged(validateAndConvertPass());
    //Reloads the widget with the new input
    setState(() {});
  }

  /// Validates whether all four needed pictograms have been input and returns
  /// value of password
  String? validateAndConvertPass() {
    String output = '';
    for (PictogramModel? m in _inputCode) {
      if (m != null) {
        output += m.id.toString();
      } else {
        return null;
      }
    }
    return output;
  }

  /// Returns the list of widgets that is the currently input pictograms
  /// or empty boxes
  List<Widget> passwordList() {
    final List<Widget> password =
        List<Widget>.filled(4, ErrorWidget(const Stream.empty()));
    for (int i = 0; i < 4; i++) {
      final PictogramModel? pictogram = _inputCode[i];
      Widget widget;
      if (pictogram == null) {
        widget = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFe0dede),
          ),
        );
      } else {
        widget = PictogramImage(
            pictogram: pictogram,
            onPressed: () => removeFromPass(i),
            key: UniqueKey());
      }
      password[i] = widget;
    }
    return password;
  }

  ///Called when a pictogram is pressed in the code and removes the pressed icon
  void removeFromPass(int index) {
    _inputCode[index] = null;
    widget.onPasswordChanged(validateAndConvertPass());
    //Reloads the widget with the new code
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      width: MediaQuery.of(context).size.width,
      height: 120,
      key: const Key('InputPasswordContainer'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              constraints: const BoxConstraints(
                  maxHeight: double.infinity, maxWidth: MAXWIDTH),
              child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  children: passwordList())),
        ],
      ),
    );
  }
}
