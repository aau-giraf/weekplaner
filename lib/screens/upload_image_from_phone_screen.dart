import 'dart:io';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/upload_from_gallery_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import 'package:weekplanner/widgets/loading_spinner_widget.dart';
import '../style/custom_color.dart' as theme;

/// Screen for uploading a [PictogramModel] to the server
/// Generic type I used for mocks in testing
// ignore: must_be_immutable
class UploadImageFromPhone extends StatelessWidget {
  /// Default constructor
  UploadImageFromPhone({required Key key}) : super(key: key);

  final UploadFromGalleryBloc _uploadFromGallery =
      di.get<UploadFromGalleryBloc>();

  final BorderRadius _imageBorder = BorderRadius.circular(25);

  ///Variable representing the screen height
  dynamic screenHeight;

  ///Variable representing the screen width
  dynamic screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    // ignore: lines_longer_than_80_chars
    return Scaffold(
      appBar: GirafAppBar(
          key: const ValueKey<String>('uploadKey'),
          title: 'Tilføj fra galleri'),
      body: StreamBuilder<bool>(
          stream: _uploadFromGallery.isUploading,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return snapshot.hasData && snapshot.data!
                ? LoadingSpinnerWidget(
                    key: UniqueKey(),
                  )
                : _buildBody(context);
          }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: <Widget>[
        _buildDefaultText(),
        _buildImageBox(),
        _buildInputField(context),
      ],
      //),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: _uploadFromGallery.setPictogramName,
                decoration: InputDecoration(
                    hintText: 'Piktogram navn',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50))),
              ),
            ),
          ],
        ),
        Container(
          height: 15,
        ),
        Container(
          width: 250,
          height: 50,
          child: GirafButton(
            key: const Key('SavePictogramButtonKey'),
            icon: const ImageIcon(AssetImage('assets/icons/save.png')),
            text: 'Gem',
            onPressed: () {
              _uploadFromGallery.createPictogram().listen((PictogramModel p) {
                Routes().pop(context, p);
              }, onError: (Object error) {
                _showUploadError(context);
              });
            },
            isEnabledStream: _uploadFromGallery.isInputValid,
          ),
        ),
      ],
    );
  }

  Widget _buildImageBox() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Container(
            child: TextButton(
          onPressed: _uploadFromGallery.chooseImageFromGallery,
          child: StreamBuilder<File>(
              stream: _uploadFromGallery.file,
              builder: (BuildContext context, AsyncSnapshot<File> snapshot) =>
                  snapshot.data != null
                      ? _displayImage(snapshot.data!)
                      : _displayIfNoImage()),
        )));
  }

  void _showUploadError(BuildContext context) {
    showDialog<Center>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GirafNotifyDialog(
          title: 'Fejl',
          description: 'Upload af pictogram fejlede.',
          key: UniqueKey(),
        );
      },
    );
  }

  Widget _displayIfNoImage() {
    return Container(
      height: screenHeight / 3,
      width: screenWidth * 0.90,
      decoration: BoxDecoration(
          border: Border.all(
            width: 4,
            color: theme.GirafColors.black,
          ),
          color: theme.GirafColors.white70,
          borderRadius: _imageBorder),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/icons/gallery.png',
            color: theme.GirafColors.black,
            scale: .75,
          ),
          const Text(
            'Tryk for at vælge billede',
            style: TextStyle(
                color: theme.GirafColors.black, fontSize: GirafFont.medium),
          )
        ],
      ),
    );
  }

  Widget _buildDefaultText() {
    return const Padding(
        padding: EdgeInsets.only(
          bottom: 10,
        ),
        child: Text(
          'Vælg billede fra galleri',
          style: TextStyle(
              color: theme.GirafColors.black, fontSize: GirafFont.medium),
          textAlign: TextAlign.center,
        ));
  }

  Widget _displayImage(File image) {
    return Container(
      child: Image.file(image),
      height: screenHeight / 2,
      width: screenWidth / 2,
      decoration: BoxDecoration(
        borderRadius: _imageBorder,
      ),
    );
  }
}
