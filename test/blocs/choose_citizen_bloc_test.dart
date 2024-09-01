import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/blocs/choose_citizen_bloc.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';

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

void main() {
  late ChooseCitizenBloc bloc;
  Api api;
  setUp(() {
    api = Api('any');
    api.user = MockUserApi();
    bloc = ChooseCitizenBloc(api);
  });

  test('Should be able to get UsernameModel from API', async((DoneFn done) {
    int _count = 0;
    bloc.citizen.listen((List<DisplayNameModel> response) {
      if (_count == 0) {
        expect(response.length, 0);
        _count++;
      } else {
        expect(response.length, 1);
        final DisplayNameModel rsp = response[0];
        expect(rsp.displayName, 'test1');
        expect(rsp.role, 'test1');
        expect(rsp.id, '1');
      }
    });
    done();
  }));
}
