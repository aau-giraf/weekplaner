import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/week_base_model.dart';
import 'package:weekplanner/models/week_template_model.dart';

void main() {
  final Map<String, dynamic> response = <String, dynamic>{
    'departmentKey': 1,
    'id': 1,
    'thumbnail': <String, dynamic>{
      'id': 1,
      'lastEdit': '2019-03-04T13:14:08.839432',
      'title': 'Epik',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/1/image/raw',
      'imageHash': 'bjQ6eiEnZPp3CbW06iLZ6w=='
    },
    'name': 'SkabelonUge',
    'days': <dynamic>[
      <String, dynamic>{
        'day': 1,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 1,
                'lastEdit': '2019-03-04T13:14:08.839432',
                'title': 'Epik',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/1/image/raw',
                'imageHash': 'bjQ6eiEnZPp3CbW06iLZ6w=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 25,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 76,
                'lastEdit': '2019-03-04T13:14:08.853229',
                'title': 'alfabet',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/76/image/raw',
                'imageHash': 'M3VYTIo8N47tsQ7pG5N8dA=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 46,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 75,
                'lastEdit': '2019-03-04T13:14:08.853294',
                'title': 'alle',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/75/image/raw',
                'imageHash': 'mZfa7s0eJJnWhC8VwPduNw=='
              }
            ],
            'order': 2,
            'state': 2,
            'id': 45,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 74,
                'lastEdit': '2019-03-04T13:14:08.853315',
                'title': 'alting',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/74/image/raw',
                'imageHash': 'mZfa7s0eJJnWhC8VwPduNw=='
              }
            ],
            'order': 3,
            'state': 2,
            'id': 44,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 73,
                'lastEdit': '2019-03-04T13:14:08.853361',
                'title': 'antal',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/73/image/raw',
                'imageHash': 'w0X7ms1Nqm/bZTw5qCPdCg=='
              }
            ],
            'order': 4,
            'state': 2,
            'id': 43,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 2,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 72,
                'lastEdit': '2019-03-04T13:14:08.853379',
                'title': 'berøre',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/72/image/raw',
                'imageHash': 'EHiOxcBG/a9zSUN9rVJWCQ=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 42,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 71,
                'lastEdit': '2019-03-04T13:14:08.853395',
                'title': 'bogstav',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/71/image/raw',
                'imageHash': 'CCxICqlqqaPbk2Iji9Q89A=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 41,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 70,
                'lastEdit': '2019-03-04T13:14:08.853420',
                'title': 'delmængde',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/70/image/raw',
                'imageHash': 'busi6gAXN9r9yPJByMGdEA=='
              }
            ],
            'order': 2,
            'state': 2,
            'id': 40,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 69,
                'lastEdit': '2019-03-04T13:14:08.853446',
                'title': 'division',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/69/image/raw',
                'imageHash': 'Q7QYFVWX7b0LKkVcvF81Mw=='
              }
            ],
            'order': 3,
            'state': 2,
            'id': 39,
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
                'id': 68,
                'lastEdit': '2019-03-04T13:14:08.853483',
                'title': 'en',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/68/image/raw',
                'imageHash': '3DMlWWRdyTPLqrUh/jELlw=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 38,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 67,
                'lastEdit': '2019-03-04T13:14:08.853498',
                'title': 'fantastisk',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/67/image/raw',
                'imageHash': 'UBDYrp1d5Y1P6PdoVVTunQ=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 37,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 77,
                'lastEdit': '2019-03-04T13:14:08.853542',
                'title': 'farve',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/77/image/raw',
                'imageHash': 'D0NMSX/ay+r+DsdOcPDs2A=='
              }
            ],
            'order': 2,
            'state': 2,
            'id': 36,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 66,
                'lastEdit': '2019-03-04T13:14:08.853560',
                'title': 'fem',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/66/image/raw',
                'imageHash': 'MHJVpfDDz7Z0HxN3xesdNA=='
              }
            ],
            'order': 3,
            'state': 2,
            'id': 35,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 64,
                'lastEdit': '2019-03-04T13:14:08.853574',
                'title': 'femininum',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/64/image/raw',
                'imageHash': 'tBY15aFv5C1sq+a3kc1/ng=='
              }
            ],
            'order': 4,
            'state': 2,
            'id': 34,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 4,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 69,
                'lastEdit': '2019-03-04T13:14:08.853446',
                'title': 'division',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/69/image/raw',
                'imageHash': 'Q7QYFVWX7b0LKkVcvF81Mw=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 33,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 71,
                'lastEdit': '2019-03-04T13:14:08.853395',
                'title': 'bogstav',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/71/image/raw',
                'imageHash': 'CCxICqlqqaPbk2Iji9Q89A=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 32,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 70,
                'lastEdit': '2019-03-04T13:14:08.853420',
                'title': 'delmængde',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/70/image/raw',
                'imageHash': 'busi6gAXN9r9yPJByMGdEA=='
              }
            ],
            'order': 2,
            'state': 2,
            'id': 31,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 72,
                'lastEdit': '2019-03-04T13:14:08.853379',
                'title': 'berøre',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/72/image/raw',
                'imageHash': 'EHiOxcBG/a9zSUN9rVJWCQ=='
              }
            ],
            'order': 3,
            'state': 2,
            'id': 30,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 5,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 1,
                'lastEdit': '2019-03-04T13:14:08.839432',
                'title': 'Epik',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/1/image/raw',
                'imageHash': 'bjQ6eiEnZPp3CbW06iLZ6w=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 29,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 70,
                'lastEdit': '2019-03-04T13:14:08.853420',
                'title': 'delmængde',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/70/image/raw',
                'imageHash': 'busi6gAXN9r9yPJByMGdEA=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 28,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 6,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 69,
                'lastEdit': '2019-03-04T13:14:08.853446',
                'title': 'division',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/69/image/raw',
                'imageHash': 'Q7QYFVWX7b0LKkVcvF81Mw=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 27,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 72,
                'lastEdit': '2019-03-04T13:14:08.853379',
                'title': 'berøre',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/72/image/raw',
                'imageHash': 'EHiOxcBG/a9zSUN9rVJWCQ=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 26,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      },
      <String, dynamic>{
        'day': 7,
        'activities': <dynamic>[
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 74,
                'lastEdit': '2019-03-04T13:14:08.853315',
                'title': 'alting',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/74/image/raw',
                'imageHash': 'mZfa7s0eJJnWhC8VwPduNw=='
              }
            ],
            'order': 0,
            'state': 2,
            'id': 47,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          },
          <String, dynamic>{
            'pictograms': <dynamic>[
              <String, dynamic>{
                'id': 72,
                'lastEdit': '2019-03-04T13:14:08.853379',
                'title': 'berøre',
                'accessLevel': 1,
                'imageUrl': '/v1/pictogram/72/image/raw',
                'imageHash': 'EHiOxcBG/a9zSUN9rVJWCQ=='
              }
            ],
            'order': 1,
            'state': 2,
            'id': 48,
            'isChoiceBoard': false,
            'choiceBoardName': null,
            'timer': null,
            'title': ''
          }
        ]
      }
    ]
  };

  test('Should be able to instatiate via JSON', () {
    final WeekTemplateModel template = WeekTemplateModel.fromJson(response);

    expect(template.departmentKey, response['departmentKey']);
    expect(template.id, response['id']);
    weekBaseTest(template, response);
  });

  test('Should throw exception when JSON is null', () {
    expect(() => WeekTemplateModel.fromJson(null), throwsFormatException);
  });

  test('Should be able to serialize to JSON', () {
    final WeekTemplateModel template = WeekTemplateModel.fromJson(response);

    expect(template.toJson(), response);
  });
}

void weekBaseTest(WeekBaseModel wb, Map<String, dynamic> response) {
  expect(wb.thumbnail!.toJson(), response['thumbnail']);
  expect(wb.name, response['name']);
  expect(wb.days!.length, 7);
  expect(wb.days![0].toJson(), response['days'][0]);
  expect(wb.days![1].toJson(), response['days'][1]);
  expect(wb.days![2].toJson(), response['days'][2]);
  expect(wb.days![3].toJson(), response['days'][3]);
  expect(wb.days![4].toJson(), response['days'][4]);
  expect(wb.days![5].toJson(), response['days'][5]);
  expect(wb.days![6].toJson(), response['days'][6]);
}
