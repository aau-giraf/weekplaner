import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should contain a specific list of values', () {
    expect(Role.Citizen.index, 1);
    expect(Role.Department.index, 2);
    expect(Role.Guardian.index, 3);
    expect(Role.SuperUser.index, 4);
    expect(Role.Trustee.index, 5);
  });
}
