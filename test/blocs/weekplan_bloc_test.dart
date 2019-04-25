import 'package:api_client/api/api.dart';
import 'package:api_client/api/user_api.dart';
import 'package:api_client/api/week_api.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/role_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/giraf_user_model.dart';
import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:api_client/models/weekday_model.dart';
import 'package:async_test/async_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_api/test_api.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/models/user_week_model.dart';

class MockWeekApi extends Mock implements WeekApi {}

class MockUserApi extends Mock implements UserApi {
  @override
  Observable<GirafUserModel> me() {
    return Observable<GirafUserModel>.just(GirafUserModel(
        id: '1',
        department: 3,
        role: Role.Guardian,
        roleName: 'Guardian',
        screenName: 'Kurt',
        username: 'SpaceLord69'));
  }
}

void main() {
  WeekplanBloc weekplanBloc;
  Api api;
  MockWeekApi weekApi;

  final WeekModel week = WeekModel(
      thumbnail: PictogramModel(
          imageUrl: null,
          imageHash: null,
          accessLevel: null,
          title: null,
          id: null,
          lastEdit: null),
      days: <WeekdayModel>[
        WeekdayModel(activities: <ActivityModel>[], day: null)
      ],
      name: 'Week',
      weekNumber: 1,
      weekYear: 2019);

  setUp(() {
    api = Api('any');
    weekApi = MockWeekApi();
    api.week = weekApi;

    api.user = MockUserApi();
    api.week = MockWeekApi();
    when(api.week.update(any, any, any, any)).thenAnswer((_) {
      return Observable<WeekModel>.just(week);
    });

    weekplanBloc = WeekplanBloc(api);
  });

  test('Loads a weekplan for the weekplan view', () {
    final WeekModel week = WeekModel(name: 'test week');
    weekplanBloc.setWeek(week, null);

    weekplanBloc.userWeek.listen((UserWeekModel response) {
      expect(response, isNotNull);
      expect(response.week, equals(week));
    });
  });

  test('Adds an activity to a list of marked activities', () {
    final ActivityModel activityModel = ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test'),
        id: 1,
        isChoiceBoard: null,
        order: null,
        state: null);

    weekplanBloc.addMarkedActivity(activityModel);

    weekplanBloc.markedActivities
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 1);
    });
  });

  test('Removes an activity to a list of marked activities', () {
    final ActivityModel firstActivityModel = ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test'),
        id: 1,
        isChoiceBoard: null,
        order: null,
        state: null);

    final ActivityModel secondActivityModel = ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test123'),
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

    weekplanBloc.addMarkedActivity(firstActivityModel);
    weekplanBloc.addMarkedActivity(secondActivityModel);

    weekplanBloc.removeMarkedActivity(firstActivityModel);

    weekplanBloc.markedActivities
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 1);
    });
  });

  test('Clears list of marked activities', () {
    weekplanBloc.addMarkedActivity(ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test'),
        id: 123,
        isChoiceBoard: null,
        order: null,
        state: null));

    weekplanBloc.clearMarkedActivities();

    weekplanBloc.markedActivities
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(markedActivitiesList.length, 0);
    });
  });

  test('Checks if the activity is in the list of marked activities', () {
    final ActivityModel activity = ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test123'),
        id: 2,
        isChoiceBoard: null,
        order: null,
        state: null);

    weekplanBloc.addMarkedActivity(activity);

    weekplanBloc.markedActivities
        .listen((List<ActivityModel> markedActivitiesList) {
      expect(weekplanBloc.isActivityMarked(activity), true);
    });
  });

  test('Checks if the edit mode toggles from false', () {
    /// Editmode stream initial value is false.
    weekplanBloc.toggleEditMode();

    weekplanBloc.editMode.listen((bool toggle) {
      expect(toggle, true);
    });
  });

  test('Checks if marked activities is deleted from a users weekplan', () {
    final UsernameModel user =
        UsernameModel(role: Role.Citizen.toString(), name: 'User', id: '1');

    final ActivityModel activity = ActivityModel(
        pictogram: PictogramModel(
            accessLevel: null,
            id: null,
            imageHash: null,
            imageUrl: null,
            lastEdit: null,
            title: 'test123'),
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

    weekplanBloc.setWeek(weekModel, user);

    weekplanBloc.addMarkedActivity(activity);

    weekplanBloc.deleteMarkedActivities();

    weekplanBloc.userWeek.listen((UserWeekModel userWeekModel) {
      verify(api.week.update(any, any, any, any));
      expect(userWeekModel.week.days[Weekday.Monday.index].activities,
          <ActivityModel>[]);
    });
  });

  test('Checks if the edit mode toggles from true', () {
    /// Editmode stream initial value is false.
    weekplanBloc.toggleEditMode();
    weekplanBloc.toggleEditMode();

    weekplanBloc.editMode.listen((bool toggle) {
      expect(toggle, false);
    });
  });

  test('Adds an activity to a given weekplan', async((DoneFn done) {
    final UsernameModel user =
        UsernameModel(role: Role.Guardian.toString(), name: 'User', id: '1');

    final ActivityModel activity = ActivityModel(
        order: null,
        isChoiceBoard: null,
        state: null,
        id: null,
        pictogram: null);

    weekplanBloc.userWeek.skip(1).listen((UserWeekModel userWeek) {
      verify(api.week.update(any, any, any, any));
      expect(userWeek.week, week);
      expect(userWeek.user, user);
      expect(userWeek.week.days.first.activities.length, 1);
      expect(userWeek.week.days.first.activities.first, activity);
      done();
    });

    // Used by the addActivity
    weekplanBloc.setWeek(week, user);

    weekplanBloc.addActivity(activity, 0);
  }));
}
