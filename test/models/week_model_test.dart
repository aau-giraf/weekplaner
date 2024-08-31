import 'package:weekplanner/models/week_base_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Map<String, dynamic>? response1 = <String, dynamic>{
    'name': 'Jacobs Plan II',
    'weekYear': 2019,
    'weekNumber': 10
  };

  final Map<String, dynamic>? response2 = <String, dynamic>{
    'weekYear': 2019,
    'weekNumber': 10,
    'thumbnail': <String, dynamic>{
      'id': 2,
      'lastEdit': '2014-05-14T06:20:18.000',
      'title': 'alfabet',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/2/image/raw',
      'imageHash': 'iLRm28Hp/amc2847ALSk0g=='
    },
    'name': 'Jacobs Plan II',
    'days': <dynamic>[
      <String, dynamic>{'day': 1, 'activities': <dynamic>[]},
      <String, dynamic>{
        'day': 2,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 1246,
                'lastEdit': '2014-05-14T06:29:07.000',
                'title': 'pade',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/1246/image/raw',
                'imageHash': 'tHJWezktGh8FUxQH3Bp/0Q=='
              }
            ],
            'order': 0,
            'state': 1,
            'id': 1238,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 3,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 5974,
                'lastEdit': '2014-05-14T07:03:37.000',
                'title': 'tegning',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/5974/image/raw',
                'imageHash': 'bWTcndsk24PK8ov19Q+J/A=='
              }
            ],
            'order': 0,
            'state': 4,
            'id': 1239,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 1199,
                'lastEdit': '2014-05-14T06:28:46.000',
                'title': 'målmand',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/1199/image/raw',
                'imageHash': 'OH9cCXWS4lj/n/F2asnwKA=='
              }
            ],
            'order': 1,
            'state': 1,
            'id': 1240,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 2512,
                'lastEdit': '2014-05-14T06:38:19.000',
                'title': 'buskort',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/2512/image/raw',
                'imageHash': '/YFdskOccdy3wRFEf4rmhA=='
              }
            ],
            'order': 2,
            'state': 1,
            'id': 1241,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{'day': 4, 'activities': <dynamic>[]},
      <String, dynamic>{'day': 5, 'activities': <dynamic>[]},
      <String, dynamic>{'day': 6, 'activities': <dynamic>[]},
      <String, dynamic>{'day': 7, 'activities': <dynamic>[]}
    ]
  };

  test('Should be able to instantiate from JSON', () {
    final WeekModel week1 = WeekModel.fromJson(response1!);
    final WeekModel week2 = WeekModel.fromJson(response2!);

    expect(week1.weekYear, response1['weekYear']);
    expect(week1.weekNumber, response1['weekNumber']);

    expect(week2.weekYear, response2['weekYear']);
    expect(week2.weekNumber, response2['weekNumber']);

    weekBaseTest(week1, response1);
    weekBaseTest(week2, response2);
  });

  test('Should be able to serialize to JSON', () {
    final WeekModel week1 = WeekModel.fromJson(response1!);
    final WeekModel week2 = WeekModel.fromJson(response2!);

    expect(week1.toJson(), response1);
    expect(week2.toJson(), response2);
  });
}

void weekBaseTest(WeekBaseModel wb, Map<String, dynamic> response) {
  expect(wb.name, response['name']);

  if (wb.thumbnail != null) {
    expect(wb.thumbnail!.toJson(), response['thumbnail']);
  } else {
    expect(wb.thumbnail, isNull);
  }

  if (wb.days != null) {
    expect(wb.days!.length, 7);
    expect(wb.days![0].toJson(), response['days'][0]);
    expect(wb.days![1].toJson(), response['days'][1]);
    expect(wb.days![2].toJson(), response['days'][2]);
    expect(wb.days![3].toJson(), response['days'][3]);
    expect(wb.days![4].toJson(), response['days'][4]);
    expect(wb.days![5].toJson(), response['days'][5]);
    expect(wb.days![6].toJson(), response['days'][6]);
  } else {
    expect(wb.days, isNull);
  }
}
