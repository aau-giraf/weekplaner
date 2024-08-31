import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Throws when JSON is null', () {
    const Map<String, dynamic>? json = null; // ignore: avoid_init_to_null
    expect(() => PictogramModel.fromJson(json), throwsFormatException);
  });

  test('Can create from JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'lastEdit': '2017-05-26T14:53:00.660175',
      'title': 'Epik',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/1/image/raw',
      'imageHash': 'tns4KGE8xw3BigQj67jSpQ==',
      'userId': '1'
    };

    final PictogramModel model = PictogramModel.fromJson(json);

    expect(model.id, json['id']);
    expect(model.lastEdit, DateTime(2017, 05, 26, 14, 53, 00, 660, 175));
    expect(model.title, json['title']);
    expect(model.accessLevel, AccessLevel.PUBLIC);
    expect(model.imageUrl, json['imageUrl']);
    expect(model.imageHash, json['imageHash']);
    expect(model.userId, json['userId']);
  });

  test('Can convert to JSON map', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 1,
      'lastEdit': '2017-05-26T14:53:00.660175',
      'title': 'Epik',
      'accessLevel': 1,
      'imageUrl': '/v1/pictogram/1/image/raw',
      'imageHash': 'tns4KGE8xw3BigQj67jSpQ==',
      'userId': '1'
    };

    expect(PictogramModel.fromJson(json).toJson(), json);
  });
}
