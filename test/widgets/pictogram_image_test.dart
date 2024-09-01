// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import '../blocs/pictogram_bloc_test.dart';
import '../test_image.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }
}

void main() {
  late PictogramImageBloc bloc;
  late Api api;
  late MockPictogramApi pictogramApi;

  final PictogramModel pictogramModel = PictogramModel(
      id: 1,
      lastEdit: DateTime(2017, 9, 7, 17, 30),
      title: 'Title',
      accessLevel: AccessLevel.PUBLIC,
      imageUrl: 'http://any.tld',
      imageHash: 'null',
      userId: '1');

  setUp(() {
    api = Api('any');
    pictogramApi = MockPictogramApi();
    api.pictogram = pictogramApi;
    api.user = MockUserApi();
    bloc = PictogramImageBloc(api);

    // when(pictogramApi.getImage(pictogramModel.id!))
    //     .thenAnswer((_) => rx_dart.BehaviorSubject<Image>.seeded(sampleImage));

    when(pictogramApi.getImage(pictogramModel.id!) as Function())
        .thenAnswer((_) => (int id) {
              // Return the Stream<Image> based on the provided ID
              if (id == pictogramModel.id) {
                // Return the stream with the sample image
                return Stream<Image>.fromIterable(<Image>[sampleImage]);
              } else {
                // Handle other cases if needed
                throw Exception('Invalid pictogram ID');
              }
            });

    // when(pictogramApi.getImage(pictogramModel.id!)).thenAnswer((_) =>
    //   (int id) {
    //     // Return the Stream<Image> based on the provided ID
    //     if (id == pictogramModel.id) {
    //       // Return the stream with the sample image
    //       return Stream<Image>.fromIterable([sampleImage]);
    //     } else {
    //       // Handle other cases if needed
    //       throw Exception('Invalid pictogram ID');
    //     }
    //   });

    // when(pictogramApi.getImage(pictogramModel.id!)).thenAnswer((_) =>
    //   (int id) {
    //     // Return the Stream<Image> based on the provided ID
    //     if (id == pictogramModel.id) {
    //       // Return the stream with the sample image
    //       return Stream<Image>.fromIterable([sampleImage]);
    //     } else {
    //       // Handle other cases if needed
    //       throw Exception('Invalid pictogram ID');
    //     }
    //   });

    di.clearAll();
    di.registerDependency<PictogramImageBloc>(() => bloc);
  });

  testWidgets('takes PictogramModel and VoidCallback',
      (WidgetTester tester) async {
    await tester.pumpWidget(PictogramImage(
      pictogram: pictogramModel,
      onPressed: () {},
      key: const ValueKey<String>('pictogramModelKey'),
    ));
  });

  testWidgets('loads renders given image', (WidgetTester tester) async {
    await tester.pumpWidget(PictogramImage(
      pictogram: pictogramModel,
      onPressed: () {},
      key: const ValueKey<String>('pictogramModelKey'),
    ));

    final Finder f = find.byWidgetPredicate((Widget widget) {
      return widget is PictogramImage;
    });

    expect(f, findsOneWidget);

    final Completer<bool> waiter = Completer<bool>();
    bloc.image.listen(expectAsync1((Image image) async {
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      waiter.complete(true);
    }));
    await waiter.future;
  });

  testWidgets('triggers callback on tap', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();

    await tester.pumpWidget(PictogramImage(
      pictogram: pictogramModel,
      onPressed: () {
        done.complete(true);
      },
      key: const ValueKey<String>('callbackKey'),
    ));

    final Finder f = find.byWidgetPredicate((Widget widget) {
      return widget is StreamBuilder;
    });

    bloc.image.listen(expectAsync1((Image image) async {
      await tester.pump();
      await tester.tap(f);
    }));
    await done.future;
  });

  testWidgets('shows spinner on loading', (WidgetTester tester) async {
    await tester.pumpWidget(PictogramImage(
      pictogram: pictogramModel,
      onPressed: () {},
      key: const ValueKey<String>('pictogramModelKey'),
    ));

    final Finder f = find.byWidgetPredicate((Widget widget) {
      return widget is CircularProgressIndicator;
    });

    expect(f, findsOneWidget);

    final Completer<bool> waiter = Completer<bool>();
    bloc.image.listen(expectAsync1((Image image) async {
      await tester.pump();
      expect(f, findsNothing);
      waiter.complete(true);
    }));
    await waiter.future;
  });

  testWidgets('shows delete button when haveRights',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SingleChildScrollView(
        child: PictogramImage(
          pictogram: pictogramModel,
          onPressed: () {},
          haveRights: true,
          key: const ValueKey<String>('haveRightsKey'),
        ),
      ),
    ));
    expect(find.byType(GirafButton), findsOneWidget);
  });

  testWidgets('show delete button when comparing ids',
      (WidgetTester tester) async {
    late String id;
    final Completer<bool> done = Completer<bool>();
    api.user.me().listen((GirafUserModel model) {
      id = model.id!;
      done.complete(true);
    });

    await done.future;
    await tester.pumpWidget(MaterialApp(
      home: SingleChildScrollView(
        child: PictogramImage(
          pictogram: pictogramModel,
          onPressed: () {},
          haveRights: pictogramModel.userId == id,
          key: const ValueKey<String>('pictogramImageTestKey'),
        ),
      ),
    ));
    expect(find.byType(GirafButton), findsOneWidget);
  });

  testWidgets('deletebutton is not shown when image is not owned',
      (WidgetTester tester) async {
    await tester.pumpWidget(PictogramImage(
      pictogram: pictogramModel,
      onPressed: () {},
      haveRights: false,
      key: const ValueKey<String>('pictogramImageTestBtnKey'),
    ));
    expect(find.byType(GirafButton), findsNothing);
  });
}
