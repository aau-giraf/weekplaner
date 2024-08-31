import 'dart:async';

import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';

/// Bloc to get settings for a user
/// Set settings, and listen for changes in them.
class SettingsBloc extends BlocBase {
  /// Default constructor
  SettingsBloc(this._api);

  final Api _api;

  /// Settings stream
  Stream<SettingsModel?> get settings => _settings.stream;

  /// Currently selected theme
  Stream<GirafTheme?> get theme => _theme.stream;

  /// List of available themes
  Stream<List<GirafTheme>> get themeList => _themeList.stream;
  final rx_dart.BehaviorSubject<List<GirafTheme>> _themeList =
      rx_dart.BehaviorSubject<List<GirafTheme>>.seeded(<GirafTheme>[]);

  final rx_dart.BehaviorSubject<GirafTheme?> _theme =
      rx_dart.BehaviorSubject<GirafTheme?>.seeded(null);

  final rx_dart.BehaviorSubject<SettingsModel?> _settings =
      rx_dart.BehaviorSubject<SettingsModel>();

  /// Load the settings for a user
  void loadSettings(DisplayNameModel user) {
    _api.user.getSettings(user.id!).listen((SettingsModel? settingsModel) {
      _settings.add(settingsModel);
    });
  }

  /// Load the settings for a giraf user
  void loadSettingsGirafUser(GirafUserModel user) {
    _api.user.getSettings(user.id!).listen((SettingsModel? settingsModel) {
      _settings.add(settingsModel);
    });
  }

  /// Update an existing settingsModel
  Stream<void> updateSettings(String userId, SettingsModel settingsModel) {
    return _api.user.updateSettings(userId, settingsModel);
  }

  ///Deletes the user
  void deleteUser(String userId) {
    _api.account.delete(userId).listen((bool deleted) {});
  }

  /// Set the theme to be used
  void setTheme(GirafTheme theme) {
    _theme.add(theme);
  }

  @override
  void dispose() {
    _settings.close();
  }
}
