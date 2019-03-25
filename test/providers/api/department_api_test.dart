import 'package:test_api/test_api.dart';
import 'package:weekplanner/models/department_model.dart';
import 'package:weekplanner/models/department_name_model.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/username_model.dart';
import 'package:weekplanner/providers/api/department_api.dart';
import 'package:weekplanner/providers/http/http_mock.dart';

void main() {
  HttpMock httpMock;
  DepartmentApi departmentApi;

  final DepartmentModel sampleDepartment =
      DepartmentModel(id: 1, name: 'Dep. of Science', members: <UsernameModel>[
    UsernameModel(name: 'Kurt', role: Role.SuperUser.toString(), id: '1'),
    UsernameModel(name: 'Hüttel', role: Role.SuperUser.toString(), id: '2'),
  ], resources: <int>[
    1,
    2,
    3,
    4
  ]);

  setUp(() {
    httpMock = HttpMock();
    departmentApi = DepartmentApi(httpMock);
  });

  test('Should fetch department names', () {
    const List<Map<String, dynamic>> names = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'name': 'dep1',
      },
      <String, dynamic>{
        'id': 2,
        'name': 'dep3',
      }
    ];

    departmentApi
        .departmentNames()
        .listen(expectAsync1((List<DepartmentNameModel> response) {
      expect(response.length, 2);

      expect(response[0].id, names[0]['id']);
      expect(response[0].name, names[0]['name']);

      expect(response[1].id, names[1]['id']);
      expect(response[1].name, names[1]['name']);
    }));

    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': names,
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should be able to create department', () {
    departmentApi
        .createDepartment(sampleDepartment)
        .listen(expectAsync1((DepartmentModel response) {
      expect(response.toJson(), sampleDepartment.toJson());
    }));

    httpMock.expectOne(url: '/', method: Method.post).flush(<String, dynamic>{
      'data': sampleDepartment.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should get department with ID', () {
    departmentApi
        .getDepartment(sampleDepartment.id)
        .listen(expectAsync1((DepartmentModel response) {
      expect(response.toJson(), sampleDepartment.toJson());
    }));

    httpMock
        .expectOne(url: '/${sampleDepartment.id}', method: Method.get)
        .flush(<String, dynamic>{
      'data': sampleDepartment.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should be able to fetch department users', () {
    departmentApi
        .getDepartmentUsers(sampleDepartment.id)
        .listen(expectAsync1((List<UsernameModel> response) {
      expect(
          response.map((UsernameModel member) => member.toJson()),
          sampleDepartment.members
              .map((UsernameModel member) => member.toJson()));
    }));

    httpMock
        .expectOne(url: '/${sampleDepartment.id}/citizens', method: Method.get)
        .flush(<String, dynamic>{
      'data': sampleDepartment.members
          .map((UsernameModel member) => member.toJson())
          .toList(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should be able to add user to department', () {
    departmentApi
        .addUserToDepartment(
            sampleDepartment.id, sampleDepartment.members[0].id)
        .listen(expectAsync1((DepartmentModel response) {
      expect(response.toJson(), sampleDepartment.toJson());
    }));

    httpMock
        .expectOne(
            url:
                '/${sampleDepartment.id}/user/${sampleDepartment.members[0].id}',
            method: Method.post)
        .flush(<String, dynamic>{
      'data': sampleDepartment.toJson(),
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should be able to change name of department', () {
    departmentApi
        .updateName(sampleDepartment.id, 'new Name')
        .listen(expectAsync1((bool response) {
      expect(response, isTrue);
    }));

    httpMock
        .expectOne(url: '/${sampleDepartment.id}/name', method: Method.put)
        .flush(<String, dynamic>{
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  test('Should be able to delete department', () {
    departmentApi
        .delete(sampleDepartment.id)
        .listen(expectAsync1((bool success) {
      expect(success, isTrue);
    }));

    httpMock
        .expectOne(url: '/${sampleDepartment.id}', method: Method.delete)
        .flush(<String, dynamic>{
      'success': true,
      'errorProperties': <dynamic>[],
      'errorKey': 'NoError',
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
