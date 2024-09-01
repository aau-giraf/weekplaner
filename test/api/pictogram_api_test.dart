@Timeout(Duration(seconds: 5))

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/http/http_mock.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';

Future<void> main() async {
  HttpMock httpMock = HttpMock();
  PictogramApi pictogramApi = PictogramApi(httpMock);

  final List<PictogramModel> grams = <PictogramModel>[
    PictogramModel(
        id: 1,
        title: 'Cat#1',
        accessLevel: AccessLevel.PUBLIC,
        imageHash: '#',
        imageUrl: 'http://any',
        lastEdit: DateTime.now(),
        userId: '1'),
    PictogramModel(
        id: 2,
        title: 'Cat#2',
        accessLevel: AccessLevel.PRIVATE,
        imageHash: '#',
        imageUrl: 'http://any',
        lastEdit: DateTime.now(),
        userId: '2'),
  ];
  sqfliteFfiInit();
  setUp(() {
    httpMock = HttpMock();
    pictogramApi = PictogramApi(httpMock);
  });

  test('Should be able to search pictograms', () {
    pictogramApi
        .getAll(query: 'Cat', page: 0, pageSize: 10)
        .listen(expectAsync1((List<PictogramModel>? pictograms) {
      expect(pictograms!.map((PictogramModel gram) => gram.toJson()),
          grams.map((PictogramModel gram) => gram.toJson()));
    }));

    httpMock
        .expectOne(url: '?query=Cat&page=0&pageSize=10', method: Method.get)
        .flush(<String, dynamic>{
      'data': grams.map((PictogramModel gram) => gram.toJson()).toList(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Get Pictogram with specific ID', () {
    pictogramApi.get(grams[0].id!).listen(expectAsync1((PictogramModel model) {
      expect(model.toJson(), grams[0].toJson());
    }));

    httpMock
        .expectOne(url: '/${grams[0].id}', method: Method.get)
        .flush(<String, dynamic>{
      'data': grams[0].toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Create pictogram', () {
    pictogramApi.create(grams[0]).listen(expectAsync1((PictogramModel model) {
      expect(model.toJson(), grams[0].toJson());
    }));

    httpMock.expectOne(url: '/', method: Method.post).flush(<String, dynamic>{
      'data': grams[0].toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Update pictogram', () {
    pictogramApi.update(grams[0]).listen(expectAsync1((PictogramModel model) {
      expect(model.toJson(), grams[0].toJson());
    }));

    httpMock
        .expectOne(url: '/${grams[0].id}', method: Method.put)
        .flush(<String, dynamic>{
      'data': grams[0].toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Delete pictogram', () {
    pictogramApi.delete(grams[0].id!).listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/${grams[0].id}', method: Method.delete)
        .flush(<String, dynamic>{
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Updates pictogram image', () {
    final Uint8List image = Uint8List.fromList(<int>[
      1,
      2,
      3,
      4,
    ]);

    pictogramApi
        .updateImage(grams[0].id!, image)
        .listen(expectAsync1((PictogramModel model) {
      expect(model.id, grams[0].id);
    }));
    httpMock
        .expectOne(
            url: '/${grams[0].id}/image', method: Method.put, body: image)
        .flush(<String, dynamic>{
      'data': grams[0].toJson(),
      'success': true,
      'message': '',
      'errorKey': 'NoError',
    });
  });

  test('Get raw image', () {
    final Uint8List imagebytes = Uint8List.fromList(<int>[
      1,
      2,
      3,
      4,
    ]);

    pictogramApi
        .getImage(grams[0].id!)
        .listen(expectAsync1((Image imageWidget) {
      if (imageWidget.image is MemoryImage) {
        final MemoryImage currentImage = imageWidget.image as MemoryImage;
        expect(currentImage.bytes, imagebytes);
      } else {
        fail('Image is not a MemoryImage');
      }
    }));

    httpMock
        .expectOne(
            url: '/${grams[0].id}/image/raw',
            method: Method.get,
            statusCode: 200)
        .flush(imagebytes);
  });

  tearDown(() {
    httpMock.verify();
  });
}
