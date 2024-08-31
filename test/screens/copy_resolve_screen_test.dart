import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
//import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/copy_resolve_bloc.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/blocs/edit_weekplan_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/copy_resolve_screen.dart';
import 'package:weekplanner/screens/weekplan_selector_screen.dart';

//class WeekModelFake extends Fake implements WeekModel{}
class MockWeekApi extends Mock implements WeekApi {}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
        id: 'testId', username: 'testName', role: Role.Guardian));
  }

  @override
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    final List<DisplayNameModel> output = <DisplayNameModel>[];
    output.add(
        DisplayNameModel(displayName: 'testName', role: 'testRole', id: id));
    return Stream<List<DisplayNameModel>>.value(output);
  }
}

class MockCopyResolveBloc extends CopyResolveBloc {
  MockCopyResolveBloc(this.api) : super(api);

  bool acceptAllInputs = true;
  Api api;

  @override
  Stream<bool> get allInputsAreValidStream => Stream<bool>.value(true);
}

final List<WeekNameModel> weekNameModelList = <WeekNameModel>[];
final WeekNameModel weekNameModel =
    WeekNameModel(name: 'weekplan1', weekNumber: 2020, weekYear: 32);
final WeekNameModel weekNameModel2 =
    WeekNameModel(name: 'weekplan2', weekNumber: 2020, weekYear: 33);

void main() {
  setUpAll(() {
    registerFallbackValue(WeekModel());
  });

  final DisplayNameModel mockUser =
      DisplayNameModel(displayName: 'testName', role: 'testRole', id: 'testId');

  final WeekModel weekplan1 = WeekModel(
      thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32);

  final WeekModel weekplan2 = WeekModel(
      thumbnail: null, name: 'weekplan2', weekYear: 2020, weekNumber: 33);

  final WeekModel weekplan1Copy = WeekModel(
      thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 3);

  late MockCopyResolveBloc bloc;
  Api api = Api('baseUrl');

  setUp(() {
    weekNameModelList.clear();
    weekNameModelList.add(weekNameModel);
    weekNameModelList.add(weekNameModel2);

    bloc = MockCopyResolveBloc(api);
    bloc.initializeCopyResolverBloc(mockUser, weekplan1);

    api = Api('any');
    api.week = MockWeekApi();
    api.user = MockUserApi();

    when(() => api.week.update('testId', 2020, 3, any()))
        .thenAnswer((Invocation answer) {
      final WeekModel inputWeek = answer.positionalArguments[3];
      final WeekNameModel weekNameModel =
          WeekNameModel(name: inputWeek.name, weekYear: 2020, weekNumber: 3);

      weekNameModelList.add(weekNameModel);
      return Stream<WeekModel>.value(weekplan1);
    });

    when(() => api.week.get('testId', 2020, 3)).thenAnswer((_) {
      for (WeekNameModel week in weekNameModelList) {
        final bool isEqual = week.weekYear == 2020 && week.weekNumber == 3;
        if (isEqual) {
          return Stream<WeekModel>.value(weekplan1Copy);
        }
      }
      return Stream<WeekModel>.value(WeekModel(
          thumbnail: null, name: '2020 - 3', weekYear: 2020, weekNumber: 3));
    });

    when(() => api.week
            .get('testId', weekNameModel.weekYear!, weekNameModel.weekNumber!))
        .thenAnswer((_) {
      return Stream<WeekModel>.value(weekplan1);
    });

    when(() => api.week.get(
            'testId', weekNameModel2.weekYear!, weekNameModel2.weekNumber!))
        .thenAnswer((_) {
      return Stream<WeekModel>.value(weekplan2);
    });

    when(() => api.week.getNames('testId')).thenAnswer((_) {
      return Stream<List<WeekNameModel>>.value(weekNameModelList);
    });

    di.clearAll();
    di.registerDependency<Api>(() => api);
    di.registerDependency<EditWeekplanBloc>(() => EditWeekplanBloc(api));
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<PictogramImageBloc>(() => PictogramImageBloc(api));
    di.registerDependency<CopyResolveBloc>(() => bloc);
    di.registerDependency<CopyWeekplanBloc>(() => CopyWeekplanBloc(api));
    di.registerDependency<SettingsBloc>(() => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<WeekplansBloc>(() => WeekplansBloc(api));
  });

  testWidgets('Renders CopyResolveScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CopyResolveScreen(
            currentUser: mockUser,
            weekModel: weekplan1,
            forThisCitizen: false)));
    expect(find.byType(CopyResolveScreen), findsOneWidget);
  });

  testWidgets('Copies when you press "kopier ugeplan"',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: CopyResolveScreen(
            currentUser: mockUser,
            weekModel: weekplan1,
            forThisCitizen: true)));

    expect(find.text(weekplan1.weekNumber.toString()), findsOneWidget);
    expect(find.text(weekplan1.weekYear.toString()), findsOneWidget);
    expect(find.text(weekplan1.name!), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('WeekNumberTextFieldKey')), '3');
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('WeekYearTextFieldKey')), '2020');
    await tester.pumpAndSettle();
    expect(find.text('2020'), findsOneWidget);

    expect(find.byKey(const Key('CopyResolveSaveButton')), findsOneWidget);
    await tester.tap(find.byKey(const Key('CopyResolveSaveButton')));
    await tester.pumpAndSettle();

    expect(find.byType(WeekplanSelectorScreen), findsOneWidget);

    // Expands the old week section
    expect(find.byKey(const Key('ShowOldWeeks')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ShowOldWeeks')));
    await tester.pumpAndSettle();

    expect(find.text('weekplan1'), findsNWidgets(2));
  });
}
