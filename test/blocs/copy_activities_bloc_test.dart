import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/copy_activities_bloc.dart';

void main() {
  late CopyActivitiesBloc copyActivitiesBloc;

  setUp(() {
    copyActivitiesBloc = CopyActivitiesBloc();
  });

  test('Checkbox values stream is seeded with false values',
      async((DoneFn done) {
    copyActivitiesBloc.checkboxValues.listen((List<bool> checkmarkList) {
      expect(checkmarkList.every((bool value) {
        return value == false;
      }), isTrue);
      done();
    });
  }));

  test('The selected checkmark changes value', async((DoneFn done) {
    copyActivitiesBloc.checkboxValues
        .skip(1)
        .listen((List<bool> checkmarkList) {
      expect(checkmarkList[Weekday.Monday.index], isTrue);
      done();
    });

    copyActivitiesBloc.toggleCheckboxState(Weekday.Monday.index);
  }));
}
