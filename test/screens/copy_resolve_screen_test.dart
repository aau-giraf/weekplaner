import 'package:api_client/api/week_api.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/week_name_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
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
import 'package:api_client/api/api.dart';
import 'package:weekplanner/screens/weekplan_selector_screen.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockCopyResolveBloc extends CopyResolveBloc {
  MockCopyResolveBloc(this.api) : super(api);

  bool acceptAllInputs = true;
  Api api;

  @override
  Observable<bool> get allInputsAreValidStream => Observable<bool>.just(true);
}

final WeekModel emptyWeekmodel = WeekModel(days: <WeekdayModel>[]);

final List<WeekNameModel> weekNameModelList = <WeekNameModel>[];
final WeekNameModel weekNameModel =
WeekNameModel(name: 'weekplan1', weekNumber: 2020, weekYear: 32);
final WeekNameModel weekNameModel2 =
WeekNameModel(name: 'weekplan2', weekNumber: 2020, weekYear: 33);

void main() {
  final DisplayNameModel mockUser =
  DisplayNameModel(displayName: 'testName', role: 'testRole', id: 'testId');

  final WeekModel weekplan1 = WeekModel(
    thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32);

  final WeekModel weekplan2 = WeekModel(
    thumbnail: null, name: 'weekplan2', weekYear: 2020, weekNumber: 33);

  final WeekModel weekplan1Copy = WeekModel(
    thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 3);

  MockCopyResolveBloc bloc;
  Api api;

  setUp(() {
    weekNameModelList.clear();
    weekNameModelList.add(weekNameModel);
    weekNameModelList.add(weekNameModel2);

    bloc = MockCopyResolveBloc(api);
    bloc.initializeCopyResolverBloc(mockUser, weekplan1);

    api = Api('any');
    api.week = MockWeekApi();

    when(api.week.update('testId', 2020, 3, any)).thenAnswer((
      Invocation answer) {

      WeekModel inputWeek = answer.positionalArguments[3];
      WeekNameModel weekNameModel = WeekNameModel(
        name: inputWeek.name,
        weekYear: 2020,
        weekNumber: 3
      );

      weekNameModelList.add(weekNameModel);
      return Observable<WeekModel>.just(weekplan1);
    });

    when(api.week.get('testId', 2020, 3)).thenAnswer((_) {
      for (WeekNameModel week in weekNameModelList){
        bool isEqual = week.weekYear == 2020 && week.weekNumber == 3;
        if (isEqual){
          return Observable<WeekModel>.just(weekplan1Copy);
        }
      }
      return Observable<WeekModel>.just(emptyWeekmodel);
    });

    when(api.week
      .get('testId', weekNameModel.weekYear, weekNameModel.weekNumber))
      .thenAnswer((_) {
      return Observable<WeekModel>.just(weekplan1);
    });

    when(api.week
      .get('testId', weekNameModel2.weekYear, weekNameModel2.weekNumber))
      .thenAnswer((_) {
      return Observable<WeekModel>.just(weekplan2);
    });

    when(api.week.getNames('testId')).thenAnswer((_) {
      return Observable<List<WeekNameModel>>.just(weekNameModelList);
    });

    di.clearAll();
    di.registerDependency<EditWeekplanBloc>((_) => EditWeekplanBloc(api));
    di.registerDependency<AuthBloc>((_) => AuthBloc(api));
    di.registerDependency<PictogramImageBloc>((_) => PictogramImageBloc(api));
    di.registerDependency<CopyResolveBloc>((_) => bloc);
    di.registerDependency<CopyWeekplanBloc>((_) => CopyWeekplanBloc(api));
    di.registerDependency<SettingsBloc>((_) => SettingsBloc(api));
    di.registerDependency<ToolbarBloc>((_) => ToolbarBloc());
    di.registerDependency<WeekplansBloc>((_) => WeekplansBloc(api));
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
      expect(find.text(weekplan1.name), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('WeekNumberTextFieldKey')), '3');
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      expect(find.byKey(const Key('CopyResolveSaveButton')), findsOneWidget);
      await tester.tap(find.byKey(const Key('CopyResolveSaveButton')));
      await tester.pumpAndSettle();

      expect(find.byType(WeekplanSelectorScreen), findsOneWidget);

      expect(find.text('Uge: 3      År: 2020'), findsOneWidget);
      expect(find.text('weekplan1'), findsNWidgets(2));
    });

}
