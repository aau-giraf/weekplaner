import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weekplanner/api_client.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:weekplanner/persistence/persistence_client.dart';

/// OfflineDbHandler is used for communication with the offline database
class OfflineDbHandler {
  ///Constructor for the dbhandler
  @visibleForTesting
  OfflineDbHandler();

  /// The current running instance of the database
  static final OfflineDbHandler instance = OfflineDbHandler();
  static Database? _database;

  late FutureOr<GirafUserModel> _me;

  /// Get the database, if it doesnt exist create it
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  /// Return the directory where pictograms are saved
  Future<String> get getPictogramDirectory async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final Directory imageDirectory =
        Directory(join(directory.path, 'pictograms'));
    imageDirectory.createSync();
    return imageDirectory.path;
  }

  /// Initiate the database
  Future<Database> initializeDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'offlineGiraf'),
      onCreate: (Database db, int version) => createTables(db),
      onUpgrade: (Database db, int oldVersion, int newVersion) =>
          createTables(db),
      onDowngrade: (Database db, int oldVersion, int newVersion) =>
          createTables(db),

      /// Remove this comment to enable foreign_keys
      /// By doing this, one must make sure that every fk constraint is met
      //onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      version: 1,
    );
  }

  ///Creates all of the tables in the DB
  Future<void> createTables(Database db) async {
    await db.transaction((Transaction txn) async {
      await txn.execute('''CREATE TABLE IF NOT EXISTS Settings (
          id integer NOT NULL PRIMARY KEY,
          orientation integer NOT NULL,
          completeMark integer NOT NULL,
          cancelMark integer NOT NULL,
          defaultTimer integer NOT NULL,
          timerSeconds integer DEFAULT NULL,
          activitiesCount integer DEFAULT NULL,
          theme integer NOT NULL,
          nrOfDaysToDisplayPortrait integer DEFAULT NULL,
          displayDaysRelativePortrait integer DEFAULT 1,
          nrOfDaysToDisplayLandscape integer DEFAULT NULL,
          displayDaysRelativeLandscape integer DEFAULT 0,
          greyScale integer DEFAULT 0,
          lockTimerControl integer DEFAULT 0,
          pictogramText integer DEFAULT 0,
          showPopup integer DEFAULT 0,
          nrOfActivitiesToDisplay integer DEFAULT 0,
          showOnlyActivities integer DEFAULT 0,
          showSettingsForCitizen integer DEFAULT 0)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS Users (
          id text NOT NULL PRIMARY KEY,
          role integer NOT NULL,
          roleName text DEFAULT NULL,
          username text DEFAULT NULL,
          displayName text NOT NULL,
          department integer DEFAULT NULL,
          password text NOT NULL,
          settingsId integer DEFAULT NULL,
          UNIQUE(username),
          CONSTRAINT FK_Users_Settings_SettingsKey
          FOREIGN KEY(settingsId)
          REFERENCES Settings(id) ON DELETE RESTRICT)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS GuardianRelations (
          citizenId text NOT NULL,
          guardianId text NOT NULL,
          PRIMARY KEY(citizenId, guardianId),
          CONSTRAINT FK_GuardianRelations_Users_CitizenId
          FOREIGN KEY(citizenId)
          REFERENCES Users(id) ON DELETE CASCADE,
          CONSTRAINT FK_GuardianRelations_Users_GuardianId
          FOREIGN KEY(guardianId)
          REFERENCES Users(id) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS WeekDayColors (
          settingsId integer NOT NULL,
          day integer NOT NULL,
          hexColor text COLLATE BINARY,
          PRIMARY KEY(settingsId, day),
          CONSTRAINT FK_WeekDayColors_Settings_SettingsId
          FOREIGN KEY(settingsId)
          REFERENCES Settings(id) ON DELETE CASCADE)''');

      await txn.execute('''CREATE TABLE IF NOT EXISTS Pictograms (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          accessLevel integer NOT NULL,
          lastEdit datetime NOT NULL,
          title text NOT NULL,
          imageHash	text COLLATE BINARY,
          onlineId integer NOT NULL,
          UNIQUE(title, onlineId))''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS WeekTemplates (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          name text COLLATE BINARY,
          thumbnailKey integer NOT NULL,
          onlineId integer NOT NULL,
          department integer,
          CONSTRAINT FK_WeekTemplates_Pictograms_ThumbnailKey
          FOREIGN KEY(thumbnailKey)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS Weeks (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          girafUserId text NOT NULL,
          name text COLLATE BINARY,
          thumbnailKey integer NOT NULL,
          weekNumber integer NOT NULL,
          weekYear integer NOT NULL,
          CONSTRAINT FK_Weeks_AspNetUsers_GirafUserId
          FOREIGN KEY(girafUserId)
          REFERENCES Users(id) ON DELETE CASCADE,
          CONSTRAINT FK_Weeks_Pictograms_ThumbnailKey
          FOREIGN KEY(thumbnailKey)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS Weekdays (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          day integer NOT NULL,
          weekId integer DEFAULT NULL,
          weekTemplateId integer DEFAULT NULL,
          CONSTRAINT FK_Weekdays_WeekTemplates_WeekTemplateId
          FOREIGN KEY(weekTemplateId)
          REFERENCES WeekTemplates(onlineId) ON DELETE CASCADE,
          CONSTRAINT FK_Weekdays_Weeks_WeekId
          FOREIGN KEY(weekId)
          REFERENCES Weeks(id) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS Timers (
          key integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          startTime integer NOT NULL,
          progress integer NOT NULL,
          fullLength integer NOT NULL,
          paused integer NOT NULL)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS Activities (
          key integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          orderValue integer NOT NULL,
          otherKey integer NOT NULL,
          state integer NOT NULL,
          timerKey integer DEFAULT NULL,
          isChoiceBoard integer NOT NULL DEFAULT 0,
          CONSTRAINT FK_Activities_Timers_TimerKey
          FOREIGN KEY(timerKey)
          REFERENCES Timers(key) ON DELETE SET NULL,
          CONSTRAINT FK_Activities_Weekdays_OtherKey
          FOREIGN KEY(otherKey)
          REFERENCES Weekdays(id) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS PictogramRelations (
          activityId integer NOT NULL,
          pictogramId integer NOT NULL,
          PRIMARY KEY(activityId,pictogramId),
          CONSTRAINT FK_PictogramRelations_Activities_ActivityId
          FOREIGN KEY(activityId)
          REFERENCES Activities(key) ON DELETE CASCADE,
          CONSTRAINT FK_PictogramRelations_Pictograms_PictogramId
          FOREIGN KEY(pictogramId)
          REFERENCES Pictograms(onlineId) ON DELETE CASCADE)''');
      await txn.execute('''CREATE TABLE IF NOT EXISTS FailedOnlineTransactions (
          id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
          type text NOT NULL,
          url text NOT NULL,
          body text,
          tableAffected text,
          tempId text)''');
    });
  }

  /// Save failed online transactions
  /// [type] transaction type
  /// [baseUrl] baseUrl from the http
  /// [url] Url to send the transaction to
  /// [body] the json to send to the online database
  /// [tableAffected] NEEDS to be set when we try to create objects with public
  /// id's we need to have syncronized between the offline and online database
  Future<void> saveFailedTransactions(String type, String baseUrl, String url,
      {Map<String, dynamic>? body,
      String? tableAffected,
      String? tempId}) async {
    final Database db = await database;
    await db.rawInsert('''INSERT INTO FailedOnlineTransactions
        (type, url, body, tableAffected, tempId)
        VALUES(?, ?, ?, ?, ?)''',
        <dynamic>[type, baseUrl + url, body.toString(), tableAffected, tempId]);
  }

  /// Remove a previously failed transaction from the
  /// offline database when it succeeds
  Future<void> removeFailedTransaction(int id) async {
    final Database db = await database;
    await db.rawDelete(
        'DELETE FROM FailedOnlineTransactions WHERE id = ?', <dynamic>[id]);
  }

  /// Retry sending the failed changes to the online database
  Future<void> retryFailedTransactions() async {
    // TODO: Is not implemented correctly
    /*final Database db = await database;

    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM FailedOnlineTransactions');
    if (dbRes.isNotEmpty) {
      final Http _http = getHttpObject();
      for (Map<String, dynamic> transaction in dbRes) {
        switch (transaction['type']) {
          case 'DELETE':
            _http.delete(transaction['url']).listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction['id']);
              }
            }).onError((Object error) {});
            break;
          case 'POST':
            _http
                .post(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction['id']);
                await updateIdInOfflineDb(
                    res.json['data'],
                    transaction['tableAffected'],
                    int.tryParse(transaction['tempId']));
              }
            }).onError((Object error) {});
            break;
          case 'PATCH':
            _http
                .patch(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction['id']);
              }
            }).onError((Object error) {});
            break;
          case 'PUT':
            _http
                .put(transaction['url'], transaction['body'])
                .listen((Response res) async {
              if (res.success()) {
                await removeFailedTransaction(transaction['id']);
              }
            }).onError((Object error) {});
            break;
          default:
            throw const HttpException('invalid request type');
        }
      }
    }*/
  }

  /// Exists to be able to override the http used for retry failed transactions
  Http getHttpObject() {
    return HttpClient(baseUrl: '', persist: PersistenceClient());
  }

  /// Update an Id in the offline DB with a new one from the online database,
  /// once the online is done creating them. The [json] contains the key
  /// [table] is the table to be changed
  /// [tempId] is the id assigned when the object was created offline
  Future<void> updateIdInOfflineDb(
      Map<String, dynamic> json, String table, int tempId) async {
    switch (table) {
      case 'Users':
        replaceTempIdUsers(tempId, int.tryParse(json['id'])!);
        break;
      case 'Pictograms':
        replaceTempIdPictogram(tempId, json['id']);
        break;
      case 'WeekTemplates':
        replaceTempIdWeekTemplate(tempId, json['id']);
        break;
      default:
        break;
    }
  }

  /// Replace the id of a User
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdUsers(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate(
        'UPDATE Users SET id = ? WHERE id = ?', <dynamic>[newId, oldId]);
    db.rawUpdate(
        'UPDATE GuardianRelations SET citizenId = ? WHERE citizenId = ?',
        <dynamic>[newId, oldId]);
    db.rawUpdate(
        'UPDATE GuardianRelations SET guardianId = ? WHERE guardianId = ?',
        <dynamic>[newId, oldId]);
    db.rawUpdate('UPDATE Weeks SET girafUserId = ? WHERE girafUserId = ?',
        <dynamic>[newId, oldId]);
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdPictogram(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate(
        'UPDATE Pictograms SET id = ? WHERE id = ?', <dynamic>[newId, oldId]);
    db.rawUpdate(
        'UPDATE WeekTemplates SET thumbnailKey = ? WHERE thumbnailKey = ?',
        <dynamic>[newId, oldId]);
    db.rawUpdate('UPDATE Weeks SET thumbnailKey = ? WHERE thumbnailKey = ?',
        <dynamic>[newId, oldId]);
    db.rawUpdate(
        'UPDATE PictogramRelations SET pictogramId = ? WHERE pictogramId = ?',
        <dynamic>[newId, oldId]);
  }

  /// Replace the id of a Pictogram
  /// Should be called to replace the id given by this class with the one in the
  /// online database, such that they are synchonized
  Future<void> replaceTempIdWeekTemplate(int oldId, int newId) async {
    final Database db = await database;
    db.rawUpdate('UPDATE WeekTemplates SET onlineId = ? WHERE onlineId = ?',
        <dynamic>[newId, oldId]);
    db.rawUpdate(
        'UPDATE Weekdays SET weekTemplateId = ? WHERE weekTemplateId = ?',
        <dynamic>[newId, oldId]);
  }

  // Account API functions
  /// Returns [true] if [password] matches the password saved for [username]
  Future<bool> login(String username, String password) async {
    final Database db = await database;
    return (await db.rawQuery('SELECT password FROM Users WHERE username = ?',
                <dynamic>[username]))
            .first['password'] ==
        password;
  }

  /// Do not call this function without ensuring that the password is
  /// successfully changed online
  /// change a password of a user with id [userId] to [newPassword]
  Future<void> changePassword(String userId, String newPassword) async {
    final Database db = await database;
    db.rawUpdate('UPDATE Users SET password = ? WHERE id = ?',
        <dynamic>[newPassword, userId]);
  }

  // User API functions
  /// Return the me value
  FutureOr<GirafUserModel> getMe() => _me;

  /// Set the me value
  void setMe(FutureOr<GirafUserModel> user) => _me = user;

  /// Checks if a user with [userId] already exists
  Future<bool> userExists(String userId) =>
      _existsInTable('Users', <String>['id'], <String>[userId]);

  /// Get a user with [userId] if it exists, otherwise returns null.
  Future<GirafUserModel> getUser(String? userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>?> users = await db
        .rawQuery('SELECT * FROM Users WHERE id = ?', <String>[userId!]);
    if (users.isNotEmpty) {
      return GirafUserModel.fromJson(users[0]);
    } else {
      return GirafUserModel.fromJson(null);
    }
  }

  /// Inserts the user if it does not already exist, otherwise updates it.
  Future<void> insertUser(GirafUserModel user) async {
    final Database db = await database;
    if (await userExists(user.id!)) {
      await _updateUser(user);
    } else {
      await db.rawInsert(
          '''INSERT INTO Users (id, role, roleName, username,
          displayName, department, password) VALUES (?, ?, ?, ?, ?, ?, ?)''',
          <dynamic>[
            user.id,
            user.role!.index,
            user.roleName,
            user.username,
            user.displayName,
            user.department,
            /* This password should be either set together with login on the
            account api, or just updated on login.
            Since only user api has been implemented for offline usage
            this will have to be done at some other time. */
            'password'
          ]);
    }
  }

  /// Update a user based on [user.id] with the values from [user]
  Future<void> _updateUser(GirafUserModel user) async {
    final Database db = await database;
    db.rawUpdate('''UPDATE Users SET role = ?, roleName = ?, username = ?,
        displayName = ?, department = ? WHERE id = ?''', <dynamic>[
      user.role!.index,
      user.roleName,
      user.username,
      user.displayName,
      user.department,
      user.id
    ]);
  }

  /// Return the role of a user through its username
  Future<int> getUserRole(String username) async {
    final Database db = await database;
    final List<Map<String, dynamic>> roles = await db.rawQuery(
        'SELECT role FROM Users WHERE username = ?', <String>[username]);
    if (roles.isNotEmpty) {
      return roles.first['role'];
    } else {
      return Role.Unknown.index;
    }
  }

  /// Update the role of a user through its username
  Future<int?> updateUserRole(String username, int role) async {
    final Database db = await database;
    if (await _existsInTable(
        'Users', <String>['username'], <String>[username])) {
      return db.rawUpdate('UPDATE Users SET role = ? WHERE username = ?',
          <dynamic>[role, username]);
    }

    return null;
  }

  /// Get the settings for a user with the id: [userId]
  Future<SettingsModel?> getUserSettings(String userId) async {
    final Database db = await database;
    try {
      final Map<String, dynamic> settings = (await db.rawQuery(
              '''SELECT * FROM Settings WHERE
          id = (SELECT settingsId FROM Users WHERE id = ?)''',
              <String>[userId]))
          .first;
      final List<Map<String, dynamic>> weekdayColors = await db.rawQuery(
          'SELECT * FROM WeekDayColors WHERE settingsId = ?',
          <int>[settings['id']]);
      return SettingsModel.fromDatabase(settings, weekdayColors);
    } catch (error) {
      return null;
    }
  }

  /// Insert [settings] for user with the specified [userId]
  Future<void> insertUserSettings(String userId, SettingsModel settings) async {
    final Database db = await database;
    if (await _existsInTable(
        'Users', <String>['id', 'settingsId'], <dynamic>[userId, null])) {
      final int settingsId = await db.rawInsert(
          '''INSERT INTO SETTINGS
        (orientation, completeMark, cancelMark, defaultTimer, timerSeconds,
        activitiesCount, theme, nrOfDaysToDisplayPortrait, 
        displayDaysRelativePortrait, nrOfDaysToDisplayLandscape,
        displayDaysRelativeLandscape, greyScale, lockTimerControl,
        pictogramText, showPopup,
        nrOfActivitiesToDisplay, showOnlyActivities, 
        showSettingsForCitizen) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          <dynamic>[
            settings.orientation!.index,
            settings.completeMark!.index,
            settings.cancelMark!.index,
            settings.defaultTimer!.index,
            settings.timerSeconds,
            settings.activitiesCount,
            settings.theme!.index,
            settings.nrOfDaysToDisplayPortrait,
            settings.displayDaysRelativePortrait,
            settings.nrOfDaysToDisplayLandscape,
            settings.displayDaysRelativeLandscape,
            settings.greyscale,
            settings.lockTimerControl,
            settings.pictogramText,
            settings.showPopup,
            settings.nrOfActivitiesToDisplay,
            settings.showOnlyActivities,
            settings.showSettingsForCitizen
          ]);
      await db.rawUpdate('UPDATE Users SET settingsId = ? WHERE id = ?',
          <dynamic>[settingsId, userId]);

      /* WeekDayColors is a list in SettingsModel,
         which means that they have to be saved in its own table */
      if (settings.weekDayColors != null) {
        //for (WeekdayColorModel weekdayColor in settings.weekDayColors) {
        //  insertSettingsWeekDayColor(settingsId, weekdayColor);
        //}
      }
    } else {
      _updateUserSettings(userId, settings);
    }
  }

  /// Update the settings with [settings] for a user with id: [userId]
  Future<void> _updateUserSettings(
      String userId, SettingsModel settings) async {
    final Database db = await database;

    final Object? settingsId = (await db.rawQuery(
            'SELECT settingsId FROM Users WHERE id = ?', <String>[userId]))
        .first['settingsId'];

    await db.rawUpdate(
        '''UPDATE Settings SET
        orientation = ?, completeMark = ?, cancelMark = ?, defaultTimer = ?,
        timerSeconds = ?, activitiesCount = ?, theme = ?, 
        nrOfDaysToDisplayPortrait = ?, displayDaysRelativePortrait = ?, 
        nrOfDaysToDisplayLandscape = ?, displayDaysRelativeLandscape = ?, 
        greyScale = ?, lockTimerControl = ?, 
        pictogramText = ?, showPopup = ?, nrOfActivitiesToDisplay = ?, 
        showOnlyActivities = ?, showSettingsForCitizen = ? WHERE id = ?''',
        <dynamic>[
          settings.orientation!.index,
          settings.completeMark!.index,
          settings.cancelMark!.index,
          settings.defaultTimer!.index,
          settings.timerSeconds,
          settings.activitiesCount,
          settings.theme!.index,
          settings.nrOfDaysToDisplayPortrait,
          settings.displayDaysRelativePortrait,
          settings.nrOfDaysToDisplayLandscape,
          settings.displayDaysRelativeLandscape,
          settings.greyscale,
          settings.lockTimerControl,
          settings.pictogramText,
          settings.showPopup,
          settings.nrOfActivitiesToDisplay,
          settings.showOnlyActivities,
          settings.showSettingsForCitizen,
          settingsId
        ]);

    /* WeekDayColors is a list in SettingsModel,
       which means that they have to be saved in its own table 
    if (settings.weekDayColors != null) {
      for (WeekdayColorModel weekdayColor in settings.weekDayColors) {
        //insertSettingsWeekDayColor(settingsId, weekdayColor);
      }
    }*/
  }

  /// Insert [weekdayColor] for settings with id: [settingsId]
  /// If a weekdayColor with the provided [settingsId] and [weekdayColor.day]
  /// does already exist in the database, it will be updated instead.

  Future<void> insertSettingsWeekDayColor(
      int settingsId, WeekdayColorModel weekdayColor) async {
    final Database db = await database;
    if (!await _existsInTable('WeekDayColors', <String>['settingsId', 'day'],
        <dynamic>[settingsId, weekdayColor.day!.index])) {
      db.rawInsert('''INSERT INTO WeekDayColors (settingsId, day, hexColor)
          VALUES (?, ?, ?)''', <dynamic>[
        settingsId,
        weekdayColor.day!.index,
        weekdayColor.hexColor
      ]);
    } else {
      _updateSettingsWeekDayColor(settingsId, weekdayColor);
    }
  }

  /// Update with [weekdayColor] for settings with id: [settingsId]
  Future<void> _updateSettingsWeekDayColor(
      int settingsId, WeekdayColorModel weekdayColor) async {
    final Database db = await database;
    db.rawUpdate('''UPDATE WeekDayColors SET hexColor = ?
        WHERE settingsId = ? AND day = ?''',
        <dynamic>[weekdayColor.hexColor, settingsId, weekdayColor.day!.index]);
  }

  /// Return list of citizens from database based on guardian id
  Future<List<DisplayNameModel>> getCitizens(String id) async {
    // TODO: This needs to be implemented
    throw UnimplementedError();
  }

  /// Return list of guardians from database based on citizen id
  Future<List<DisplayNameModel>> getGuardians(String id) async {
    // TODO: This needs to be implemented
    throw UnimplementedError();
  }

  /// Add a [guardianId] to a [citizenId]
  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) async {
    // TODO: This needs to be implemented
    throw UnimplementedError();
  }

  /// Checks if the [values] of [columns] exists in the [table]
  /// [columns.length] should be equal to [values.length]
  Future<bool> _existsInTable(
      String table, List<String> columns, List<dynamic> values) async {
    if (columns.length != values.length) {
      throw Exception('The length of [values] and [columns] should match.');
    }
    final Database db = await database;

    /* This is responsible for generating the where clause string for the query.
       Values that are null, should be checked with "IS NULL",
       instead of "= null" */
    final List<int> indicesWhereNull = <int>[];
    for (int i = 0; i < values.length; i++) {
      if (values[i] == null) {
        indicesWhereNull.add(i);
      }
    }
    String whereClause = indicesWhereNull.contains(0)
        ? '${columns[0]} IS NULL'
        : '${columns[0]} = ?';
    for (int i = 1; i < values.length; i++) {
      whereClause += indicesWhereNull.contains(i)
          ? ' AND ${columns[i]} IS NULL'
          : ' AND ${columns[i]} = ?';
    }

    return (await db.rawQuery('SELECT * FROM $table WHERE $whereClause',
            values.where((dynamic value) => value != null).toList()))
        .isNotEmpty;
  }

  /// Gets the version of the currently running db
  Future<int> getCurrentDBVersion() async {
    final Database db = await database;
    return db.getVersion();
  }

  /// Force close the db
  Future<void> closeDb() async {
    final Database db = await database;
    await db.close();
  }
}
