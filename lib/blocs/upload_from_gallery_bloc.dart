import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';

/// Bloc for retriving an image from a phones gallery,
/// and send it to the pictogram database
class UploadFromGalleryBloc extends BlocBase {
  ///
  UploadFromGalleryBloc(this._api);
  final Api _api;
  late String _pictogramName;

  /// Publishes the image file, while it is nut null
  Stream<File> get file => _file.stream.where((File? f) => f != null);

  /// Publishes true while waiting for the pictogram to be uploaded
  Stream<bool> get isUploading => _isUploading.stream;

  /// Publishes the accessLevel for the pictogram
  Stream<String> get accessLevel => _accessString.stream;

  /// Publishes if the input fields are filled
  Stream<bool> get isInputValid => _isInputValid.stream;

  final rx_dart.BehaviorSubject<bool> _isInputValid =
      rx_dart.BehaviorSubject<bool>.seeded(false);
  final rx_dart.BehaviorSubject<File> _file = rx_dart.BehaviorSubject<File>();
  final rx_dart.BehaviorSubject<String> _accessString =
      rx_dart.BehaviorSubject<String>.seeded('Institution');
  final rx_dart.BehaviorSubject<bool> _isUploading =
      rx_dart.BehaviorSubject<bool>.seeded(false);

  /// pushes an imagePicker screen, then sets the pictogram image,
  /// to the selected image from the gallery
  void chooseImageFromGallery() {
    ImagePicker()
        .pickImage(source: ImageSource.gallery)
        .then<dynamic>((XFile? f) {
      if (f != null) {
        _publishImage(File(f.path));
        _checkInput();
      }
    });
  }

  /// Checks if the input fields are filled out
  void _checkInput() {
    if (_pictogramName.isNotEmpty) {
      _isInputValid.add(true);
    } else {
      _isInputValid.add(false);
    }
  }

  /// sets the pictogram name
  void setPictogramName(String newName) {
    _pictogramName = newName;
    _checkInput();
  }

  void _publishImage(File file) {
    _file.add(file);
  }

  /// Encodes the given file into an integer list.
  List<int>? encodePicture(File? file) {
    if (file != null) {
      final Image? image = decodeImage(file.readAsBytesSync());
      if (image != null) {
        return encodePng(copyResize(image, width: 512));
      }
    }
    return null;
  }

  /// Creates a [PictogramModel]
  /// from the seleted [Image], [AccessLevel], and title
  Stream<PictogramModel> createPictogram() {
    _isUploading.add(true);
    return _api.pictogram
        .create(PictogramModel(
      accessLevel: AccessLevel.PRIVATE,
      title: _pictogramName,
    ))
        .flatMap((PictogramModel pictogram) {
      return _api.pictogram
          .updateImage(pictogram.id!, encodePicture(_file.value) as Uint8List);
    }).map((PictogramModel pictogram) {
      _isUploading.add(false);
      return pictogram;
    }).doOnError((Object error, StackTrace trace) {
      _isUploading.add(false);
    }).take(1);
  }

  @override
  void dispose() {
    _file.close();
    _accessString.close();
    _isInputValid.close();
    _isUploading.close();
  }
}
