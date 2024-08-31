// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api_client.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_color_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/copy_activities_bloc.dart';
import 'package:weekplanner/blocs/pictogram_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/timer_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';
import 'package:weekplanner/screens/weekplan_screen.dart';
import 'package:weekplanner/widgets/bottom_app_bar_button_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_copy_activities_dialog.dart';
import 'package:weekplanner/widgets/pictogram_text.dart';
import 'package:weekplanner/widgets/weekplan_screen_widgets/activity_card.dart';
import 'package:weekplanner/widgets/weekplan_screen_widgets/weekplan_day_column.dart';

import '../mock_data.dart';

class MockActivityApi extends Mock implements ActivityApi {
  @override
  Stream<ActivityModel> update(ActivityModel activity, String userId) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }

  @override
  Stream<ActivityModel> updateTimer(ActivityModel activity, String userId) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }
}

void main() {
  late WeekModel mockWeek;
  late SettingsModel mockSettings;
  late List<ActivityModel> mockActivities;
  late List<PictogramModel> mockPictograms;
  late DisplayNameModel user;
  late WeekplanBloc weekplanBloc;
  late AuthBloc authBloc;
  late Api api;

  setUp(() {
    MockData mockData;
    mockData = MockData();
    mockWeek = mockData.mockWeek;
    mockSettings = mockData.mockSettings;
    mockActivities = mockData.mockActivities;
    mockPictograms = mockData.mockPictograms;
    user = mockData.mockUser;
    api = mockData.mockApi;
    api.pictogram = MockPictogramApi();
    authBloc = AuthBloc(api);
    authBloc.setMode(WeekplanMode.guardian);
    weekplanBloc = WeekplanBloc(api);
    di.clearAll();
    // We register the dependencies needed to build different widgets
    di.registerDependency<AuthBloc>(() => authBloc);
    di.registerDependency<WeekplanBloc>(() => weekplanBloc);
    di.registerDependency<Api>(() => api);
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<TimerBloc>(() => TimerBloc(api));
    di.registerDependency<ActivityBloc>(() => ActivityBloc(api));
    di.registerDependency<PictogramBloc>(() => PictogramBloc(api));
    di.registerDependency<CopyActivitiesBloc>(() => CopyActivitiesBloc());
  });
  Color getColorFromWeekdayColorModel(WeekdayColorModel weekdayColorModel) {
    final String hexColor = weekdayColorModel.hexColor!;
    hexColor.replaceFirst('#', '0xff');

    return Color(int.parse(hexColor));
  }

  void expectColorDayMatch(Weekday day, String color) {
    String dayString = '';
    if (day == Weekday.Monday) {
      dayString = 'Mandag';
    } else if (day == Weekday.Tuesday) {
      dayString = 'Tirsdag';
    } else if (day == Weekday.Wednesday) {
      dayString = 'Onsdag';
    } else if (day == Weekday.Thursday) {
      dayString = 'Torsdag';
    } else if (day == Weekday.Friday) {
      dayString = 'Fredag';
    } else if (day == Weekday.Saturday) {
      dayString = 'Lørdag';
    } else {
      dayString = 'Søndag';
    }

    final Finder findColor = find.byWidgetPredicate((Widget widget) =>
    widget is Card && widget.color == Color(int.parse(color)));
    final Finder findTitle = find.byWidgetPredicate(
            (Widget widget) => widget is Card && widget.key == Key(dayString));

    expect(find.descendant(of: findColor, matching: findTitle), findsOneWidget);
  }


  testWidgets('_weekplanRenders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();
    expect(find.byType(WeekplanScreen), findsOneWidget);
  });

  testWidgets('choice Board Showns In Weekplan',
          (WidgetTester tester) async {
        authBloc.setMode(WeekplanMode.citizen);
        mockActivities[0].state = ActivityState.Normal;
        mockActivities[0].isChoiceBoard = true;
        mockActivities[0].pictograms = mockPictograms;
        mockWeek.days![0].activities!.add(mockActivities[0]);

        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        expect(
            find.byKey(const Key('WeekPlanScreenChoiceBoard')), findsOneWidget);
      });

  testWidgets('activity Selector Shows Up When Activity Tapped',
          (WidgetTester tester) async {
        authBloc.setMode(WeekplanMode.citizen);
        mockActivities[0].state = ActivityState.Normal;
        mockActivities[0].isChoiceBoard = true;
        mockActivities[0].pictograms = mockPictograms;
        mockWeek.days![0].activities!.add(mockActivities[0]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('WeekPlanScreenChoiceBoard')));
        await tester.pumpAndSettle();

        expect(
            find.byKey(const Key('ChoiceBoardActivitySelector')),
            findsOneWidget);
      });

  testWidgets('has Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();
    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('has Edit Button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Rediger'), findsOneWidget);
  });

  testWidgets('_editButtonTogglesEditMode', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    bool currentEditMode = false;
    weekplanBloc.editMode.listen((bool editMode) {
      currentEditMode = editMode;
    });
    // Initial edit mode should be false
    expect(currentEditMode, false);

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    weekplanBloc.editMode.listen((bool editMode) {
      currentEditMode = editMode;
    });
    // After tapping the button edit mode should be true
    expect(currentEditMode, true);

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();
    weekplanBloc.editMode.listen((bool editMode) {
      currentEditMode = editMode;
    });
    // After tapping the button agian it should be false
    expect(currentEditMode, false);
  });

  testWidgets('empty Board When Empty', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();
    // After tapping the button edit mode should be true
    expect(find.byType(ActivityCard), findsNothing);
  });

  testWidgets('_activitiesGetACard', (WidgetTester tester) async {
    // We add an activity to monday and one to tuesday
    mockWeek.days![0].activities!.add(mockActivities[0]);
    mockWeek.days![1].activities!.add(mockActivities[1]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // After tapping the button edit mode should be true
    expect(find.byType(ActivityCard), findsNWidgets(2));
  });

  testWidgets('tapping Activity When Not Editing Pushes Activity Screen',
          (WidgetTester tester) async {
    //This test fails. This is likely because of ShowActivityScreen has som kind of problem :(
    await tester.pumpAndSettle();
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
          home: WeekplanScreen(
            mockWeek,
            user,
            key: UniqueKey(),
          )));
    await tester.pumpAndSettle();

      await tester.tap(find.byType(ActivityCard));
      await tester.pumpAndSettle();
      expect(find.byType(ShowActivityScreen), findsOneWidget);
  });

  testWidgets('tapping Activity When Editing Selects Activity',
          (WidgetTester tester) async {
        mockWeek.days![0].activities!.add(mockActivities[0]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        //We enter edit mode.
        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        expect(weekplanBloc.getNumberOfMarkedActivities(), 0);

        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();
        expect(weekplanBloc.getNumberOfMarkedActivities(), 1);

        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();
        expect(weekplanBloc.getNumberOfMarkedActivities(), 0);
      });

  testWidgets('marking Activity Renders Black Box',
          (WidgetTester tester) async {
        mockWeek.days![0].activities!.add(mockActivities[0]);

        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Rediger'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('isSelectedKey')), findsOneWidget);
      });

  testWidgets(
      '_cancel Copy Delete Undo Buttons Not Built When EditMode Is False',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));

        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is BottomAppBarButton &&
                widget.buttonText == 'Aflys' &&
                widget.buttonKey == 'CancelActivtiesButton'),
            findsNothing);

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is BottomAppBarButton &&
                widget.buttonText == 'Kopier' &&
                widget.buttonKey == 'CopyActivtiesButton'),
            findsNothing);

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is BottomAppBarButton &&
                widget.buttonText == 'Slet' &&
                widget.buttonKey == 'DeleteActivtiesButton'),
            findsNothing);

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is BottomAppBarButton &&
                widget.buttonText == 'Genoptag' &&
                widget.buttonKey == 'GenoptagActivtiesButton'),
            findsNothing);
      });

  testWidgets(
      '_cancel Copy Delete Undo Buttons Do Not Open Dialog When No Activities Selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Aflys' &&
            widget.buttonKey == 'CancelActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafConfirmDialog &&
                widget.title == 'Aflys aktiviteter'),
            findsNothing);

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Kopier' &&
            widget.buttonKey == 'CopyActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafCopyActivitiesDialog &&
                widget.title == 'Kopier aktiviteter'),
            findsNothing);

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Slet' &&
            widget.buttonKey == 'DeleteActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafConfirmDialog &&
                widget.title == 'Slet aktiviteter'),
            findsNothing);

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Genoptag' &&
            widget.buttonKey == 'GenoptagActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafConfirmDialog && widget.title == 'Genoptag'),
            findsNothing);
      });

  testWidgets('_cancelActivityButtonOpensDialogWhenActivitySelected',
          (WidgetTester tester) async {
        mockWeek.days![0].activities!.add(mockActivities[0]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        // Toggle edit mode by pressing the edit mode button
        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        // Selecting an activity
        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();

        // Tapping cancel activities button
        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Aflys' &&
            widget.buttonKey == 'CancelActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafConfirmDialog &&
                widget.title == 'Aflys aktiviteter'),
            findsOneWidget);
      });

  testWidgets('copyActivityButtonOpensDialogWhenActivitySelected',
          (WidgetTester tester) async {
        mockWeek.days![0].activities!.add(mockActivities[0]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        // Toggle edit mode by pressing the edit mode button
        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        // Selecting an activity
        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();

        // Tapping copy activities button
        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Kopier' &&
            widget.buttonKey == 'CopyActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafCopyActivitiesDialog &&
                widget.title == 'Kopier aktiviteter'),
            findsOneWidget);
      });

  testWidgets('deleteActivityButtonOpensDialogWhenActivitySelected',
          (WidgetTester tester) async {
        mockWeek.days![0].activities!.add(mockActivities[0]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        // Toggle edit mode by pressing the edit mode button
        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        // Selecting an activity
        await tester.tap(find.byType(ActivityCard));
        await tester.pumpAndSettle();

        // Tapping copy activities button
        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Slet' &&
            widget.buttonKey == 'DeleteActivtiesButton'));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((Widget widget) =>
            widget is GirafConfirmDialog &&
                widget.title == 'Slet aktiviteter'),
            findsOneWidget);
      });

  testWidgets('cancellingAnActivityWorks', (WidgetTester tester) async {
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    await tester.tap(find
        .byType(ActivityCard)
        .first);
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is BottomAppBarButton &&
        widget.buttonText == 'Aflys' &&
        widget.buttonKey == 'CancelActivtiesButton'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('IconCanceled')), findsNothing);

    await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets('_markingActivityAsCurrentAndUpdateWork',
          (WidgetTester tester) async {
        mockSettings.nrOfDaysToDisplayLandscape = 1;
        final int weekDay = DateTime
            .now()
            .weekday
            .toInt() - 1;
        mockWeek.days![weekDay].activities!.add(mockActivities[0]);
        mockWeek.days![weekDay].activities!.add(mockActivities[1]);
        await tester.pumpWidget(MaterialApp(
            home: WeekplanScreen(
              mockWeek,
              user,
              key: UniqueKey(),
            )));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('IconActive')), findsOneWidget);

        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        await tester.tap(find
            .byType(ActivityCard)
            .first);
        await tester.pumpAndSettle();

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Aflys' &&
            widget.buttonKey == 'CancelActivtiesButton'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('IconCanceled')), findsNothing);
        expect(find.byKey(const Key('IconActive')), findsOneWidget);

        await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
        expect(find.byKey(const Key('IconActive')), findsOneWidget);

        await tester.tap(find.byTooltip('Rediger'));
        await tester.pump();

        await tester.tap(find
            .byType(ActivityCard)
            .first);
        await tester.pumpAndSettle();

        await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is BottomAppBarButton &&
            widget.buttonText == 'Genoptag' &&
            widget.buttonKey == 'GenoptagActivtiesButton'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
        expect(find.byKey(const Key('IconActive')), findsOneWidget);

        await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('IconCanceled')), findsNothing);
        expect(find.byKey(const Key('IconActive')), findsOneWidget);
      });

  testWidgets('_resumingAnActivityWorks', (WidgetTester tester) async {
    //Create a cancel activity
    mockActivities[0].state = ActivityState.Canceled;
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    await tester.tap(find
        .byType(ActivityCard)
        .first);
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is BottomAppBarButton &&
        widget.buttonText == 'Genoptag' &&
        widget.buttonKey == 'GenoptagActivtiesButton'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('IconCanceled')), findsNothing);
  });

  testWidgets('_copyingAnActivityWorks', (WidgetTester tester) async {
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    expect(mockWeek.days![0].activities!.length, 1);
    expect(mockWeek.days![1].activities!.length, 0);

    // Toggle edit mode by pressing the edit mode button
    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    // Selecting an activity
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();

    // Tapping copy activities button
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is BottomAppBarButton &&
        widget.buttonText == 'Kopier' &&
        widget.buttonKey == 'CopyActivtiesButton'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('TueCheckbox')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('DialogConfirmButton')));
    await tester.pumpAndSettle();

    expect(mockWeek.days![0].activities!.length, 1);
    expect(mockWeek.days![1].activities!.length, 1);
  });

  testWidgets('_deletingAnActivityWorks', (WidgetTester tester) async {
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    expect(mockWeek.days![0].activities!.length, 1);

    // Toggle edit mode by pressing the edit mode button
    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    // Selecting an activity
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();

    // Tapping copy activities button
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is BottomAppBarButton &&
        widget.buttonText == 'Slet' &&
        widget.buttonKey == 'DeleteActivtiesButton'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
    await tester.pumpAndSettle();

    expect(mockWeek.days![0].activities!.length, 0);
  });

  testWidgets('_hasSevenSelectAllButtons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    expect(weekplanBloc.getNumberOfMarkedActivities(), 0);
    expect(find.byKey(const Key('SelectAllButton')), findsNWidgets(7));
  });

  testWidgets('_hasSevenDeselectAllButtons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();

    expect(weekplanBloc.getNumberOfMarkedActivities(), 0);
    expect(find.byKey(const Key('DeselectAllButton')), findsNWidgets(7));
  });

  testWidgets('_marksAllAndUnmarksAllActivitiesForGivenDay', (
      WidgetTester tester) async {
    // Adding two activities too monday
    mockWeek.days![0].activities!.add(mockActivities[0]);
    mockWeek.days![0].activities!.add(mockActivities[1]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rediger'));
    await tester.pump();
    expect(weekplanBloc.getNumberOfMarkedActivities(), 0);

    // Checking that the select all activities button works
    await tester.tap(find
        .byKey(const Key('SelectAllButton'))
        .first);
    await tester.pump();
    expect(weekplanBloc.getNumberOfMarkedActivities(), 2);

    // Checking that the Deselect all activities button works
    await tester.tap(find
        .byKey(const Key('DeselectAllButton'))
        .first);
    await tester.pump();
    expect(weekplanBloc.getNumberOfMarkedActivities(), 0);
  });

  testWidgets('_oneWeekdayRowIsCreatedInLandscapeModeForCitizen', (
      WidgetTester tester) async {
    mockSettings.nrOfDaysToDisplayLandscape = 1;
    authBloc.setMode(WeekplanMode.citizen);
    final WeekplanScreen weekplanScreen = WeekplanScreen(
      mockWeek,
      user,
      key: UniqueKey(),
    );

    await tester.pumpWidget(MaterialApp(home: weekplanScreen));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('SingleWeekdayRow')), findsOneWidget);
  });

  testWidgets('_fiveWeekdayColumnsAreCreatedInLandscapeModeForCitizen', (
      WidgetTester tester) async {
    mockSettings.nrOfDaysToDisplayLandscape = 5;
    authBloc.setMode(WeekplanMode.citizen);
    final WeekplanScreen weekplanScreen = WeekplanScreen(
      mockWeek,
      user,
      key: UniqueKey(),
    );

    await tester.pumpWidget(MaterialApp(home: weekplanScreen));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('SingleWeekdayRow')), findsNothing);
    expect(find.byType(WeekplanDayColumn), findsNWidgets(5));
  });

  testWidgets('_sevenWeekdayColumnsAreCreatedInLandscapeModeForCitizen', (
      WidgetTester tester) async {
    mockSettings.nrOfDaysToDisplayLandscape = 7;
    authBloc.setMode(WeekplanMode.citizen);
    final WeekplanScreen weekplanScreen = WeekplanScreen(
      mockWeek,
      user,
      key: UniqueKey(),
    );
    await tester.pumpWidget(MaterialApp(home: weekplanScreen));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('SingleWeekdayRow')), findsNothing);
    expect(find.byType(WeekplanDayColumn), findsNWidgets(7));
  });

  testWidgets('_sevenWeekdayColumnsAlwaysCreatedForGuardian', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    final WeekplanScreen weekplanScreen = WeekplanScreen(
      mockWeek,
      user,
      key: UniqueKey(),
    );
    await tester.pumpWidget(MaterialApp(home: weekplanScreen));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('SingleWeekdayRow')), findsNothing);
    expect(find.byType(WeekplanDayColumn), findsNWidgets(7));
  });

  testWidgets('_weekdayColorsInCorrectOrderRegardlessOfDBOrder', (
      WidgetTester tester) async {
    mockSettings.nrOfDaysToDisplayLandscape = 7;
    mockSettings.weekDayColors = <WeekdayColorModel>[
      WeekdayColorModel(day: Weekday.Saturday, hexColor: '0xffeeeeee'),
      WeekdayColorModel(day: Weekday.Tuesday, hexColor: '0xffaaaaaa'),
      WeekdayColorModel(day: Weekday.Wednesday, hexColor: '0xffbbbbbb'),
      WeekdayColorModel(day: Weekday.Monday, hexColor: '0xff999999'),
      WeekdayColorModel(day: Weekday.Thursday, hexColor: '0xffcccccc'),
      WeekdayColorModel(day: Weekday.Friday, hexColor: '0xffdddddd'),
      WeekdayColorModel(day: Weekday.Sunday, hexColor: '0xffffffff'),
    ];

    mockWeek.days = <WeekdayModel>[
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Monday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Friday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Saturday),
      WeekdayModel(activities: <ActivityModel>[], day: Weekday.Sunday)
    ];

    authBloc.setMode(WeekplanMode.citizen);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    for (WeekdayColorModel dayColor in mockSettings.weekDayColors!) {
      expectColorDayMatch(dayColor.day!, dayColor.hexColor!);
    }
  });

  testWidgets('_pictogramTextRendersWhenSettingsSetToDisplayText', (
      WidgetTester tester) async {
    // Enable the setting that displays pictogram text
    mockSettings.pictogramText = true;

    // Add an activity to the week we want to look at in the weekPlan screen
    mockWeek.days![4].activities!.add(mockActivities[0]);

    // Build the weekPlan screen
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    expect(find.byType(PictogramText), findsOneWidget);

    // Get the title of the activity
    final String title = mockActivities[0].title!;

    expect(
        find.text(title[0].toUpperCase() + title.substring(1).toLowerCase()),
        findsOneWidget);
  });

  testWidgets('_changingToCitizenWorks', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);

    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is IconButton &&
        widget.tooltip == 'Skift til borger tilstand'));
    await tester.pumpAndSettle();

    expect(find.byType(GirafConfirmDialog), findsOneWidget);

    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is GirafButton &&
        widget.key == const Key('ConfirmDialogConfirmButton')));
    await tester.pumpAndSettle();

    authBloc.mode
        .listen((WeekplanMode mode) => expect(mode, WeekplanMode.citizen));

  });

  testWidgets('Changing To Guardian Works', (WidgetTester tester) async {
  // This test has a problem with being run with all the other test
    // The authbloc.mode does not change to weekplanMode.guradian when run with
    // all the other test, but does when being run as a single test.
  // This is truly a problem for future GIRAF devs to fix
    authBloc.setMode(WeekplanMode.citizen);

    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is IconButton &&
            widget.tooltip == 'Skift til værge tilstand'),
        findsOneWidget);

    await tester.tap(find.byWidgetPredicate((Widget widget) =>
    widget is IconButton &&
        widget.tooltip == 'Skift til værge tilstand'));
    await tester.pumpAndSettle();

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is DialogButton &&
            widget.key == const Key('SwitchToGuardianSubmit')),
        findsOneWidget);

    await tester.tap(find.text('Bekræft'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    authBloc.mode
        .listen((WeekplanMode mode) => expect(mode, WeekplanMode.guardian));
  });

  testWidgets('_addActivityButtonsWork', (WidgetTester tester) async {
    when(() => api.pictogram.getAll(page: 1, pageSize: pageSize, query: ''))
        .thenAnswer((_) =>
    rx_dart.BehaviorSubject<List<PictogramModel>>.seeded(
        <PictogramModel>[mockPictograms[0]]));
    mockSettings.nrOfDaysToDisplayLandscape = 7;
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsNWidgets(7));

    await tester.tap(find
        .byType(ElevatedButton)
        .first);
    await tester.pumpAndSettle();

    expect(find.byType(PictogramSearch), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 11000));
  });

  testWidgets('completedActivitiesDisplayedCorrectlyInGuardianMode', (
      WidgetTester tester) async {
    mockActivities[0].state = ActivityState.Completed;

    // Added the activity that is completed with checkmark
    mockWeek.days![0].activities!.add(mockActivities[0]);

    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Find checkmark icon by key
    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('_cancelledActivitiesDisplayedCorrectlyInGuardianMode', (
      WidgetTester tester) async {
    mockActivities[0].state = ActivityState.Canceled;

    // Added Cancelled activity with a cross
    mockWeek.days![0].activities!.add(mockActivities[0]);

    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Find cross (cancelled) icon by key
    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets('_timerIconDisplayedCorrectlyInGuardianMode', (
      WidgetTester tester) async {
    // Activity with a timer
    mockWeek.days![0].activities!.add(mockActivities[2]);

    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Find timer icon
    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is Image &&
            widget.image ==
                const AssetImage('assets/timer/piechart_icon.png')),
        findsOneWidget);
  });

  testWidgets('_checkMarkCompletedActivityModeWorksInCitizenMode', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.completeMark = CompleteMark.Checkmark;
    mockActivities[0].state = ActivityState.Completed;
    // Added the activity that is completed with checkmark
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Find checkmark icon by key
    expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  });

  testWidgets('_greyedOutCompletedActivityModeWorksInCitizenMode', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.completeMark = CompleteMark.MovedRight;
    mockActivities[0].state = ActivityState.Completed;
    // Added the activity that is completed with checkmark
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Find greyed out box by key
    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is Container && widget.key == const Key('GreyOutBox')),
        findsOneWidget);
  });

  testWidgets('_removeCompletedActivityModeWorksInCitizenMode', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.completeMark = CompleteMark.Removed;
    mockActivities[0].state = ActivityState.Completed;
    // Added the activity that is completed with checkmark
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Check that the opacity of the activity card is set to zero.
    expect(
        find.byWidgetPredicate(
                (Widget widget) => widget is Opacity && widget.opacity == 0.0),
        findsOneWidget);
  });

  testWidgets('_notCompletedActivitiesNotHidden', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.completeMark = CompleteMark.Removed;
    mockActivities[0].state = ActivityState.Normal;
    // Added the activity that is completed with checkmark
    mockWeek.days![0].activities!.add(mockActivities[0]);
    await tester.pumpWidget(MaterialApp(
        home: WeekplanScreen(
          mockWeek,
          user,
          key: UniqueKey(),
        )));
    await tester.pumpAndSettle();

    // Check that the opacity of the activity card is set to zero.
    expect(
        find.byWidgetPredicate(
                (Widget widget) => widget is Opacity && widget.opacity == 1.0),
        findsOneWidget);
  });

  // testWidgets ('_checkMarkCompletedActivityModeWorksInCitizenMode',(WidgetTester tester) async {
  //   authBloc.setMode(WeekplanMode.citizen);
  //   mockSettings.completeMark = CompleteMark.Checkmark;
  //   mockActivities[0].state = ActivityState.Completed;
  //   // Added the activity that is completed with checkmark
  //   mockWeek.days[0].activities.add(mockActivities[0]);
  //   await tester.pumpWidget(MaterialApp(
  //       home: WeekplanScreen(
  //     mockWeek,
  //     user,
  //     key: UniqueKey(),
  //   )));
  //   await tester.pumpAndSettle();

  //   // Find checkmark icon by key
  //   expect(find.byKey(const Key('IconComplete')), findsOneWidget);
  // });

  testWidgets(
      '_correctNumberOfActivitiesDisplayed', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.showOnlyActivities = true;
    mockSettings.nrOfActivitiesToDisplay = 2;
    final int weekDay = DateTime
        .now()
        .weekday
        .toInt() - 1;
    mockWeek.days![weekDay].activities!.add(mockActivities[0]);
    mockWeek.days![weekDay].activities!.add(mockActivities[1]);
    mockWeek.days![weekDay].activities!.add(mockActivities[2]);
    mockWeek.days![weekDay].activities!.add(mockActivities[3]);

    await tester.pumpWidget(MaterialApp(
      home: WeekplanScreen(
        mockWeek,
        user,
        key: UniqueKey(),
      ),
      key: UniqueKey(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityCard), findsNWidgets(2));
  });

  testWidgets(
      '_twoActivitiesDisplayedAfterCompletingAndCancellingFirstAndLastActivity', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockSettings.showOnlyActivities = true;
    mockSettings.nrOfActivitiesToDisplay = 2;
    final int weekDay = DateTime
        .now()
        .weekday
        .toInt() - 1;
    mockActivities[0].state = ActivityState.Completed;
    mockActivities[2].state = ActivityState.Canceled;
    mockWeek.days![weekDay].activities!.add(mockActivities[0]);
    mockWeek.days![weekDay].activities!.add(mockActivities[1]);
    mockWeek.days![weekDay].activities!.add(mockActivities[2]);
    mockWeek.days![weekDay].activities!.add(mockActivities[3]);

    await tester.pumpWidget(
        MaterialApp(home: WeekplanScreen(mockWeek, user, key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityCard), findsNWidgets(2));
  });

  testWidgets('_activityListsChangedName', (WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.guardian);
    mockSettings.pictogramText = true;
    mockActivities[3].title = 'NameTest';
    mockWeek.days![4].activities!.add(mockActivities[3]);

    // Build the weekPlan screen
    await tester.pumpWidget(
        MaterialApp(home: WeekplanScreen(mockWeek, user, key: UniqueKey())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Nametest'));
    expect(find.text('Nametest'), findsOneWidget);
  });

  testWidgets('_cancelledActivitiesDisplayedCorrectlyInCitizenMode', (
      WidgetTester tester) async {
    authBloc.setMode(WeekplanMode.citizen);
    mockActivities[0].state = ActivityState.Canceled;

    // Added Cancelled activity with a cross
    mockWeek.days![0].activities!.add(mockActivities[0]);

    await tester.pumpWidget(
        MaterialApp(home: WeekplanScreen(mockWeek, user, key: UniqueKey())));
    await tester.pumpAndSettle();

    // Find cross (cancelled) icon by key
    expect(find.byKey(const Key('IconCanceled')), findsOneWidget);
  });

  testWidgets(
      '_sevenWeekdaysWithCorrespondingColorsPresentInLandscapeModeForCitizen', (
      WidgetTester tester) async {
    mockSettings.nrOfDaysToDisplayLandscape = 7;

    authBloc.setMode(WeekplanMode.citizen);
    final WeekplanScreen weekplanScreen =
    WeekplanScreen(mockWeek, user, key: UniqueKey());
    await tester.pumpWidget(MaterialApp(home: weekplanScreen));
    await tester.pumpAndSettle();

    final List<WeekdayColorModel>? expectedColors =
        mockSettings.weekDayColors;
    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![0])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![1])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![2])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![3])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![4])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![5])),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((Widget widget) =>
        widget is WeekplanDayColumn &&
            widget.color ==
                getColorFromWeekdayColorModel(expectedColors![6])),
        findsOneWidget);
  });

  testWidgets('activity Card Start Time When Activated And Shows It For Citizen', (
      WidgetTester tester) async {
    await tester.runAsync(() async{
      final Completer<bool> checkCompleted = Completer<bool>();

      mockActivities[2].state = ActivityState.Normal;
      mockActivities[2].timer!.paused = true;
      mockActivities[2].timer!.fullLength = 100;
      mockWeek.days![0].activities!.add(mockActivities[2]);
      authBloc.setMode(WeekplanMode.citizen);
      final WeekplanScreen weekplanScreen =
      WeekplanScreen(mockWeek, user, key: UniqueKey());
      await tester.pumpWidget(MaterialApp(home: weekplanScreen));

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(mockWeek.days![0].day!.index.toString() +
          mockActivities[2].id.toString())));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);

      await tester.tap(find.byKey(Key(mockWeek.days![0].day!.index.toString() +
          mockActivities[2].id.toString())));
      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 2), () async {
        checkCompleted.complete(true);
        await checkCompleted.future;

        expect(find.byKey(const Key('IconComplete')), findsOneWidget);
      });
    });

  });

  testWidgets('_activityCardHasCompletedIconWhenActivityIsCompleted', (
      WidgetTester tester) async {
    await tester.runAsync(() async {
      mockActivities[0].state = ActivityState.Normal;
      mockWeek.days![0].activities!.add(mockActivities[0]);
      authBloc.setMode(WeekplanMode.citizen);
      final WeekplanScreen weekplanScreen =
      WeekplanScreen(mockWeek, user, key: UniqueKey());
      await tester.pumpWidget(MaterialApp(home: weekplanScreen));

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(
          mockWeek.days![0].day!.index.toString() +
              mockActivities[0].id.toString())));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('IconComplete')), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  testWidgets(
      'click Activity Card Does Nothing If Completed Or Timer Running For Citizen', (
      WidgetTester tester) async {
    await tester.runAsync(() async {
      final Completer<bool> checkCompleted = Completer<bool>();

      mockActivities[2].state = ActivityState.Normal;
      mockActivities[2].timer!.paused = true;
      mockActivities[2].timer!.fullLength = 100;
      mockWeek.days![0].activities!.add(mockActivities[2]);
      authBloc.setMode(WeekplanMode.citizen);
      final WeekplanScreen weekplanScreen =
      WeekplanScreen(mockWeek, user, key: UniqueKey());
      await tester.pumpWidget(MaterialApp(home: weekplanScreen));

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(
          mockWeek.days![0].day!.index.toString() +
              mockActivities[2].id.toString())));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);
      await tester.tap(find.byKey(Key(
          mockWeek.days![0].day!.index.toString() +
              mockActivities[2].id.toString())));

      expect(find.byKey(const Key('TimerInitKey')), findsOneWidget);
      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 2), () async {
        checkCompleted.complete(true);
        await checkCompleted.future;

        expect(find.byKey(const Key('IconComplete')), findsOneWidget);
        await tester.tap(find.byKey(Key(
            mockWeek.days![0].day!.index.toString() +
                mockActivities[2].id.toString())));

        expect(find.byKey(const Key('IconComplete')), findsOneWidget);
      });
    });
  });
}

