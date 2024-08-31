@Timeout(Duration(seconds: 5))

import 'dart:io';

import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:async_test/async_test.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';

class MockWeekApi extends Mock implements WeekApi {}

void main() {
  Api api = Api('baseUrl');
  WeekplansBloc bloc = WeekplansBloc(api);
  MockWeekApi weekApi = MockWeekApi();

  final List<WeekNameModel> weekNameModelList = <WeekNameModel>[];
  final WeekNameModel weekNameModel1 =
      WeekNameModel(name: 'name', weekNumber: 8, weekYear: 2020);
  final WeekNameModel weekNameModel2 =
      WeekNameModel(name: 'name', weekNumber: 3, weekYear: 2021);
  final WeekNameModel weekNameModel3 =
      WeekNameModel(name: 'name', weekNumber: 28, weekYear: 2020);
  final WeekNameModel weekNameModel4 =
      WeekNameModel(name: 'name', weekNumber: 3, weekYear: 2020);
  final WeekNameModel weekNameModel5 =
      WeekNameModel(name: 'name', weekNumber: 50, weekYear: 2019);
  final WeekNameModel weekNameModel6 =
      WeekNameModel(name: 'name', weekNumber: 8, weekYear: 9999);
  final List<WeekModel> weekModelList = <WeekModel>[];
  final WeekModel weekModel1 = WeekModel(weekNumber: 8, weekYear: 2020);
  final WeekModel weekModel2 = WeekModel(weekNumber: 3, weekYear: 2021);
  final WeekModel weekModel3 = WeekModel(weekNumber: 28, weekYear: 2020);
  final WeekModel weekModel4 = WeekModel(weekNumber: 3, weekYear: 2020);
  final WeekModel weekModel5 = WeekModel(weekNumber: 50, weekYear: 2019);
  final WeekModel weekModel6 = WeekModel(weekNumber: 8, weekYear: 9999);
  final DisplayNameModel mockUser =
      DisplayNameModel(displayName: 'test', id: 'test', role: 'test');

  setUp(() {
    api = Api('any');
    weekApi = MockWeekApi();
    api.week = weekApi;
    bloc = WeekplansBloc(api);

    weekNameModelList.clear();
    weekModelList.clear();

    weekModelList.add(weekModel1);
    weekNameModelList.add(weekNameModel1);
  });

  when(() => weekApi.getNames('test')).thenAnswer((_) =>
      rx_dart.BehaviorSubject<List<WeekNameModel>?>.seeded(weekNameModelList));

  when(() => weekApi.get(
          'test', weekNameModel1.weekYear!, weekNameModel1.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel1));

  when(() => weekApi.get(
          'test', weekNameModel2.weekYear!, weekNameModel2.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel2));

  when(() => weekApi.get(
          'test', weekNameModel3.weekYear!, weekNameModel3.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel3));

  when(() => weekApi.get(
          'test', weekNameModel4.weekYear!, weekNameModel4.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel4));

  when(() => weekApi.get(
          'test', weekNameModel5.weekYear!, weekNameModel5.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel5));

  when(() => weekApi.get(
          'test', weekNameModel6.weekYear!, weekNameModel6.weekNumber!))
      .thenAnswer((_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel6));

  when(() => weekApi.delete(any(), any(), any()))
      .thenAnswer((_) => rx_dart.BehaviorSubject<bool>.seeded(true));

  test('Should be able to load weekplans for a user', async((DoneFn done) {
    when(() => weekApi.get(
            mockUser.id!, weekNameModel1.weekYear!, weekNameModel1.weekNumber!))
        .thenAnswer(
            (_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel1));

    when(() => weekApi.getNames(mockUser.id!)).thenAnswer((_) =>
        rx_dart.BehaviorSubject<List<WeekNameModel>>.seeded(weekNameModelList));

    bloc.weekNameModels.listen((List<WeekNameModel>? response) {
      expect(response, isNotNull);
      expect(response, equals(weekNameModelList));
    });

    bloc.oldWeekModels.listen((List<WeekModel> response) {
      expect(response, isNotNull);
      expect(response, equals(weekModelList));
      done();
    });

    bloc.load(mockUser);
  }));

  test('Should dispose weekModels stream', async((DoneFn done) {
    bloc.weekModels.listen((_) {}, onDone: done);
    bloc.dispose();
  }));

  test('Should dispose weekNameModel1 stream', async((DoneFn done) {
    bloc.weekNameModels.listen((_) {}, onDone: done);
    bloc.dispose();
  }));

  test('Adds a weekmodel to a list of marked weekmodels', async((DoneFn done) {
    bloc.markedWeekModels
        .skip(1)
        .listen((List<WeekModel> markedWeekModelsList) {
      expect(markedWeekModelsList.length, 1);
      done();
    });

    // Add the ActivityModel to the list of marked weekmodels.
    bloc.toggleMarkedWeekModel(weekModel1);
  }));

  test('Removes a weekmodel from the list of marked weekmodels',
      async((DoneFn done) {
    // Add the weekmodel to list of marked weekmodels
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    bloc.markedWeekModels
        .skip(1)
        .listen((List<WeekModel> markedWeekModelsList) {
      expect(markedWeekModelsList.length, 0);
      done();
    });

    // Remove the weekmodel from the list of marked weekmodels.
    bloc.toggleMarkedWeekModel(weekModel1);
  }));

  test('Clear the list of marked weekmodels', async((DoneFn done) {
    // Add the weekmodel to list of marked weekmodels
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    bloc.markedWeekModels
        .skip(1)
        .listen((List<WeekModel> markedWeekModelsList) {
      expect(markedWeekModelsList.length, 0);
      done();
    });

    // Clears the list of marked weekmodels.
    bloc.clearMarkedWeekModels();
  }));

  test('Checks if a weekmodel is marked', async((DoneFn done) {
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    expect(bloc.isWeekModelMarked(weekModel1), true);
    done();
  }));

  test('Returns false if a weekmodel is not marked', async((DoneFn done) {
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 0);

    expect(bloc.isWeekModelMarked(weekModel1), false);
    done();
  }));

  test('Checks if the number of marked weekmodels matches',
      async((DoneFn done) {
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    bloc.toggleMarkedWeekModel(WeekModel(name: 'testWeekModel'));
    expect(bloc.getNumberOfMarkedWeekModels(), 2);

    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);
    done();
  }));

  test('Checks if the marked weekmodels are deleted from the weekmodels',
      async((DoneFn done) {
    final List<WeekNameModel> weekNameModelList = <WeekNameModel>[
      weekNameModel1
    ];
    when(() => weekApi.get(
            mockUser.id!, weekNameModel1.weekYear!, weekNameModel1.weekNumber!))
        .thenAnswer(
            (_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel1));

    when(() => weekApi.getNames(mockUser.id!)).thenAnswer((_) =>
        rx_dart.BehaviorSubject<List<WeekNameModel>>.seeded(weekNameModelList));

    bloc.load(mockUser);
    bloc.toggleMarkedWeekModel(weekModel1);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    int count = 0;
    bloc.weekModels.listen((List<WeekModel> userWeekModels) {
      if (count == 0) {
        bloc.deleteMarkedWeekModels();
        count++;
      } else {
        expect(userWeekModels.contains(weekModel1), false);
        expect(userWeekModels.length, 0);
        expect(bloc.getNumberOfMarkedWeekModels(), 0);
      }
    });

    done();
  }));

  test('check deletion of new weekplan without oldWeekPlan',
      async((DoneFn done) {
    final List<WeekNameModel> weekNameModelList = <WeekNameModel>[
      weekNameModel6
    ];
    when(() => weekApi.get(
            mockUser.id!, weekNameModel6.weekYear!, weekNameModel6.weekNumber!))
        .thenAnswer(
            (_) => rx_dart.BehaviorSubject<WeekModel>.seeded(weekModel6));

    when(() => weekApi.getNames(mockUser.id!)).thenAnswer((_) =>
        rx_dart.BehaviorSubject<List<WeekNameModel>>.seeded(weekNameModelList));

    bloc.load(mockUser);
    bloc.toggleMarkedWeekModel(weekModel6);
    expect(bloc.getNumberOfMarkedWeekModels(), 1);

    int count = 0;
    bloc.weekModels.listen((List<WeekModel> userWeekModels) {
      if (count == 0) {
        count++;
      } else {
        expect(userWeekModels.contains(weekModel6), false);
        expect(userWeekModels.length, 0);
        expect(bloc.getNumberOfMarkedWeekModels(), 0);
      }
    });

    done();
  }));

  test('Checks if the edit mode toggles from true', async((DoneFn done) {
    /// Edit mode stream initial value is false.
    bloc.toggleEditMode();

    bloc.editMode.skip(1).listen((bool toggle) {
      expect(toggle, false);
      done();
    });

    bloc.toggleEditMode();
  }));

  //test('Check if the week models are sorted by date', async((DoneFn done)
  // async
  //{
  //  final List<WeekModel> correctListOld = <WeekModel>[
  //    weekModel1, weekModel4, weekModel5
  //  ];
  //  final List<WeekModel> correctListUpcoming = <WeekModel>[
  //    weekModel3, weekModel2
  //  ];
