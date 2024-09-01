import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/new_weekplan_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockWeekModel extends Fake implements WeekModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockWeekModel());
  });

  Api api = Api('baseUrl');
  NewWeekplanBloc bloc = NewWeekplanBloc(api);
  final PictogramModel mockThumbnail = PictogramModel(
      id: 1,
      lastEdit: null,
      title: 'null',
      accessLevel: AccessLevel.PRIVATE,
      imageUrl: 'http://any.tld',
      imageHash: null);
  final DisplayNameModel mockUser =
      DisplayNameModel(displayName: 'User', id: '1', role: null);
  final WeekModel mockWeek = WeekModel(
      thumbnail: mockThumbnail,
      days: null,
      name: 'Week',
      weekNumber: 1,
      weekYear: 2019);

  WeekplansBloc mockWeekplanSelector = WeekplansBloc(api);

  setUp(() {
    api = Api('any');
    api.week = MockWeekApi();

    when(() => api.week.update(any(), any(), any(), any())).thenAnswer((_) {
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
    di.registerSingleton<WeekplansBloc>(() => mockWeekplanSelector);

    bloc = NewWeekplanBloc(api);
    bloc.initialize(mockUser);
  });

  test('Should save the new weekplan', async(
    (DoneFn done) {
      bloc.onTitleChanged.add('Ugeplan');
      bloc.onYearChanged.add('2019');
      bloc.onWeekNumberChanged.add('42');
      bloc.onThumbnailChanged.add(mockThumbnail);
      bloc
          .saveWeekplan(
              screenContext: null,
              existingWeekPlans: mockWeekplanSelector.weekNameModels)
          .then(
        (WeekModel w) {
          verify(() => api.week.update(any(), any(), any(), any()));
          done();
        },
      );
    },
  ));

  test('Should save the new weekplan even when there are no existing', async(
    (DoneFn done) {
      when(() => api.week.getNames(any())).thenAnswer(
          (_) => Stream<List<WeekNameModel>>.value(<WeekNameModel>[]));

      mockWeekplanSelector = WeekplansBloc(api);
      mockWeekplanSelector.load(mockUser);

      bloc.onTitleChanged.add('Ugeplan');
      bloc.onYearChanged.add('2019');
      bloc.onWeekNumberChanged.add('42');
      bloc.onThumbnailChanged.add(mockThumbnail);
      bloc
          .saveWeekplan(
              screenContext: null,
              existingWeekPlans: mockWeekplanSelector.weekNameModels)
          .then(
        (WeekModel w) {
          verify(() => api.week.update(any(), any(), any(), any()));
          done();
        },
      );
    },
  ));

  test('Should validate title: Ugeplan', async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.validTitleStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Should not validate title: [space]', async((DoneFn done) {
    bloc.onTitleChanged.add(' ');
    bloc.validTitleStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate title: [empty string]', async((DoneFn done) {
    bloc.onTitleChanged.add('');
    bloc.validTitleStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should validate year: 2019', async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.onYearChanged.add('2019');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Should validate year: 1990', async((DoneFn done) {
    bloc.onYearChanged.add('1990');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Should not validate year: 1', async((DoneFn done) {
    bloc.onYearChanged.add('1');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate year: four characters one is a letter',
      async((DoneFn done) {
    bloc.onYearChanged.add('2k01');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate year: negative value for year',
      async((DoneFn done) {
    bloc.onYearChanged.add('-2019');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate year: [empty string]', async((DoneFn done) {
    bloc.onYearChanged.add('');
    bloc.validYearStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should validate weekNumber: 42', async((DoneFn done) {
    bloc.onWeekNumberChanged.add('42');
    bloc.validWeekNumberStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Should not validate weekNumber: 0', async((DoneFn done) {
    bloc.onWeekNumberChanged.add('0');
    bloc.validWeekNumberStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate weekNumber: 54', async((DoneFn done) {
    bloc.onWeekNumberChanged.add('54');
    bloc.validWeekNumberStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not validate weekNumber: -42', async((DoneFn done) {
    bloc.onWeekNumberChanged.add('-42');
    bloc.validWeekNumberStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should see all inputs as valid when they are valid individually',
      async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.onYearChanged.add('2019');
    bloc.onWeekNumberChanged.add('42');
    bloc.onThumbnailChanged.add(mockThumbnail);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, true);
      done();
    });
  }));

  test('Should not see all inputs as valid when week number is invalid',
      async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.onYearChanged.add('2019');
    bloc.onWeekNumberChanged.add('-42');
    bloc.onThumbnailChanged.add(mockThumbnail);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not see all inputs as valid when title is invalid',
      async((DoneFn done) {
    bloc.onTitleChanged.add('');
    bloc.onYearChanged.add('2019');
    bloc.onWeekNumberChanged.add('42');
    bloc.onThumbnailChanged.add(mockThumbnail);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should not see all inputs as valid when thumbnail is missing',
      async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.onYearChanged.add('2019');
    bloc.onWeekNumberChanged.add('42');
    bloc.onThumbnailChanged.add(null);
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should reset input streams to default values', async((DoneFn done) {
    bloc.onTitleChanged.add('Ugeplan');
    bloc.onYearChanged.add('2019');
    bloc.onWeekNumberChanged.add('42');
    bloc.onThumbnailChanged.add(mockThumbnail);
    bloc.resetBloc();
    bloc.allInputsAreValidStream.listen((bool isValid) {
      expect(isValid, isNotNull);
      expect(isValid, false);
      done();
    });
  }));

  test('Should dispose stream', async((DoneFn done) {
    bloc.allInputsAreValidStream.listen((_) {}, onDone: done);
    bloc.dispose();
  }));
}
