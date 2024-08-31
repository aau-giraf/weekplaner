import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/activity_state_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/timer_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_template_model.dart';
import 'package:weekplanner/models/weekday_model.dart';

//Test GirafUserModel 1
final GirafUserModel jamesbondTestUser = GirafUserModel(
    id: 'james007bond',
    role: Role.Citizen,
    roleName: 'Citizen',
    username: 'JamesBond007',
    displayName: 'James Bond',
    department: 1);
// Test account body 1
final Map<String, dynamic> jamesBody = <String, dynamic>{
  'username': jamesbondTestUser.username,
  'displayName': jamesbondTestUser.displayName,
  'password': 'TestPassword123',
  'department': jamesbondTestUser.department,
  'role': jamesbondTestUser.role.toString().split('.').last
};
//Test GirafUserModel 2
final GirafUserModel edTestUser = GirafUserModel(
    id: 'edmcniel01',
    role: Role.Citizen,
    roleName: 'Citizen',
    username: 'EdMcNiel34',
    displayName: 'Ed McNiel',
    department: 34);
//Test account body 2
final Map<String, dynamic> edBody = <String, dynamic>{
  'username': edTestUser.username,
  'displayName': edTestUser.displayName,
  'password': 'MyPassword42',
  'department': edTestUser.department,
  'role': edTestUser.role.toString().split('.').last
};

//Test GirafUserModel 3
final GirafUserModel jamesbondSuperUser = GirafUserModel(
    id: 'james007bond',
    role: Role.SuperUser,
    roleName: 'SuperUser',
    username: 'JamesBond007',
    displayName: 'James Bond',
    department: 1);
// Test account body 3
final Map<String, dynamic> jamesBodySuper = <String, dynamic>{
  'username': jamesbondTestUser.username,
  'displayName': jamesbondTestUser.displayName,
  'password': 'TestPassword123',
  'department': jamesbondTestUser.department,
  'role': jamesbondSuperUser.role.toString().split('.').last
};

//Test Pictogram 1
final PictogramModel scrum = PictogramModel(
    accessLevel: AccessLevel.PUBLIC,
    id: 44,
    title: 'Picture of Scrum',
    lastEdit: DateTime.now(),
    userId: '1');

//Test Pictogram 2
final PictogramModel extreme = PictogramModel(
    accessLevel: AccessLevel.PROTECTED,
    id: 20,
    title: 'Picture of XP',
    lastEdit: DateTime.now(),
    userId: '3');

//Lists of test pictograms
List<PictogramModel> testListe = <PictogramModel>[scrum];
List<PictogramModel> testListe2 = <PictogramModel>[extreme];

//Test ActivityModel 1
final ActivityModel lege = ActivityModel(
  id: 69,
  isChoiceBoard: false,
  order: 1,
  pictograms: testListe,
  choiceBoardName: 'Testchoice',
  state: ActivityState.Active,
  timer: null,
);

//Test ActivityModel 2
final ActivityModel spise = ActivityModel(
  id: 70,
  pictograms: testListe2,
  order: 2,
  state: ActivityState.Active,
  isChoiceBoard: true,
  choiceBoardName: 'Testsecondchoice',
  timer: null,
);

//Test Timer
final TimerModel timer = TimerModel(
  startTime: DateTime.now(),
  progress: 0,
  fullLength: 10,
  paused: false,
  key: 44,
);

//Test ActivityModel 3 (has Timer)
final ActivityModel sandkasse = ActivityModel(
  id: 71,
  pictograms: testListe2,
  order: 2,
  state: ActivityState.Active,
  isChoiceBoard: false,
  choiceBoardName: 'testthirdchoice',
  timer: timer,
);

final List<ActivityModel> legeday = <ActivityModel>[lege];
final List<ActivityModel> spiseday = <ActivityModel>[spise];

final WeekdayModel weekDay1 =
    WeekdayModel(day: Weekday.Tuesday, activities: legeday);

final WeekdayModel weekDay2 =
    WeekdayModel(day: Weekday.Friday, activities: null);

final List<WeekdayModel> testWeekList = <WeekdayModel>[weekDay1];
final List<WeekdayModel> blankWeekList = <WeekdayModel>[weekDay2];

final WeekModel blankTestWeek = WeekModel(
    days: blankWeekList,
    name: 'blankWeek',
    thumbnail: scrum,
    weekNumber: 25,
    weekYear: 2020);

final WeekModel testWeekModel = WeekModel(
    days: testWeekList,
    name: 'testWeek',
    thumbnail: scrum,
    weekNumber: 44,
    weekYear: 2020);

final WeekTemplateModel weekTemplate1 = WeekTemplateModel(
    days: testWeekList,
    name: 'TestReddit',
    departmentKey: 3,
    id: 44,
    thumbnail: extreme);
final WeekTemplateModel weekTemplate2 = WeekTemplateModel(
    days: testWeekList,
    name: 'TestReddit2',
    departmentKey: 2,
    id: 40,
    thumbnail: scrum);
