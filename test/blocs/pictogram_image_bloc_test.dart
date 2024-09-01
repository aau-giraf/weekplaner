import 'package:async_test/async_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';

import '../test_image.dart';

class MockPictogramApi extends Mock implements PictogramApi {}

void main() {
  late PictogramImageBloc bloc;
  late Api api;
  late MockPictogramApi pictogramApi;

  setUp(() {
    api = Api('any');
    pictogramApi = MockPictogramApi();
    api.pictogram = pictogramApi;
    bloc = PictogramImageBloc(api);
  });

  test('Should be able load pictogram', async((DoneFn done) {
    final PictogramModel model = PictogramModel(
        id: 1,
        lastEdit: null,
        title: 'null',
        accessLevel: AccessLevel.PRIVATE,
        imageUrl: null,
        imageHash: null);

    when(() => pictogramApi.getImage(model.id!))
        .thenAnswer((_) => rx_dart.BehaviorSubject<Image>.seeded(sampleImage));

    bloc.image.listen((Image response) {
      expect(response, isNotNull);
      expect(response, equals(sampleImage));
      done();
    });

    bloc.load(model);
  }));

  test('Should dispose stream', async((DoneFn done) {
    bloc.image.listen((_) {}, onDone: done);
    bloc.dispose();
  }));
}
