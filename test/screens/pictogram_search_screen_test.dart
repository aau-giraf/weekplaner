import 'dart:async';

import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/new_citizen_bloc.dart';
import 'package:weekplanner/blocs/pictogram_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import '../blocs/pictogram_bloc_test.dart';
import '../test_image.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  late PictogramBloc bloc;
  late Api api;
  late MockPictogramApi pictogramApi;
  late DisplayNameModel user;
  setUpAll(() {
    registerFallbackValue(MockRoute());
  });
  final PictogramModel pictogramModel = PictogramModel(
      id: 1,
      lastEdit: null,
      title: 'kat',
      accessLevel: AccessLevel.PROTECTED,
      imageUrl: 'http://any.tld',
      imageHash: null,
      userId: '1');

  setUp(() {
    api = Api('any');
    pictogramApi = MockPictogramApi();
    api.pictogram = pictogramApi;
    bloc = PictogramBloc(api);
    user =
        DisplayNameModel(id: '1', displayName: 'Anders and', role: 'Guardian');

    when(() => pictogramApi.getImage(pictogramModel.id!))
        .thenAnswer((_) => rx_dart.BehaviorSubject<Image>.seeded(sampleImage));

    di.clearAll();
    di.registerDependency<PictogramBloc>(() => bloc);
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<NewCitizenBloc>(() => NewCitizenBloc(api));
  });

  testWidgets('renders', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: ''))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(
        home: PictogramSearch(
      user: user,
    )));

    await tester.pump(const Duration(milliseconds: 41000));

    bloc.pictograms.listen((List<PictogramModel>? images) async {
      await tester.pump();
      expect(find.byType(PictogramImage), findsNWidgets(1));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Has Giraf App Bar', (WidgetTester tester) async {
    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: ''))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(
        home: PictogramSearch(
      user: user,
    )));

    expect(find.byWidgetPredicate((Widget widget) => widget is GirafAppBar),
        findsOneWidget);

    await tester.pump(const Duration(milliseconds: 11000));
  });

  testWidgets('Display spinner on loading', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    const String query = 'Kat';

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: query))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(
        home: PictogramSearch(
      user: user,
    )));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    bloc.pictograms.listen((List<PictogramModel>? images) async {
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      done.complete(true);
    });

    await done.future;
  });

  testWidgets('Displays PictogramImage on result', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    const String query = 'Kat';

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: query))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(MaterialApp(
        home: PictogramSearch(
      user: user,
    )));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    bloc.pictograms.listen((List<PictogramModel>? images) async {
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

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: query))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(
      MaterialApp(
        home: PictogramSearch(
          user: user,
        ),
        navigatorObservers: <NavigatorObserver>[mockObserver],
      ),
    );
    final Finder searchScreen = find.byType(PictogramSearch);
    expect(searchScreen, findsOneWidget);
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 11000));

    bloc.pictograms.listen((List<PictogramModel>? images) async {
      await tester.tap(find.byType(PictogramImage));
      await tester.pump();

      verify(() => mockObserver.didPop(any(), any()));

      final Finder imageFinder = find.byType(PictogramImage);
      final Finder matchFinder =
          find.descendant(of: searchScreen, matching: imageFinder);

      expect(matchFinder, findsOneWidget);
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Display text to user if no result is found after 10 seconds',
      (WidgetTester tester) async {
    const String query = 'Kat';

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: query))
        .thenAnswer(
            (_) => rx_dart.BehaviorSubject<List<PictogramModel>?>.seeded(null));

    await tester.pumpWidget(MaterialApp(
        home: PictogramSearch(
      user: user,
    )));
    await tester.enterText(find.byType(TextField), query);

    await tester.pump(const Duration(milliseconds: 11000));

    expect(find.byKey(const Key('timeoutWidget')), findsOneWidget);
  });

  testWidgets('Tap delete button triggers confirm popup',
      (WidgetTester tester) async {
    const String query = 'Kat';

    when(() => pictogramApi.getAll(
            page: bloc.latestPage, pageSize: pageSize, query: query))
        .thenAnswer((_) => BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[pictogramModel]));

    await tester.pumpWidget(
      MaterialApp(home: PictogramSearch(user: user)),
    );
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 11000));
    final Finder f = find.text('Slet');

    expect(f, findsOneWidget);

    await tester.tap(f);
    await tester.pump();

    expect(find.byType(GirafConfirmDialog), findsOneWidget);
  });
}
