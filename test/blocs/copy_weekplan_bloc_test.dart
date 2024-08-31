import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';

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

  @override
  Stream<List<DisplayNameModel>> getCitizens(String id) {
    final List<DisplayNameModel> output = <DisplayNameModel>[];
    output.add(DisplayNameModel(displayName: 'test1', role: 'test1', id: id));

    return Stream<List<DisplayNameModel>>.value(output);
  }
}

Map<String, WeekModel> map = <String, WeekModel>{};

class MockWeekApi extends Mock implements WeekApi {
  @override
  Stream<WeekModel> update(
      String id, int year, int weekNumber, WeekModel week) {
    map[id] = week;
    return Stream<WeekModel>.value(week);
  }

  @override
  Stream<WeekModel> get(String? id, int? year, int? weekNumber) {
    // return null so there are no conflicts
    return Stream<WeekModel>.value(WeekModel());
  }
}

void main() {
  late CopyWeekplanBloc bloc;
  late Api api;
  late DisplayNameModel user;
  late WeekModel weekplan1;
  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    api.week = MockWeekApi();
    bloc = CopyWeekplanBloc(api);
    user = DisplayNameModel(
        displayName: 'Hans', role: Role.Citizen.toString(), id: '1');
    weekplan1 = WeekModel(
        thumbnail: null, name: 'weekplan1', weekYear: 2020, weekNumber: 32);
  });

  test('toggleMarkedUserModel', async((DoneFn done) {
    bloc.toggleMarkedUserModel(user);

    bloc.markedUserModels.listen((List<DisplayNameModel> response) {
      expect(response.contains(user), true);
    });
    done();
  }));

  test(
      'Test whether the copyToCitizens method '
      'copies the weekplan to the citizens', async((DoneFn done) {
    for (int i = 0; i < 10; i++) {
      final DisplayNameModel user = DisplayNameModel(
          displayName: 'Hans', role: Role.Citizen.toString(), id: i.toString());
      bloc.toggleMarkedUserModel(user);
      bloc.markedUserModels.listen((List<DisplayNameModel> markedUsers) {
        expect(markedUsers.contains(user), true);
      });
    }

    bloc.copyWeekplan(<WeekModel>[weekplan1], user, false);

    bloc.markedUserModels.listen((List<DisplayNameModel> markedUsers) {
      for (DisplayNameModel user in markedUsers) {
        expect(map.containsKey(user.id), true);
        expect(map[user.id], weekplan1);
      }
      done();
    });
  }));
}
