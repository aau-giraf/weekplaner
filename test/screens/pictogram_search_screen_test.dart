import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/pictogram_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/api/api.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import '../blocs/pictogram_bloc_test.dart';
import '../test_image.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  PictogramBloc bloc;
  Api api;
  MockPictogramApi pictogramApi;

  final PictogramModel pictogramModel = PictogramModel(
      id: 1,
      lastEdit: null,
      title: null,
      accessLevel: null,
      imageUrl: 'http://any.tld',
      imageHash: null);

  setUp(() {
    api = Api('any');
    pictogramApi = MockPictogramApi();
    api.pictogram = pictogramApi;
    bloc = PictogramBloc(api);

    when(pictogramApi.getImage(pictogramModel.id))
        .thenAnswer((_) => rx_dart.BehaviorSubject<Image>.seeded(sampleImage));

    di.clearAll();
    di.registerDependency<PictogramBloc>((_) => bloc);
    di.registerDependency<AuthBloc>((_) => AuthBloc(api));
    di.registerDependency<PictogramImageBloc>((_) => PictogramImageBloc(api));
    di.registerDependency<ToolbarBloc>((_) => ToolbarBloc());
  });

  testWidgets('renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramSearch()));
  });

  testWidgets('Has Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramSearch()));

    expect(find.byWidgetPredicate((Widget widget) => widget is GirafAppBar),
        findsOneWidget);
  });

  testWidgets('Display spinner on loading', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    const String query = 'Kat';

    when(pictogramApi.getAll(page: 1, pageSize: 10, query: query)).thenAnswer(
        (_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(home: PictogramSearch()));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    bloc.pictograms.listen((List<PictogramModel> images) async {
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      if (images != null) {
        done.complete(true);
      }
    });

    await done.future;
  });

  testWidgets('Displays PictogramImage on result', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    const String query = 'Kat';

    when(pictogramApi.getAll(page: 1, pageSize: 10, query: query)).thenAnswer(
        (_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(home: PictogramSearch()));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    bloc.pictograms.listen((List<PictogramModel> images) async {
      await tester.pump();
      expect(find.byType(PictogramImage), findsOneWidget);
      done.complete(true);
    });

    await done.future;
  });

  testWidgets('Pops on selection', (WidgetTester tester) async {
    final MockNavigatorObserver mockObserver = MockNavigatorObserver();
    final Completer<bool> done = Completer<bool>();
    const String query = 'Kat';

    when(pictogramApi.getAll(page: 1, pageSize: 10, query: query)).thenAnswer(
        (_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(
      MaterialApp(
        home: PictogramSearch(),
        navigatorObservers: <NavigatorObserver>[mockObserver],
      ),
    );
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 11000));

    bloc.pictograms.listen((List<PictogramModel> images) async {
      await tester.pump();

      await tester.tap(find.byType(PictogramImage));

      final Route<dynamic> pushedRoute =
          verify(mockObserver.didPush(captureAny, any)).captured.single;

      expect(await pushedRoute.popped, pictogramModel);
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Display text to user if no result is found after 10 seconds',
          (WidgetTester tester) async {
    const String query = 'Kat';

    when(pictogramApi.getAll(page: 1, pageSize: 10, query: query)).thenAnswer(
            (_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            null));

    await tester.pumpWidget(MaterialApp(home: PictogramSearch()));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    expect(find.byKey(const Key('timeoutWidget')), findsOneWidget);

  });
}
