import 'dart:async';

import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/offline_database/offline_db_handler.dart';
import 'package:flutter/material.dart';

import 'connectivity_api.dart';

/// User endpoints
class UserApi {
  /// Default constructor
  UserApi(this._http, this._connectivity)
      : _dbHandler = OfflineDbHandler.instance;

  /// Constructor with custom DbHandler
  UserApi.withMockDbHandler(this._http, this._connectivity, this._dbHandler);

  final Http _http;
  final ConnectivityApi _connectivity;
  final OfflineDbHandler _dbHandler;

  /// Find information about the currently authenticated user.
  Stream<GirafUserModel> me() => _connectivity.handle(() {
        final Future<GirafUserModel> me = _http
            .get('/')
            .map((Response res) => GirafUserModel.fromJson(res.json['data']))
            .first;
        _dbHandler.setMe(me);
        return me;
      }, () => _dbHandler.getMe());

  /// Find information on the user with the given ID
  ///
  /// [id] ID of the user
  Stream<GirafUserModel> get(String id) => _connectivity.handle(() async {
        final GirafUserModel user = await _http
            .get('/$id')
            .map((Response res) => GirafUserModel.fromJson(res.json['data']))
            .first;
        _dbHandler.insertUser(user);
        return user;
      }, () => _dbHandler.getUser(id));

  /// Get the role of the user with the username inputted
  ///
  /// [username] Username of the user
  Stream<int> role(String username) => _connectivity.handle(() async {
        final int role = await _http
            .get('/$username/role')
            .map<int>((Response res) => res.json['data'])
            .first;
        _dbHandler.updateUserRole(username, role);
        return role;
      }, () => _dbHandler.getUserRole(username));

  /// Updates the user with the information in GirafUserModel
  ///
  /// [user] The updated user
  Stream<void> update(GirafUserModel user) => _connectivity.handle(
      () async => _dbHandler.insertUser(await _http
          .put('/${user.id}', user.toJson())
          .map((Response res) => GirafUserModel.fromJson(res.json['data']))
          .first),
      () => _dbHandler.insertUser(user));

  /// Get user-settings for the user with the specified Id
  ///
  /// [id] Identifier of the GirafUser to get settings for
  Stream<SettingsModel?> getSettings(String id) =>
      _connectivity.handle(() async {
        try {
          final SettingsModel settings = await _http
              .get('/$id/settings')
              .map((Response res) => SettingsModel.fromJson(res.json['data']))
              .first;

          if (!await _dbHandler.userExists(id)) {
            // Get the user if it does not already exist in the database
            await get(id).first;
          }

          await _dbHandler.insertUserSettings(id, settings);

          return settings;
        } catch (error) {
          throw Exception('Error with User/v1/[id]/settings ' + id);
        }
      }, () => _dbHandler.getUserSettings(id));

  /// Updates the user settings for the user with the provided id
  ///
  /// [id] Identifier of the GirafUser to update settings for
  /// [settings] reference to a Settings containing the new settings
  Stream<void> updateSettings(String id, SettingsModel settings) =>
      _connectivity.handle(() async {
        _http.put('/$id/settings', settings.toJson()).toList();
        return _dbHandler.insertUserSettings(id, settings);
      }, () => _dbHandler.insertUserSettings(id, settings));

  /// Deletes the user icon for a given user
  ///
  /// [id] Identifier for the user to which the icon should be deleted
  // TODO: Offline mode needs to be implemented
  Stream<bool> deleteIcon(String id) =>
      _http.delete('/$id/icon').map((Response res) => res.statusCode() == 200);

  /// Gets the raw user icon for a given user
  ///
  /// [id] Identifier of the GirafUser to get icon for
  // TODO: Offline mode needs to be implemented
  Stream<Image> getIcon(String id) => _http
      .get('/$id/icon/raw')
      .map((Response res) => Image.memory(res.response.bodyBytes));

  /// NYI
  // TODO: Offline mode needs to be implemented
  Stream<bool>? updateIcon() {
    // TODO(boginw): implement this
    return null;
  }

  /// Gets the citizens of the user with the provided id. The provided user must
  /// be a guardian
  ///
  /// [id] Identifier of the GirafUser to get citizens for
  // TODO: Offline mode needs to be implemented
  Stream<List<DisplayNameModel>> getCitizens(String id) => _http
      .get('/$id/citizens')
      .map((Response res) => List<Map<String, dynamic>>.from(res.json['data'])
          .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
          .toList());

  /// Gets the guardians for the specific citizen corresponding to the
  /// provided id.
  ///
  /// [id] Identifier for the citizen to get guardians for
  /// TODO: Offline mode needs to be implemented
  Stream<List<DisplayNameModel>> getGuardians(String id) => _http
      .get('/$id/guardians')
      .map((Response res) => List<Map<String, dynamic>>.from(res.json['data'])
          .map((Map<String, dynamic> val) => DisplayNameModel.fromJson(val))
          .toList());

  /// Adds relation between the authenticated user (guardian) and an
  /// existing citizen.
  ///
  /// [guardianId] The guardian
  /// [citizenId] The citizen to be added to the guardian
  /// TODO: Offline mode needs to be implemented
  Stream<bool> addCitizenToGuardian(String guardianId, String citizenId) =>
      _http
          .post('/$guardianId/citizens/$citizenId')
          .map((Response res) => res.statusCode() == 200);

  /// Adds relation between the authenticated user (trustee) and an
  /// existing citizen.
  ///
  /// [trusteeId] The trustee
  /// [citizenId] The citizen to be added to the guardian
  ///
  Stream<bool> addCitizenToTrustee(String trusteeId, String citizenId) => _http
      .post('/$trusteeId/citizens/$citizenId')
      .map((Response res) => res.statusCode() == 200);
}
