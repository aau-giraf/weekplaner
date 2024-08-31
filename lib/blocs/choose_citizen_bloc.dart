import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/giraf_user_model.dart';

/// Bloc to obtain all citizens assigned to a guarding
class ChooseCitizenBloc extends BlocBase {
  /// Default Constructor
  ChooseCitizenBloc(this._api) {
    updateBloc();
  }

  /// The stream holding the citizens
  Stream<List<DisplayNameModel>> get citizen => _citizens.stream;

  /// Update the block with current users
  void updateBloc() {
    _api.user.me().flatMap((GirafUserModel user) {
      return _api.user.getCitizens(user.id!);
    }).listen((List<DisplayNameModel> citizens) {
      _citizens.add(citizens);
    }).onError((Object error) {
      if (error.toString() == '[ApiException]: UserHasNoCitizens') {
        // Do not return any citizens if the web-api throws UserHasNoCitzens.
        // See issue #826 on GitHub for more info.
        return null;
      } else {
        // Return the error if it is not a UserHasNoCitzens error.
        return Future<void>.error(error);
      }
    });
  }

  final Api _api;
  final rx_dart.BehaviorSubject<List<DisplayNameModel>> _citizens =
      rx_dart.BehaviorSubject<List<DisplayNameModel>>.seeded(
          <DisplayNameModel>[]);

  @override
  void dispose() {
    _citizens.close();
  }

  /// Method for finding the currently logged in Guardian
  Stream<GirafUserModel> get guardian {
    return _api.user.me();
  }
}
