import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

import '../routes.dart';

/// Widget for rendering pictogram models as images
class PictogramImage extends StatelessWidget {
  /// Renders [pictogram] model as image
  ///
  /// The image url is extracted from the [pictogram] provided, and an
  /// authenticated request is then made to the back-end to load the image.
  ///
  /// The [onPressed] function will be called every time the image is pressed
  PictogramImage(
      {required Key key,
      required this.pictogram,
      required this.onPressed,
      this.haveRights = false,
      this.needsTitle = false})
      : super(key: key) {
    _bloc.load(pictogram);
  }

  /// Provided Pictogram to load
  final PictogramModel pictogram;

  /// haveRights returns true if the current active user have the rights to the
  /// pictogram.
  final bool haveRights;

  ///needsTitle is true if the a title should be displayed along with the image
  final bool needsTitle;

  /// The provided callback function which will be called on
  /// every press of the image
  final VoidCallback onPressed;

  final PictogramImageBloc _bloc = di.get<PictogramImageBloc>();

  final Widget _loading = Center(
      child: Container(
          width: 200, height: 200, child: const CircularProgressIndicator()));

  Future<Center?> _confirmDeleteDialog(BuildContext context) {
    return showDialog<Center>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Slet piktogram',
              description: 'Vil du slette det markerede piktogram?',
              confirmButtonText: 'Slet',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/delete.png')),
              confirmOnPressed: () {
                if (!_bloc.delete(pictogram)) {
                  _notifyErrorOnDeleteDialog(context);
                }
                Routes().pop(context);
              },
              key: UniqueKey());
        });
  }

  Future<Center?> _notifyErrorOnDeleteDialog(BuildContext context) {
    return showDialog<Center>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const GirafNotifyDialog(
            title: 'Det valgte piktogram kunne ikke slettes',
            description: 'Piktogrammet kunne ikke slettes, prøv igen. '
                'Hvis fejlen gentager sig, kontakt en administrator.',
            key: ValueKey<String>('errorOnDeleteKey'),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Card(
            child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                    child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Stack(children: <Widget>[
                          //If needsTitle=true display picture and title,
                          // else only show picture
                          needsTitle
                              ? Column(children: <Widget>[
                                  Stack(children: <Widget>[
                                    Container(
                                      //200x200 is the size of the pictograms,
                                      //this is added so the text does not scale
                                      width: 200,
                                      height: 200,
                                    ),
                                    StreamBuilder<Image>(
                                        stream: _bloc.image,
                                        builder: (BuildContext context,
                                                AsyncSnapshot<Image>
                                                    snapshot) =>
                                            snapshot.data ?? _loading)
                                  ]),
                                  Text(pictogram.title),
                                ])
                              : StreamBuilder<Image>(
                                  stream: _bloc.image,
                                  builder: (BuildContext context,
                                          AsyncSnapshot<Image> snapshot) =>
                                      snapshot.data ?? _loading),
                          //delete button
                          haveRights
                              ? Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GirafButton(
                                    onPressed: () {
                                      _confirmDeleteDialog(context);
                                    },
                                    icon: const ImageIcon(
                                        AssetImage('assets/icons/gallery.png')),
                                    text: 'Slet',
                                    key: const ValueKey<String>('deleteBtnKey'),
                                  ),
                                )
                              : Container(),
                        ]))))));
  }
}
