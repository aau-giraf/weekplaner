@Timeout(Duration(seconds: 5))

import 'dart:async';

import 'package:weekplanner/api/connectivity_api.dart';
import 'package:weekplanner/api/status_api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/http/http_mock.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:weekplanner/offline_database/offline_db_handler.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ConnectivityMock implements Connectivity {
  bool isConnected = true;

  @override
  Future<ConnectivityResult> checkConnectivity() async {
    if (!isConnected) {
      return ConnectivityResult.none;
    }
    return ConnectivityResult.wifi;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      throw UnimplementedError();
}

class DBHandlerMock implements OfflineDbHandler {
  late FutureOr<GirafUserModel> _authUser;

  @override
  Future<bool> addCitizenToGuardian(String guardianId, String citizenId) {
    return Future<bool>.value(true);
  }

  @override
  Future<bool> changePassword(String id, String newPassword) {
    // TODO(bogin): Is not implemented correctly
    throw UnimplementedError();
  }

  @override
  Future<void> closeDb() {
    // TODO(bogin): Implement closeDb
    throw UnimplementedError();
  }

  @override
  Future<void> createTables(Database db) {
    // TODO(bogin): Implement createTables
    throw UnimplementedError();
  }

  @override
  // TODO(bogin): Implement database
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<List<DisplayNameModel>> getCitizens(String id) {
    return Future<List<DisplayNameModel>>.value(<DisplayNameModel>[
      DisplayNameModel(
          displayName: 'Kurt', role: Role.SuperUser.toString(), id: '1'),
      DisplayNameModel(
          displayName: 'Hüttel', role: Role.SuperUser.toString(), id: '2')
    ]);
  }

  @override
  Future<int> getCurrentDBVersion() {
    // TODO(bogin): Implement getCurrentDBVersion
    throw UnimplementedError();
  }

  @override
  Future<List<DisplayNameModel>> getGuardians(String id) {
    return Future<List<DisplayNameModel>>.value(<DisplayNameModel>[
      DisplayNameModel(
          displayName: 'Kurt', role: Role.SuperUser.toString(), id: '1'),
      DisplayNameModel(
          displayName: 'Hüttel', role: Role.SuperUser.toString(), id: '2')
    ]);
  }

  @override
  Http getHttpObject() {
    // TODO(bogin): Implement getHttpObject
    throw UnimplementedError();
  }

  @override
  FutureOr<GirafUserModel> getMe() {
    return _authUser;
  }

  @override
  // TODO(bogin): Implement getPictogramDirectory
  Future<String> get getPictogramDirectory => throw UnimplementedError();

  @override
  Future<GirafUserModel> getUser(String? id) {
    return Future<GirafUserModel>.value(GirafUserModel(
        id: '1236',
        department: 3,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Kurt',
        username: 'SpaceLord67'));
  }

  @override
  Future<int> getUserRole(String username) {
    return Future<int>.value(3);
  }

  @override
  Future<SettingsModel> getUserSettings(String id) {
    return Future<SettingsModel>.value(SettingsModel(
        orientation: Orientation.Landscape,
        completeMark: CompleteMark.Checkmark,
        cancelMark: CancelMark.Cross,
        defaultTimer: DefaultTimer.PieChart,
        theme: GirafTheme.AndroidBlue,
        weekDayColors: <WeekdayColorModel>[
          WeekdayColorModel(day: Weekday.Monday, hexColor: '#123456')
        ]));
  }

  @override
  Future<Database> initializeDatabase() {
    // TODO(bogin): Implement initializeDatabase
    throw UnimplementedError();
  }

  @override
  Future<GirafUserModel> insertUser(GirafUserModel user) {
    return Future<GirafUserModel>.value(user);
  }

  @override
  Future<SettingsModel> insertUserSettings(
      String userId, SettingsModel settings) {
    return Future<SettingsModel>.value(settings);
  }

  @override
  Future<bool> login(String username, String password) {
    // TODO(bogin): Implement login
    throw UnimplementedError();
  }

