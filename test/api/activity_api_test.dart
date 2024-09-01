import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/http/http_mock.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

Future<void> main() async {
  sqfliteFfiInit();
  late HttpMock httpMock;
  late ActivityApi activityApi;
  final DisplayNameModel mockUser =
      DisplayNameModel(id: '1', displayName: 'Test', role: 'Guardian');

  final PictogramModel mockPictogram = PictogramModel(
      id: 69,
      title: 'hi',
      accessLevel: AccessLevel.PUBLIC,
      lastEdit: DateTime.now(),
      imageHash: null,
      imageUrl: null);

  final ActivityModel mockActivity = ActivityModel(
      id: 1,
      state: ActivityState.Normal,
      isChoiceBoard: false,
      order: 0,
      pictograms: <PictogramModel>[mockPictogram],
      title: 'Test');

  final WeekModel mockWeek = WeekModel(
      thumbnail: mockPictogram,
      name: 'TestWeek',
      weekYear: 1999,
      weekNumber: 42,
      days: <WeekdayModel>[
        WeekdayModel(day: Weekday.Sunday, activities: <ActivityModel>[])
      ]);
  setUp(() {
    httpMock = HttpMock();
    activityApi = ActivityApi(httpMock);
  });

  test('Should update an activity state', () {
    activityApi
        .update(mockActivity, mockUser.id!)
        .listen(expectAsync1((ActivityModel response) {
      expect(response.toJson(), mockActivity.toJson());
    }));

    httpMock
        .expectOne(url: '/${mockUser.id}/update', method: Method.put)
        .flush(<String, dynamic>{
      'data': mockActivity.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should add an activity', () {
    activityApi
        .add(mockActivity, mockUser.id!, mockWeek.name!, mockWeek.weekYear,
            mockWeek.weekNumber, mockWeek.days!.first.day!)
        .listen(expectAsync1((ActivityModel response) {
      expect(response.toJson(), mockActivity.toJson());
    }));

    httpMock
        .expectOne(
            url: '/${mockUser.id}/${mockWeek.name}/${mockWeek.weekYear}/'
                '${mockWeek.weekNumber}/${mockWeek.days!.first.day!.index + 1}',
            method: Method.post)
        .flush(<String, dynamic>{
      'data': mockActivity.toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Should delete an activity', () {
    activityApi
        .delete(mockActivity.id, mockUser.id!)
        .listen(expectAsync1((bool response) {
      expect(response, true);
    }));

    httpMock
        .expectOne(
            url: '/${mockUser.id}/delete/${mockActivity.id}',
            method: Method.delete)
        .flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });
}
