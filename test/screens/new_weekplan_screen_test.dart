import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/new_weekplan_bloc.dart';
import 'package:weekplanner/blocs/pictogram_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:weekplanner/screens/new_weekplan_screen.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import '../test_image.dart';

class MockNewWeekplanBloc extends NewWeekplanBloc {
  MockNewWeekplanBloc(this.api) : super(api);

  bool acceptAllInputs = true;
  Api api;

  @override
  Stream<bool> get validTitleStream => Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get validYearStream => Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get validWeekNumberStream => Stream<bool>.value(acceptAllInputs);

  @override
  Stream<PictogramModel> get thumbnailStream =>
      Stream<PictogramModel>.value(mockPictogram);

  @override
  Stream<bool> get allInputsAreValidStream => Stream<bool>.value(true);
}

class MockWeekApi extends Mock implements WeekApi {}

class MockPictogramApi extends Mock implements PictogramApi {}

final PictogramModel mockPictogram = PictogramModel(
    id: 1,
    lastEdit: null,
    title: 'title',
    accessLevel: AccessLevel.PROTECTED,
    imageUrl: 'http://any.tld',
    imageHash: null);

final WeekModel mockWeek = WeekModel(
    thumbnail: mockPictogram,
    days: null,
    name: 'Week',
    weekNumber: 1,
    weekYear: 2019);

final DisplayNameModel mockUser =
    DisplayNameModel(displayName: 'test', role: 'test', id: 'test');

late WeekplansBloc mockWeekplanSelector;

