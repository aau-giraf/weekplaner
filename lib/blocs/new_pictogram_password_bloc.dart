import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/widgets/pictogram_password_widgets/pictogram_password_widget.dart';

/// Used to create a new pictogram password for a citizen.
class NewPictogramPasswordBloc extends BlocBase {
  /// Constructor
  NewPictogramPasswordBloc(this._api);

  final Api _api;
  GirafUserModel _user = GirafUserModel();

  /// The username for the citizen that one is creating a password for.
  late String? userName;

  /// The display name for the citizen that one is creating a password for.
  late String? displayName;

  /// The profile picture for the citizen that one is creating a password for.
  late List<int>? profilePicture;

  /// Controller that contains the stream & sink of the pictogram password.
  final rx_dart.BehaviorSubject<String?> pictogramPasswordController =
      rx_dart.BehaviorSubject<String?>();

  /// To be called whenever somethings needs to be added to the controller.
  Sink<String?> get onPictogramPasswordChanged =>
      pictogramPasswordController.sink;

  /// Streams a bool that tells whether the password is valid.
  Stream<bool> get validPictogramPasswordStream =>
      pictogramPasswordController.stream.transform(_passwordValidation);

  /// This validation method just null-checks, as there is validation
  /// in the [PictogramPassword] widget.
  final StreamTransformer<String?, bool> _passwordValidation =
      StreamTransformer<String?, bool>.fromHandlers(
          handleData: (String? input, EventSink<bool> sink) {
    if (input == null) {
      sink.add(false);
    } else {
      sink.add(true);
    }
  });

  /// Creates a user with the given information.
  Stream<GirafUserModel> createCitizen() {
    return _api.account.register(userName!, pictogramPasswordController.value!,
        displayName!, profilePicture,
        departmentId: _user.department!, role: Role.Citizen);
  }

  /// Initializes the bloc.
  void initialize(
      String _userName, String _displayName, Uint8List _profilePicture) {
    reset();
    userName = _userName;
    displayName = _displayName;
    profilePicture = _profilePicture;
    _api.user.me().listen((GirafUserModel user) {
      _user = user;
    });
  }

  /// Resets the blocs variables, so that no information is stored.
  void reset() {
    userName = null;
    displayName = null;
    pictogramPasswordController.add(null);
    _user = GirafUserModel();
  }

  @override
  void dispose() {
    pictogramPasswordController.close();
  }
}