//
  //  weekNameModelList.add(weekNameModel2);
  //  weekNameModelList.add(weekNameModel3);
  //  weekNameModelList.add(weekNameModel4);
  //  weekNameModelList.add(weekNameModel5);
//
  //  weekModelList.add(weekModel2);
  //  weekModelList.add(weekModel3);
  //  weekModelList.add(weekModel4);
  //  weekModelList.add(weekModel5);
//
  //  bloc.load(DisplayNameModel(displayName: 'test', role: 'test',
  //  id: 'test'));
//
  //  bloc.oldWeekModels.listen((List<WeekModel>oldWeekModels) {
  //    expect(correctListOld, oldWeekModels);
  //  });
  //  bloc.weekModels.listen((List<WeekModel>weekModels) {
  //    expect(correctListUpcoming, weekModels);
  //  });
  //  done();
  //}));

  test('Test marked week models', async((DoneFn done) {
    final List<WeekModel> correctMarked = <WeekModel>[
      weekModel1,
      weekModel2,
      weekModel3
    ];

    bloc.toggleMarkedWeekModel(weekModel1);
    bloc.toggleMarkedWeekModel(weekModel2);
    bloc.toggleMarkedWeekModel(weekModel3);
    expect(bloc.getMarkedWeekModels(), correctMarked);
    done();
  }));

  group('getWeekNumberFromDate', () {
    /*
  This test is to find errors with getWeekNumberFromDate if the next test
  fails on one if its 4000 cases. It might not be enough though. More dates
  can be added to cover more cases. Good luck!

  The test is skipped for now (Remove skip from the end of the test)
   */
    test('Check if the correct week number is returned', async((DoneFn done) {
      /* Semi-random checks */
      expect(bloc.getWeekNumberFromDate(DateTime(2020, 10, 14)), 42);
      expect(bloc.getWeekNumberFromDate(DateTime(2020, 10, 7)), 41);
      expect(bloc.getWeekNumberFromDate(DateTime(2020, 12, 28)), 53);
      expect(bloc.getWeekNumberFromDate(DateTime(2020, 12, 31)), 53);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 1, 3)), 53);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 1, 4)), 1);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 6, 20)), 24);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 6, 21)), 25);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 12, 26)), 51);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 12, 27)), 52);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 1, 2)), 52);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 1, 3)), 1);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 27)), 12);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 28)), 13);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 10, 30)), 43);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 10, 31)), 44);

      /* These next expects checks the same week in years where the
     first of January starts on different week days.
     */

      /* Monday */
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 10)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 11)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 12)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 13)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 17)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2024, 3, 18)), 12);

      /* Tuesday */
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 10)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 11)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 12)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 13)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 17)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2030, 3, 18)), 12);

      /* Wednesday */
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 9)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 10)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 11)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 12)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 13)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2025, 3, 17)), 12);

      /* Thursday */
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 8)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 9)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 10)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 11)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 12)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 13)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2026, 3, 16)), 12);

      /* Friday */
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 14)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 17)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 18)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 19)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 20)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 21)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2021, 3, 22)), 12);

      /* Saturday */
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 13)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 17)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 18)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 19)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 20)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2022, 3, 21)), 12);

      /* Sunday */
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 12)), 10);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 13)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 14)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 15)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 16)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 17)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 18)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 19)), 11);
      expect(bloc.getWeekNumberFromDate(DateTime(2023, 3, 20)), 12);

      done();
    }) /*, skip: 'Only needed if the function breaks'*/);

    test(
        'Check if the correct week number is returned '
        'from list of dates', async((DoneFn done) {
      // Because GitHub CI is stupid
      File file = File('${Directory.current.path}/blocs/'
          'Dates_with_weeks_2020_to_2030_semi.csv');

      if (!file.existsSync()) {
        file = File('${Directory.current.path}/test/blocs/'
            'Dates_with_weeks_2020_to_2030_semi.csv');
      }

      final String csv = file.readAsStringSync();

      const CsvToListConverter converter = CsvToListConverter(
          fieldDelimiter: ',',
          textDelimiter: '"',
          textEndDelimiter: '"',
          eol: ';');

      final List<List<dynamic>> datesAndWeeks = converter.convert<dynamic>(csv);

      for (int i = 0; i < datesAndWeeks.length; i++) {
        final DateTime date = DateTime.parse(datesAndWeeks[i][0]);
        final int expectedWeek = datesAndWeeks[i][1];

        final int actualWeek = bloc.getWeekNumberFromDate(date);

        try {
          expect(actualWeek, expectedWeek);
        } on TestFailure {
          print('Error in calculating week number for date: '
              '${date.toString()}\nGot $actualWeek, '
              'expected $expectedWeek');
          fail('');
        }
      }

      done();
    }));
  });

  // test('Weekplans should be split into old and upcoming',
  // async((DoneFn done){
  //  weekNameModelList.add(weekNameModel2);
  //  weekNameModelList.add(weekNameModel3);
  //  weekNameModelList.add(weekNameModel4);
  //  weekNameModelList.add(weekNameModel5);
  //
  //  weekModelList.add(weekModel2);
  //  weekModelList.add(weekModel3);
  //  weekModelList.add(weekModel4);
  //  weekModelList.add(weekModel5);
  //
  //  bloc.load(DisplayNameModel(displayName: 'test', role: 'test',
  //  id: 'test'));
  //
  //  bloc.oldWeekModels.listen((List<WeekModel>oldWeekModels) {
  //    expect(oldWeekModels.contains(weekModel1), true);
  //    expect(oldWeekModels.contains(weekModel2), false);
  //    expect(oldWeekModels.contains(weekModel3), false);
  //    expect(oldWeekModels.contains(weekModel4), true);
  //    expect(oldWeekModels.contains(weekModel5), true);
  //  });
  //
  //  bloc.weekModels.listen((List<WeekModel>weekModels) {
  //    expect(weekModels.contains(weekModel1), false);
  //    expect(weekModels.contains(weekModel2), true);
  //    expect(weekModels.contains(weekModel3), true);
  //    expect(weekModels.contains(weekModel4), false);
  //    expect(weekModels.contains(weekModel5), false);
  //  });
  //
  //  done();
  // }));
}