  @override
  Future<void> removeFailedTransaction(int id) {
    // TODO(bogin): Implement removeFailedTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdPictogram(int oldId, int newId) {
    // TODO(bogin): Implement replaceTempIdPictogram
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdUsers(int oldId, int newId) {
    // TODO(bogin): Implement replaceTempIdUsers
    throw UnimplementedError();
  }

  @override
  Future<void> replaceTempIdWeekTemplate(int oldId, int newId) {
    // TODO(bogin): Implement replaceTempIdWeekTemplate
    throw UnimplementedError();
  }

  @override
  Future<void> retryFailedTransactions() {
    // TODO(bogin): Implement retryFailedTransactions
    throw UnimplementedError();
  }

  @override
  Future<void> saveFailedTransactions(String type, String baseUrl, String url,
      {Map<String, dynamic>? body, String? tableAffected, String? tempId}) {
    // TODO(bogin): Implement saveFailedTransactions
    throw UnimplementedError();
  }

  @override
  void setMe(FutureOr<GirafUserModel> model) {
    _authUser = model;
  }

  @override
  Future<void> updateIdInOfflineDb(
      Map<String, dynamic> json, String table, int tempId) {
    // TODO(bogin): Implement updateIdInOfflineDb
    throw UnimplementedError();
  }

  @override
  Future<int> updateUserRole(String username, int role) {
    return Future<int>.value(3);
  }

  @override
  Future<bool> userExists(String username) {
    return Future<bool>.value(true);
  }

  @override
  Future<void> insertSettingsWeekDayColor(
      int settingsId, WeekdayColorModel weekdayColor) {
    // TODO(bogin): Implement insertSettingsWeekDayColor
    throw UnimplementedError();
  }
}

Future<void> main() async {
  late ConnectivityMock connectivityMock;
  sqfliteFfiInit();
  late DBHandlerMock dbHandlerMock;
  late UserApi userApi;
  late HttpMock httpMock;

  final GirafUserModel user = GirafUserModel(
      id: '1236',
      department: 3,
      role: Role.Guardian,
      roleName: 'Guardian',
      displayName: 'Kurt',
      username: 'SpaceLord67');

  final SettingsModel settings = SettingsModel(
      orientation: Orientation.Landscape,
      completeMark: CompleteMark.Checkmark,
      cancelMark: CancelMark.Cross,
      defaultTimer: DefaultTimer.PieChart,
      theme: GirafTheme.AndroidBlue,
      weekDayColors: <WeekdayColorModel>[
        WeekdayColorModel(day: Weekday.Monday, hexColor: '#123456')
      ]);
  setUp(() {
    httpMock = HttpMock();
    connectivityMock = ConnectivityMock();
    dbHandlerMock = DBHandlerMock();
    userApi = UserApi.withMockDbHandler(
        httpMock,
        ConnectivityApi.withConnectivity(StatusApi(httpMock), connectivityMock),
        dbHandlerMock);
  });

  test('Should fetch authenticated user from online', () async {
    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the user api (on me())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should fetch authenticated user from offline', () {
    connectivityMock.isConnected = false;

    dbHandlerMock.setMe(user);

    userApi.me().listen(expectAsync1((GirafUserModel authUser) {
      expect(authUser.toJson(), user.toJson());
    }));
  });

  test('Should fetch user with ID', () async {
    userApi.get(user.id!).listen(expectAsync1((GirafUserModel? specUser) {
      expect(specUser!.toJson(), user.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should fetch user with ID from offline', () {
    connectivityMock.isConnected = false;
    userApi.get(user.id!).listen(expectAsync1((GirafUserModel? specUser) {
      expect(specUser!.toJson(), user.toJson());
    }));
  });

  test('Should get the role endpoint', () async {
    userApi.role(user.username!).listen(expectAsync1((int roleIndex) {
      expect(roleIndex, user.role!.index);
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.username}/role', method: Method.get)
        .flush(<String, dynamic>{
      'data': user.role!.index,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  test('Should get the role endpoint from offline', () {
    connectivityMock.isConnected = false;
    userApi.role(user.username!).listen(expectAsync1((int roleIndex) {
      expect(roleIndex, user.role!.index);
    }));
  });

  test('Should update user with ID', () async {
    userApi.update(user);

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}', method: Method.put)
        .flush(<String, dynamic>{
      'data': user.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should update user with ID from offline', () {
    connectivityMock.isConnected = false;
    userApi.update(user);
  });

  test('Should get settings from user with ID', () async {
    userApi
        .getSettings(user.id!)
        .listen(expectAsync1((SettingsModel? specSettings) {
      expect(specSettings!.toJson(), settings.toJson());
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.get)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should get settings from user with ID from offline', () {
    connectivityMock.isConnected = false;

    userApi
        .getSettings(user.id!)
        .listen(expectAsync1((SettingsModel? specSettings) {
      expect(specSettings!.toJson(), settings.toJson());
    }));
  });

  test('Should update settings from user with ID', () async {
    userApi.updateSettings(user.id!, settings);

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    // This is expecting a call to the status api (on status())
    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock
        .expectOne(url: '/${user.id}/settings', method: Method.put)
        .flush(<String, dynamic>{
      'data': settings.toJson(),
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should update settings from user with ID from offline', () {
    connectivityMock.isConnected = false;

    userApi.updateSettings(user.id!, settings);
  });

  tearDown(() {
    httpMock.verify();
  });
}