void main() {
  late MockNewWeekplanBloc mockBloc;
  late Api api;
  late bool savedWeekplan;

  setUpAll(() {
    registerFallbackValue(WeekModel());
  });

  setUp(() {
    api = Api('any');
    api.week = MockWeekApi();
    api.pictogram = MockPictogramApi();
    savedWeekplan = false;

    when(() => api.pictogram.getImage(mockPictogram.id!))
        .thenAnswer((_) => rx_dart.BehaviorSubject<Image>.seeded(sampleImage));

    when(() => api.week.update(any(), any(), any(), any())).thenAnswer((_) {
      savedWeekplan = true;
      return Stream<WeekModel>.value(mockWeek);
    });

    when(() => api.week.getNames(any())).thenAnswer(
      (_) {
        return Stream<List<WeekNameModel>>.value(<WeekNameModel>[
          WeekNameModel(
              name: mockWeek.name,
              weekNumber: mockWeek.weekNumber,
              weekYear: mockWeek.weekYear),
        ]);
      },
    );

    when(() => api.week.get(any(), any(), any())).thenAnswer(
      (_) {
        return Stream<WeekModel>.value(mockWeek);
      },
    );

    mockWeekplanSelector = WeekplansBloc(api);
    mockWeekplanSelector.load(mockUser);

    di.clearAll();
    di.registerDependency<WeekplansBloc>(() => mockWeekplanSelector);
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<PictogramBloc>(() => PictogramBloc(api));
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());

    mockBloc = MockNewWeekplanBloc(api);
    di.registerDependency<NewWeekplanBloc>(() => mockBloc);
  });

  testWidgets('Screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
  });

  testWidgets('The screen has a Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafAppBar && widget.title == 'Ny ugeplan'),
        findsOneWidget);
  });

  testWidgets('Input fields are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('Pictograms are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PictogramImage), findsOneWidget);
  });

  testWidgets('Buttons are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    expect(find.byType(GirafButton), findsNWidgets(1));
  });

  testWidgets('Error text is shown on invalid title input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Titel skal angives'), findsOneWidget);
  });

  testWidgets('No error text is shown on valid title input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = true;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Titel skal angives'), findsNothing);
  });

  testWidgets('Error text is shown on invalid year input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('År skal angives som fire cifre'), findsOneWidget);
  });

  testWidgets('No error text is shown on valid year input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = true;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('År skal angives som fire cifre'), findsNothing);
  });

  testWidgets('Error text is shown on invalid week number input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ugenummer skal være mellem 1 og 53'), findsOneWidget);
  });

  testWidgets('No error text is shown on valid week number input',
      (WidgetTester tester) async {
    mockBloc.acceptAllInputs = true;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ugenummer skal være mellem 1 og 53'), findsNothing);
  });

  testWidgets('Emojis are blacklisted from title field',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), '☺♥');
    await tester.pump();

    expect(find.text('☺♥'), findsNothing);
  });

  testWidgets('Click on thumbnail redirects to pictogram search screen',
      (WidgetTester tester) async {
    when(() => api.pictogram.getAll(page: 1, pageSize: pageSize, query: ''))
        .thenAnswer((_) => rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
            <PictogramModel>[mockPictogram]));
    mockBloc.acceptAllInputs = true;
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('WeekThumbnailKey')));
    await tester.pumpAndSettle();

    expect(find.byType(PictogramSearch), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 11000));
  });

  testWidgets(
      'Click on save weekplan button saves weekplan and return saved weekplan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), 'Test');
    await tester.enterText(
        find.byKey(const Key('WeekYearTextFieldKey')), '2020');
    await tester.enterText(
        find.byKey(const Key('WeekNumberTextFieldKey')), '20');
    mockBloc.onThumbnailChanged.add(mockWeek.thumbnail);
    await tester.tap(find.byKey(const Key('NewWeekplanSaveBtnKey')));

    expect(savedWeekplan, true);
  });

  testWidgets('Week plan is created even when there are no existing plans',
      (WidgetTester tester) async {
    when(() => api.week.getNames(any())).thenAnswer(
        (_) => Stream<List<WeekNameModel>>.value(<WeekNameModel>[]));

    mockWeekplanSelector = WeekplansBloc(api);
    mockWeekplanSelector.load(mockUser);

    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), 'Test');
    await tester.enterText(
        find.byKey(const Key('WeekYearTextFieldKey')), '2020');
    await tester.enterText(
        find.byKey(const Key('WeekNumberTextFieldKey')), '20');
    mockBloc.onThumbnailChanged.add(mockWeek.thumbnail);

    await tester.tap(find.byKey(const Key('NewWeekplanSaveBtnKey')));

    expect(savedWeekplan, true);
  });

  testWidgets('Should show overwrite dialog if trying to overwrite',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), mockWeek.name!);
    await tester.enterText(find.byKey(const Key('WeekYearTextFieldKey')),
        mockWeek.weekYear.toString());
    await tester.enterText(find.byKey(const Key('WeekNumberTextFieldKey')),
        mockWeek.weekNumber.toString());
    mockBloc.onThumbnailChanged.add(mockWeek.thumbnail);

    await tester.tap(find.byKey(const Key('NewWeekplanSaveBtnKey')));
    await tester.pumpAndSettle();
    expect(find.byType(GirafConfirmDialog), findsOneWidget);
    expect(
        find.text('Ugeplanen (uge: ' +
            mockWeek.weekNumber.toString() +
            ', år: ' +
            mockWeek.weekYear.toString() +
            ') eksisterer '
                'allerede. Vil du overskrive denne ugeplan?'),
        findsOneWidget);
  });

  testWidgets(
      'Should remove overwrite dialog when tapping the "Fortryd" button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), mockWeek.name!);
    await tester.enterText(find.byKey(const Key('WeekYearTextFieldKey')),
        mockWeek.weekYear.toString());
    await tester.enterText(find.byKey(const Key('WeekNumberTextFieldKey')),
        mockWeek.weekNumber.toString());
    mockBloc.onThumbnailChanged.add(mockWeek.thumbnail);

    await tester.tap(find.byKey(const Key('NewWeekplanSaveBtnKey')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ConfirmDialogCancelButton')));
    await tester.pumpAndSettle();

    expect(find.byType(GirafConfirmDialog), findsNothing);
    expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GirafAppBar && widget.title == 'Ny ugeplan'),
        findsOneWidget);
    expect(savedWeekplan, false);
  });

  testWidgets(
      'Saves weekplan when tapping the "Okay" button in Overwrite dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NewWeekplanScreen(
          user: mockUser,
          existingWeekPlans: mockWeekplanSelector.weekNameModels,
        ),
      ),
    );

    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('WeekTitleTextFieldKey')), mockWeek.name!);
    await tester.enterText(find.byKey(const Key('WeekYearTextFieldKey')),
        mockWeek.weekYear.toString());
    await tester.enterText(find.byKey(const Key('WeekNumberTextFieldKey')),
        mockWeek.weekNumber.toString());
    mockBloc.onThumbnailChanged.add(mockWeek.thumbnail);

    await tester.tap(find.byKey(const Key('NewWeekplanSaveBtnKey')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byType(GirafConfirmDialog), findsNothing);
    expect(savedWeekplan, true);
  });
}
