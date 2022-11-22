import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/widgets/paswordInputField.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';
import 'package:api_client/api/api.dart';
import 'giraf_notify_dialog.dart';


/// The pictograms to choose between for the code.
/// If these are changed all previously made passwords will become unusable
const List<int> CHOSENPICTOGRAMS = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

/// The maximum width that is shared by both gridviews
const double MAXWIDTH = 500;

///Widget to show possible pictograms for pictogram password
///and the currently input pictograms
class PictogramChoices extends StatelessWidget {
  ///Widget with the possible pictograms in the code and the currently picked
  /// pictograms in the code.

  const PictogramChoices({Key key,
    @required this.onPasswordChanged,
    @required this.api})
      : super(key: key);

  /// This function returns the new password every time the password has been
  /// changed by adding or removing pictogram.
  final Function onPasswordChanged;

  /// Pictogram api passed as a parameter to allow for testing
  final Api api;

  /// Returns the list of possible pictograms for use in the password
  /// as a stream
  Stream<List<PictogramModel>> getStream() async* {
    final List<PictogramModel> list =
    List<PictogramModel>.filled(CHOSENPICTOGRAMS.length, null);
    yield list;
    try {
      for (int i = 0; i < list.length; i++) {
        final int index = CHOSENPICTOGRAMS[i];
        await for (final PictogramModel model in api.pictogram.get(index)) {
          list[i] = model;
          yield list;
        }
      }
    } catch (e) {
      showErrorMessage(e, di.getDependency<BuildContext>());

    }
  }
  /// Shows error message in case of any pictogram being unobtainable
  void showErrorMessage(Object error, BuildContext context) {
    showDialog<Center>(

      /// exception handler to handle web_api exceptions
        barrierDismissible: false,
        context:  context,
        builder: (BuildContext context) {
          return const GirafNotifyDialog(
              title: 'Fejl',
              description: 'Fejl i forbindelse med at vise piktogrammer',
              key: Key('ErrorMessageDialog'));
        });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<List<PictogramModel>> _pictogramChoices = getStream();
    final GlobalKey<PasswordInputFieldState> inputFieldKey = GlobalKey();
    final PasswordInputField password = PasswordInputField(
        key: inputFieldKey,
        onPasswordChanged: onPasswordChanged);
    return Column(children: <Widget>[
      // Grid view with available pictograms
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              constraints: const BoxConstraints(
                  maxHeight: double.infinity, maxWidth: MAXWIDTH),
              child: StreamBuilder<List<PictogramModel>>(
                  stream: _pictogramChoices,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<PictogramModel>> snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Text('Fejl i forbindelse med piktogrammer.');
                    } else if (snapshot.hasData) {
                      return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 5,
                          physics: const NeverScrollableScrollPhysics(),
                          children: snapshot.data
                              .map<Widget>((PictogramModel pictogram) {
                            if (pictogram == null) {
                              return Container(
                                height: 80,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            // This is here to allow for testing.
                            else if (pictogram.id == -1) {
                              return GestureDetector(
                                onTap: () =>
                                    inputFieldKey.
                                    currentState.addToPass(pictogram),
                                child: const Text('Error'),
                                key: const Key('TestPictogram'),
                              );
                            }
                            else {
                              return PictogramImage(
                                  pictogram: pictogram,
                                  onPressed: () =>
                                      inputFieldKey.
                                      currentState.addToPass(pictogram));
                            }
                          }).toList());
                    } else {
                      return const Text('Fejl');
                    }
                  })),
        ],
      ),
      // This acts as a spacer.
      const SizedBox(
        height: 10,
      ),
      // Password grid view
      password
    ]);
  }
}