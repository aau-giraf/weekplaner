import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/user_week_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

import '../screens/show_activity_screen_test.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
        id: '1',
        department: 3,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Kurt',
        username: 'SpaceLord69'));
  }
}

class MockActivityApi extends Mock implements ActivityApi {
  @override
  Stream<ActivityModel> update(ActivityModel activity, String userId) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }

  @override
  Stream<ActivityModel> add(ActivityModel activity, String userId,
      String weekplanName, int weekYear, int weekNumber, Weekday weekDay) {
    return rx_dart.BehaviorSubject<ActivityModel>.seeded(activity);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(WeekModel());
    registerFallbackValue(mockWeekDayModel());
    registerFallbackValue(Weekday.Monday);
  });

  Api api = Api('any');
  WeekplanBloc weekplanBloc = WeekplanBloc(api);
  late WeekModel week = WeekModel();

  final DisplayNameModel user = DisplayNameModel(
      role: Role.Guardian.toString(), displayName: 'User', id: '1');

  setUp(() {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    api = Api('any');

    api.user = MockUserApi();
    api.week = MockWeekApi();
    api.activity = MockActivityApi();
    when(() => api.week.update(any(), any(), any(), any()))
        .thenAnswer((Invocation inv) {
      return Stream<WeekModel>.value(inv.positionalArguments[3]);
    });

    when(() => api.week.get(any(), any(), any())).thenAnswer((Invocation inv) {
      return Stream<WeekModel>.value(week);
    });
    when(() => api.week.getDay(any(), any(), any(), any()))
        .thenAnswer((Invocation inv) {
      return Stream<WeekdayModel>.value(week.days!.singleWhere(
          (WeekdayModel day) => day.day == inv.positionalArguments[3]));
    });
    when(() => api.week.updateDay(any(), any(), any(), any()))
        .thenAnswer((Invocation inv) {
      return Stream<WeekdayModel>.value(inv.positionalArguments[3]);
    });

    weekplanBloc = WeekplanBloc(api);
  });

  test('Loads a weekplan for the weekplan view', async((DoneFn done) {
    weekplanBloc.getWeek(week, user);
    weekplanBloc.userWeek.listen((UserWeekModel response) {
      expect(response, isNotNull);
      expect(response.week, equals(week));
      verify(() => api.week.get(user.id!, week.weekYear, week.weekNumber));
      done();
    });
  }));

  test('Adds an activity to a list of marked activities', async((DoneFn done) {
    // Create an ActivityModel, to add to the list of marked activites.
    final ActivityModel activityModel =
        ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test')
    ], id: 1, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    weekplanBloc.markedActivities
        .skip(1)
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 1);
      done();
    });

    // Add the ActivityModel to the list of marked activities.
    weekplanBloc.addMarkedActivity(activityModel);
  }));

  test('Removes an activity to a list of marked activities',
      async((DoneFn done) {
    final ActivityModel firstActivityModel =
        ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test')
    ], id: 1, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    final ActivityModel secondActivityModel =
        ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    // Add marked activities to the list to prepare for the removal
    weekplanBloc.addMarkedActivity(firstActivityModel);
    weekplanBloc.addMarkedActivity(secondActivityModel);

    weekplanBloc.markedActivities
        .skip(1)
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 1);
      done();
    });

    // Delete a marked activity
    weekplanBloc.removeMarkedActivity(secondActivityModel);
  }));

  test('Clears list of marked activities', async((DoneFn done) {
    weekplanBloc.addMarkedActivity(ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test')
    ], id: 123, isChoiceBoard: true, order: 0, state: ActivityState.Normal));

    weekplanBloc.markedActivities
        .skip(1)
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 0);
      done();
    });

    weekplanBloc.clearMarkedActivities();
  }));

  test('Checks if the activity is in the list of marked activities',
      async((DoneFn done) {
    final ActivityModel activity = ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    weekplanBloc.markedActivities
        .skip(1)
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(weekplanBloc.isActivityMarked(activity), true);
      done();
    });

    weekplanBloc.addMarkedActivity(activity);
  }));

  test('Checks if the edit mode toggles from false', async((DoneFn done) {
    /// Editmode stream initial value is false.
    weekplanBloc.editMode.skip(1).listen((bool toggle) {
      expect(toggle, true);
      done();
    });

    weekplanBloc.toggleEditMode();
  }));

  test('Checks if marked activities are deleted from a users weekplan',
      async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
        role: Role.Citizen.toString(), displayName: 'User', id: '1');

    final ActivityModel activity = ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Normal);
    week.days![0].activities!.add(activity);
    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(1, 0);
      weekplanBloc.addWeekdayStream();
      weekplanBloc.addMarkedActivity(activity);
      weekplanBloc.deleteMarkedActivities();
      verify(() => api.week.updateDay(any(), any(), any(), any()));
      done();
    });
  }));

  test('Checks if marked activities are copied to a new day',
      async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
        role: Role.Citizen.toString(), displayName: 'User', id: '1');

    final ActivityModel activity = ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Friday),
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(5, 0);
      for (int i = 0; i < 5; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc.addMarkedActivity(activity);
      weekplanBloc.copyMarkedActivities(
          <bool>[false, false, false, false, true, false, false]);
      verify(() => api.week.updateDay(any(), any(), any(), any())).called(1);
      weekplanBloc.getWeekdayStream(4).listen((WeekdayModel weekday) {
        expect(weekday.activities!.length, 1);
      });
    });
    done();
  }));

  test('Checks if marked activities are marked as cancel', async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
        role: Role.Citizen.toString(), displayName: 'User', id: '1');

    final ActivityModel activity = ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Normal);

    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Friday),
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(5, 0);
      for (int i = 0; i < 5; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc.addMarkedActivity(activity);
      weekplanBloc.cancelMarkedActivities();
      verify(() => api.week.updateDay(any(), any(), any(), any()));
      weekplanBloc.getWeekdayStream(0).listen((WeekdayModel weekday) {
        expect(weekday.activities!.first.state, ActivityState.Canceled);
      });
    });
    done();
  }));

  test('Checks if marked activities are marked as resumed',
      async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
        role: Role.Citizen.toString(), displayName: 'User', id: '1');

    final ActivityModel activity = ActivityModel(pictograms: <PictogramModel>[
      PictogramModel(
          accessLevel: AccessLevel.PRIVATE,
          id: null,
          imageHash: null,
          imageUrl: null,
          lastEdit: null,
          title: 'test123')
    ], id: 2, isChoiceBoard: true, order: 0, state: ActivityState.Canceled);

    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Friday),
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(5, 0);
      for (int i = 0; i < 5; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc.addMarkedActivity(activity);
      weekplanBloc.undoMarkedActivities();
      weekplanBloc.getWeekdayStream(0).listen((WeekdayModel weekday) {
        expect(weekday.activities!.first.state, ActivityState.Active);
      });
      verify(() => api.week.updateDay(any(), any(), any(), any()));
    });
    done();
  }));

  test('Checks if the edit mode toggles from true', async((DoneFn done) {
    /// Edit mode stream initial value is false.
    weekplanBloc.toggleEditMode();

    weekplanBloc.editMode.skip(1).listen((bool toggle) {
      expect(toggle, false);
      done();
    });

    weekplanBloc.toggleEditMode();
  }));

  test('Adds an activity to a given weekplan', async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
        role: Role.Guardian.toString(), displayName: 'User', id: '1');

    final ActivityModel activity = ActivityModel(
        order: 0,
        isChoiceBoard: false,
        state: ActivityState.Normal,
        id: 1,
        pictograms: <PictogramModel>[],
        title: '');

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(2, 0);
      for (int i = 0; i < 2; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc.addActivity(activity, 0).whenComplete(() {
        verify(() => api.week.updateDay(any(), any(), any(), any()));
        weekplanBloc.getWeekdayStream(0).listen((WeekdayModel weekday) {
          expect(weekday.activities!.length, 1);
          expect(weekday.activities!.first, activity);
        });
      });
    });
    done();
  }));

  test('Reorder activity from monday to tuesday', async((DoneFn done) {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    final ActivityModel modelToMove = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 0,
        state: ActivityState.Normal,
        isChoiceBoard: false);
    week.days![0].activities!.add(modelToMove);
    week.days![1].activities!.add(ActivityModel(
        id: 2,
        pictograms: <PictogramModel>[],
        order: 0,
        state: ActivityState.Normal,
        isChoiceBoard: false));

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(2, 0);
      for (int i = 0; i < 2; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc
          .reorderActivities(modelToMove, Weekday.Monday, Weekday.Tuesday, 1)
          .whenComplete(() {
        weekplanBloc.getWeekdayStream(1).listen((WeekdayModel weekday) {
          expect(weekday.activities![0].id, 2);
          expect(weekday.activities![1].id, modelToMove.id);
          expect(weekday.activities!.length, 2);
        });
        weekplanBloc.getWeekdayStream(0).listen((WeekdayModel weekday) {
          expect(weekday.activities!.length, 0);
        });
        verify(() => api.week.updateDay(any(), any(), any(), any()));
      });
    });
    done();
  }));

  test('Reorder activity from monday to monday', async((DoneFn done) {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: AccessLevel.PRIVATE,
            title: 'null',
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    final ActivityModel modelToMove = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 0,
        state: ActivityState.Normal,
        isChoiceBoard: false);

    week.days![0].activities!.add(modelToMove);

    week.days![0].activities!.add(ActivityModel(
        id: 2,
        pictograms: <PictogramModel>[],
        order: 1,
        state: ActivityState.Normal,
        isChoiceBoard: false));

    week.days![0].activities!.add(ActivityModel(
        id: 3,
        pictograms: <PictogramModel>[],
        order: 2,
        state: ActivityState.Normal,
        isChoiceBoard: false));

    weekplanBloc.getWeek(week, user).whenComplete(() {
      weekplanBloc.setDaysToDisplay(2, 0);
      for (int i = 0; i < 2; i++) {
        weekplanBloc.addWeekdayStream();
      }
      weekplanBloc
          .reorderActivities(modelToMove, Weekday.Monday, Weekday.Monday, 2)
          .whenComplete(() {
        weekplanBloc.getWeekdayStream(0).listen((WeekdayModel weekday) {
          expect(weekday.activities![0].id, 2);
          expect(weekday.activities![0].order, 0);
          expect(weekday.activities![1].id, 3);
          expect(weekday.activities![1].order, 1);
          expect(weekday.activities![2].id, 1);
          expect(weekday.activities![2].order, 2);
        });
        verify(() => api.week.updateDay(any(), any(), any(), any()));
      });
    });
    done();
  }));

  test(
      'Testing atLeastOneActivityMarked returns false when '
      'no activities are marked', async((DoneFn done) {
    // Listening to the atLeastOneActivityMarked stream to check it is empty
    weekplanBloc.atLeastOneActivityMarked.listen((bool result) {
      expect(result, isFalse);
      done();
    });
  }));

  test(
      'Testing atLeastOneActivityMarked returns true when an activity is '
      'marked', async((DoneFn done) {
    // Creating the activity that will be added
    final ActivityModel testActivity = ActivityModel(
        id: 1,
        pictograms: <PictogramModel>[],
        order: 0,
        state: ActivityState.Normal,
        isChoiceBoard: false);

    weekplanBloc.addMarkedActivity(testActivity);

    // Listening to the atLeastOneActivityMarked stream to check it is filled
    weekplanBloc.atLeastOneActivityMarked.listen((bool result) {
      expect(result, isTrue);
      done();
    });
  }));
}
