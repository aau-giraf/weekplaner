import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/copy_resolve_bloc.dart';

void main() {
  Api api = Api('any');
  CopyResolveBloc bloc = CopyResolveBloc(api);
  final WeekModel oldWeekmodel = WeekModel(
      thumbnail:
          PictogramModel(title: 'title', accessLevel: AccessLevel.PRIVATE),
      name: 'test',
      weekNumber: 23,
      weekYear: 2020);

  final DisplayNameModel mockUser =
      DisplayNameModel(displayName: 'testName', role: 'testRole', id: 'testId');

  setUp(() {
    api = Api('any');
    bloc = CopyResolveBloc(api);
    bloc.initializeCopyResolverBloc(mockUser, oldWeekmodel);
  });

  test('Test createNewWeekmodel', async((DoneFn done) {
    // ignore: invalid_use_of_protected_member
    bloc.weekNoController.add('24');
    // ignore: invalid_use_of_protected_member
    bloc.weekNoController.listen((_) {
      final WeekModel newWeekModel = bloc.createNewWeekmodel(oldWeekmodel);
      expect(newWeekModel.weekNumber == 24, isTrue);
      done();
    });
  }));
}
