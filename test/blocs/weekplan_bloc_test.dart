import 'package:api_client/api/api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/displayname_model.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:async_test/async_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/models/user_week_model.dart';

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

void main() {
  WeekplanBloc weekplanBloc;
  Api api;

  WeekModel week;

  final DisplayNameModel user =
  DisplayNameModel(
    role: Role.Guardian.toString(),
    displayName: 'User',
    id: '1'
  );

  setUp(() {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
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
    when(api.week.update(any, any, any, any)).thenAnswer((Invocation inv) {
      return Stream<WeekModel>.value(inv.positionalArguments[3]);
    });

    when(api.week.get(any, any, any)).thenAnswer((Invocation inv) {
      return Stream<WeekModel>.value(week);
    });

    weekplanBloc = WeekplanBloc(api);
  });

  test('Loads a weekplan for the weekplan view', async((DoneFn done) {
    weekplanBloc.userWeek.listen((UserWeekModel response) {
      expect(response, isNotNull);
      expect(response.week, equals(week));
      verify(api.week.get(user.id, week.weekYear, week.weekNumber));
      done();
    });

    weekplanBloc.loadWeek(week, user);
  }));

  test('Adds an activity to a list of marked activities', async((DoneFn done) {
    // Create an ActivityModel, to add to the list of marked activites.
    final ActivityModel activityModel = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test')
        ],
        id: 1,
        isChoiceBoard: null,
        order: null,
        state: null
    );

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
    final ActivityModel firstActivityModel = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test')
        ],
        id: 1,
        isChoiceBoard: null,
        order: null,
        state: null);

    final ActivityModel secondActivityModel = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

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
    weekplanBloc.addMarkedActivity(ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test')
        ],
        id: 123,
        isChoiceBoard: null,
        order: null,
        state: null));

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
    final ActivityModel activity = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

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
      role: Role.Citizen.toString(),
      displayName: 'User',
      id: '1'
    );

    final ActivityModel activity = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

    final WeekModel weekModel = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Monday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.addMarkedActivity(activity);
      return weekplanBloc.userWeek.take(1);
    }).flatMap((_) {
      weekplanBloc.deleteMarkedActivities();
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel userWeekModel) {
      verify(api.week.update(any, any, any, any));
      expect(userWeekModel.week.days[Weekday.Monday.index].activities,
          <ActivityModel>[]);
      done();
    });

    weekplanBloc.loadWeek(weekModel, user);
  }));

  test('Checks if marked activities are copied to a new day',
      async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
      role: Role.Citizen.toString(),
      displayName: 'User',
      id: '1'
    );

    final ActivityModel activity = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
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

    final WeekModel newWeekModel = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
          WeekdayModel(
              activities: <ActivityModel>[activity], day: Weekday.Friday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    when(api.week.update(any, any, any, any)).thenAnswer((_) {
      return Stream<WeekModel>.value(newWeekModel);
    });

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.addMarkedActivity(activity);
      return weekplanBloc.userWeek.take(1);
    }).flatMap((_) {
      // Copy to Friday
      weekplanBloc.copyMarkedActivities(
          <bool>[false, false, false, false, true, false, false]);
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel userWeekModel) {
      verify(api.week.update(any, any, any, any));
      expect(
          userWeekModel.week.days[Weekday.Friday.index].activities.length, 1);
      done();
    }, onError: (Object error) {
      fail('Should not throw error');
    });

    weekplanBloc.loadWeek(week, user);
  }));

  test('Checks if marked activities are marked as cancel', async((DoneFn done) {
    final DisplayNameModel user = DisplayNameModel(
      role: Role.Citizen.toString(),
      displayName: 'User',
      id: '1'
    );

    final ActivityModel activity = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: ActivityState.Normal);

    final ActivityModel newActivity = ActivityModel(
        pictograms: <PictogramModel>[
          PictogramModel(
              accessLevel: null,
              id: null,
              imageHash: null,
              imageUrl: null,
              lastEdit: null,
              title: 'test123')
        ],
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: ActivityState.Canceled);

    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
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

    final WeekModel newWeekModel = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
            id: null,
            lastEdit: null),
        days: <WeekdayModel>[
          WeekdayModel(
              activities: <ActivityModel>[newActivity], day: Weekday.Monday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Tuesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Wednesday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Thursday),
          WeekdayModel(activities: <ActivityModel>[], day: Weekday.Friday)
        ],
        name: 'Week',
        weekNumber: 1,
        weekYear: 2019);

    when(api.week.update(any, any, any, any)).thenAnswer((_) {
      return Stream<WeekModel>.value(newWeekModel);
    });

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.addMarkedActivity(activity);
      return weekplanBloc.userWeek.take(1);
    }).flatMap((_) {
      weekplanBloc.cancelMarkedActivities();
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel userWeekModel) {
      verify(api.week.update(any, any, any, any));
      expect(
          userWeekModel.week.days[Weekday.Monday.index].activities.first.state,
          ActivityState.Canceled);
      done();
    }, onError: (Object error) {
      fail('Should not throw error');
    });

    weekplanBloc.loadWeek(week, user);
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
      role: Role.Guardian.toString(),
      displayName: 'User',
      id: '1'
    );

    final ActivityModel activity = ActivityModel(
        order: null,
        isChoiceBoard: null,
        state: null,
        id: null,
        pictograms: null);

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.addActivity(activity, 0);
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel userWeek) {
      verify(api.week.update(any, any, any, any));
      expect(userWeek.week, week);
      expect(userWeek.user, user);
      expect(userWeek.week.days.first.activities.length, 1);
      expect(userWeek.week.days.first.activities.first, activity);
      done();
    }, onError: (Object error) {
      fail('Should not throw error');
    });

    weekplanBloc.loadWeek(week, user);
  }));

  test('Reorder activity from monday to tuesday', async((DoneFn done) {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
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
        id: 1, pictograms: null, order: 0, state: null, isChoiceBoard: false);
    week.days[0].activities.add(modelToMove);
    week.days[1].activities.add(ActivityModel(
        id: 2, pictograms: null, order: 0, state: null, isChoiceBoard: false));

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.reorderActivities(
          modelToMove, Weekday.Monday, Weekday.Tuesday, 1);
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel response) {
      expect(response.week.days[1].activities[0].id, 2);
      expect(response.week.days[1].activities[1].id, modelToMove.id);
      expect(response.week.days[0].activities.length, 0);
      expect(response.week.days[1].activities.length, 2);
      done();
    }, onError: (Object error) {
      fail('Should not throw error');
    });

    weekplanBloc.loadWeek(week, user);
  }));

  test('Reorder activity from monday to monday', async((DoneFn done) {
    week = WeekModel(
        thumbnail: PictogramModel(
            imageUrl: null,
            imageHash: null,
            accessLevel: null,
            title: null,
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
        id: 1, pictograms: null, order: 0, state: null, isChoiceBoard: false);

    week.days[0].activities.add(modelToMove);

    week.days[0].activities.add(ActivityModel(
        id: 2, pictograms: null, order: 1, state: null, isChoiceBoard: false));

    week.days[0].activities.add(ActivityModel(
        id: 3, pictograms: null, order: 2, state: null, isChoiceBoard: false));

    weekplanBloc.userWeek.take(1).flatMap((_) {
      weekplanBloc.reorderActivities(
          modelToMove, Weekday.Monday, Weekday.Monday, 2);
      return weekplanBloc.userWeek.take(1);
    }).listen((UserWeekModel response) {
      expect(response.week.days[0].activities[0].id, 2);
      expect(response.week.days[0].activities[0].order, 0);
      expect(response.week.days[0].activities[1].id, 3);
      expect(response.week.days[0].activities[1].order, 1);
      expect(response.week.days[0].activities[2].id, 1);
      expect(response.week.days[0].activities[2].order, 2);

      done();
    }, onError: (Object error) {
      fail('Should not throw error');
    });

    weekplanBloc.loadWeek(week, user);
  }));

  test('Testing atLeastOneActivityMarked returns false when '
      'no activities are marked', async((DoneFn done) {

    // Listening to the atLeastOneActivityMarked stream to check it is empty
    weekplanBloc.atLeastOneActivityMarked.listen((bool result){
       expect(result, isFalse);
       done();
    });
  }));

  test('Testing atLeastOneActivityMarked returns true when an activity is '
      'marked', async((DoneFn done) {

    // Creating the activity that will be added
    final ActivityModel testActivity = ActivityModel(
        id: 1, pictograms: null, order: 0, state: null, isChoiceBoard: false);

    weekplanBloc.addMarkedActivity(testActivity);

    // Listening to the atLeastOneActivityMarked stream to check it is filled
    weekplanBloc.atLeastOneActivityMarked.listen((bool result){
      expect(result, isTrue);
      done();
    });
  }));

}
