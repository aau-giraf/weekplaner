import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/blocs/edit_weekplan_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:weekplanner/screens/copy_to_citizens_screen.dart';
import 'package:weekplanner/widgets/giraf_3button_dialog.dart';

import 'edit_weekplan_screen_test.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(
        GirafUserModel(id: '1', username: 'test', role: Role.Guardian));
  }

  @override
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    final List<DisplayNameModel> output = <DisplayNameModel>[];
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));
    return Stream<List<DisplayNameModel>>.value(output);
  }
}

final Map<String, WeekModel> map = <String, WeekModel>{};
bool hasConflict = false;

class MockWeekApi extends Mock implements WeekApi {
  @override
  Stream<WeekModel> get(String? id, int year, int weekNumber) {
    final WeekModel weekModel = WeekModel(days: <WeekdayModel>[
      WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[
        ActivityModel(
            pictograms: <PictogramModel>[],
            order: 1,
            state: ActivityState.Normal,
            isChoiceBoard: false,
            id: 1)
      ])
    ]);
    return hasConflict
        ? Stream<WeekModel>.value(weekModel)
        : Stream<WeekModel>.value(WeekModel(
            thumbnail: null,
            name: '$year - $weekNumber',
            weekYear: year,
            weekNumber: weekNumber));
  }

  @override
  Stream<WeekModel> update(
      String id, int year, int weekNumber, WeekModel weekModel) {
    map[id] = weekModel;
    return Stream<WeekModel>.value(weekModel);
  }
}

final DisplayNameModel user1 =
    DisplayNameModel(id: 'testId', displayName: 'testName', role: 'testRole');

final DisplayNameModel user2 = DisplayNameModel(
    id: 'test2Id', displayName: 'test2Name', role: 'test2Role');

void main() {
  late CopyWeekplanBloc bloc;
  late ToolbarBloc toolbarBloc;
  late Api api;
  setUp(() {
    di.clearAll();
    api = Api('any');
    di.registerDependency<Api>(() => api);
    api.user = MockUserApi();
    api.week = MockWeekApi();

    when(() => api.week.getNames(any())).thenAnswer((_) {
      return Stream<List<WeekNameModel>>.value(<WeekNameModel>[]);
    });

    bloc = CopyWeekplanBloc(api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    toolbarBloc = ToolbarBloc();
    di.registerDependency<CopyWeekplanBloc>(() => bloc);
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>(() => toolbarBloc);
    di.registerDependency<EditWeekplanBloc>(() => EditWeekplanBloc(api));
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<WeekplansBloc>(() => WeekplansBloc(api));
  });

  testWidgets('Renders CopyToCitizenScreen', (WidgetTester tester) async {
    final WeekModel weekplan1 = WeekModel(
        thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32);
    await tester.pumpWidget(MaterialApp(
        home: CopyToCitizensScreen(<WeekModel>[weekplan1], mockUser)));
    expect(find.byType(CopyToCitizensScreen), findsOneWidget);
  });

  testWidgets('Has Citizens Avatar', (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(
        home: CopyToCitizensScreen(<WeekModel>[mockWeek], mockUser)));
    await tester.pumpAndSettle();
    bloc.citizen.listen((List<DisplayNameModel> response) {
      expect(find.byType(CircleAvatar), findsNWidgets(response.length));
      done.complete(true);
    });
    await done.future;
  });

  testWidgets('Has Accept and Cancel buttons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CopyToCitizensScreen(<WeekModel>[mockWeek], mockUser)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('AcceptButton')), findsOneWidget);
    expect(find.byKey(const Key('CancelButton')), findsOneWidget);
  });

  testWidgets(
      'Test whether it copies to citizens when pressing the accept button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CopyToCitizensScreen(<WeekModel>[mockWeek], mockUser)));
    await tester.pumpAndSettle();

    bloc.toggleMarkedUserModel(user1);
    bloc.toggleMarkedUserModel(user2);

    hasConflict = false;

    await tester.tap(find.byKey(const Key('AcceptButton')));
    await tester.pumpAndSettle();

    expect(map.containsKey(user1.id), isTrue);
    expect(map.containsKey(user2.id), isTrue);

    expect(map[user1.id] != null, isTrue);
    expect(map[user2.id] != null, isTrue);
  });

  testWidgets(
      'Testing that it launches the conflict dialog when there are conflicts',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CopyToCitizensScreen(<WeekModel>[mockWeek], mockUser)));
    await tester.pumpAndSettle();

    bloc.toggleMarkedUserModel(user1);
    bloc.toggleMarkedUserModel(user2);

    hasConflict = true;

    await tester.tap(find.byKey(const Key('AcceptButton')));
    await tester.pumpAndSettle();

    expect(find.byType(Giraf3ButtonDialog), findsOneWidget);
  });
}
