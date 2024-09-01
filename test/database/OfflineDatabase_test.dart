import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/http/http_mock.dart';
/*import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart' as orient;*/
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
/*import 'package:weekplanner/models/settings_model.dart';*/
import 'package:weekplanner/offline_database/offline_db_handler.dart';

import 'Offline_models.dart';

class MockOfflineDbHandler extends OfflineDbHandler {
  MockOfflineDbHandler._() : super();

  static final MockOfflineDbHandler instance = MockOfflineDbHandler._();
  @override
  Future<Database> initializeDatabase() async {
    sqfliteFfiInit();
    final String tempDir = Directory.current.path;
    String dbDir;
    Database db;
    if (tempDir.split(separator).last == 'test') {
      dbDir = join(tempDir, 'database');
    } else {
      dbDir = join(tempDir, 'test', 'database');
    }
    db = await databaseFactoryFfi.openDatabase(join(dbDir, 'girafTest.db'),
        options: OpenDatabaseOptions(version: 1));
    createTables(db);
    return db;
  }

  @override
  Future<String> get getPictogramDirectory async {
    final String tempDir = Directory.current.path;
    Directory imageDirectory;
    if (tempDir.split(separator).last == 'test') {
      imageDirectory = Directory(join(tempDir, 'pictograms'));
    } else {
      imageDirectory = Directory(join(tempDir, 'test', 'pictograms'));
    }
    imageDirectory.createSync(recursive: true);
    return imageDirectory.path;
  }

  @override
  Http getHttpObject() {
    return httpMock;
  }
}

final HttpMock httpMock = HttpMock();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  final MockOfflineDbHandler dbHandler = MockOfflineDbHandler.instance;
  tearDown(() async {
    await killAll(dbHandler);
  });

  test('Try to create the test db', () async {
    expect(await dbHandler.getCurrentDBVersion(), 1);
    // We might need this if something is wrong
    // in the tests and it doesn't close itself
    // dbHandler.closeDb();
  });

  test('Save data in the table for failed transactions', () async {
    const String testTransType = 'PUT';
    const String testBaseUrl = 'http://10.0.2.2:5000';
    const String testUrl = '/register';
    const String testTable = 'Users';
    const String testId = '1';
    dbHandler.saveFailedTransactions(testTransType, testBaseUrl, testUrl,
        body: jamesBody, tableAffected: testTable, tempId: testId);
    final Database db = await dbHandler.database;
    final List<Map<String, dynamic>> dbRes =
        await db.rawQuery('SELECT * FROM `FailedOnlineTransactions` '
            "WHERE tempId == '$testId'");
    expect(dbRes[0]['tempId'], testId);
    expect(dbRes[0]['body'], jamesBody.toString());
  });

  test('Perform a correct login attempt', () async {
    // The correct Password for the jamesBody user is 'TestPassword123'
    const String passAttempt = 'password';
    await dbHandler.insertUser(jamesbondTestUser);
    final bool testLogin =
        await dbHandler.login(jamesbondTestUser.username!, passAttempt);
    expect(testLogin, true);
  });

  test('Perform a incorrect login attempt', () async {
    // The correct Password for the jamesBody user is 'TestPassword123'
    const String passAttempt = 'notpassword';
    await dbHandler.insertUser(jamesbondTestUser);
    final bool testLogin =
        await dbHandler.login(jamesbondTestUser.username!, passAttempt);
    expect(testLogin, false);
  });

  test('Update a user with a new attribute', () async {
    await dbHandler.insertUser(jamesbondTestUser);
    expect((await dbHandler.getUser(jamesbondTestUser.id)).username,
        jamesbondTestUser.username);
    await dbHandler.insertUser(GirafUserModel(
        id: jamesbondTestUser.id,
        role: Role.Guardian,
        username: 'newUsername',
        displayName: 'user'));
    expect((await dbHandler.getUser(jamesbondTestUser.id)).username,
        'newUsername');
  });

  test('performs a successful login after password change', () async {
    const String oldPass = 'password';
    const String newPass = 'newpassword';

    await dbHandler.insertUser(jamesbondTestUser);
    expect(await dbHandler.login(jamesbondTestUser.username!, oldPass), true);
    await dbHandler.changePassword(jamesbondTestUser.id!, newPass);
    expect(await dbHandler.login(jamesbondTestUser.username!, newPass), true);
  });

  test('performs a failed login after password change', () async {
    const String oldPass = 'password';
    const String newPass = 'newpassword';

    await dbHandler.insertUser(jamesbondTestUser);
    expect(await dbHandler.login(jamesbondTestUser.username!, oldPass), true);
    await dbHandler.changePassword(jamesbondTestUser.id!, newPass);
    expect(await dbHandler.login(jamesbondTestUser.username!, oldPass), false);
  });

  //since this test deals with offline mode, it is not to be executed
  /*
  test('Get a user\'s settings', () async {
    await dbHandler.insertUser(jamesbondTestUser);
    await dbHandler.insertUserSettings(jamesbondTestUser.id, SettingsModel(
        orientation: orient.Orientation.Landscape,
        completeMark: CompleteMark.Checkmark, 
        cancelMark: CancelMark.Cross,
        defaultTimer: DefaultTimer.Hourglass,
        theme: GirafTheme.GirafGreen));
    expect(await dbHandler.getUserSettings(jamesbondTestUser.id), isNot(null));
  });
*/
  test('Update a user\'s settings', () async {
    //test to be created
  });

  test('Set and get a \'Me\' user', () async {
    dbHandler.setMe(jamesbondTestUser);
    expect(dbHandler.getMe(), jamesbondTestUser);
    expect(dbHandler.getMe(), isNot(edTestUser));
  });
}

Future<void> cleanUsers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Users`');
}

Future<void> cleanSettings(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Settings`');
}

Future<void> cleanGuardianRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`GuardianRelations`');
}

Future<void> cleanWeekTemplates(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`WeekTemplates`');
}

Future<void> cleanWeek(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Weeks`');
}

Future<void> cleanWeekdays(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Weekdays`');
}

Future<void> cleanPictograms(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Pictograms`');
}

Future<void> cleanActivities(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Activities`');
}

Future<void> cleanPictogramRelations(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`PictogramRelations`');
}

Future<void> cleanTimers(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`Timers`');
}

Future<void> cleanFailedOnlineTransactions(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`FailedOnlineTransactions`');
}

Future<void> cleanWeekDayColors(OfflineDbHandler dbHandler) async {
  final Database db = await dbHandler.database;
  await db.delete('`WeekDayColors`');
}

/// Clear the testing database of all information
Future<void> killAll(OfflineDbHandler dbHandler) async {
  await cleanWeekDayColors(dbHandler);
  await cleanFailedOnlineTransactions(dbHandler);
  await cleanTimers(dbHandler);
  await cleanPictogramRelations(dbHandler);
  await cleanActivities(dbHandler);
  await cleanPictograms(dbHandler);
  await cleanWeek(dbHandler);
  await cleanWeekdays(dbHandler);
  await cleanWeekTemplates(dbHandler);
  await cleanGuardianRelations(dbHandler);
  await cleanSettings(dbHandler);
  await cleanUsers(dbHandler);
}
