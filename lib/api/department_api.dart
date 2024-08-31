import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/department_model.dart';
import 'package:weekplanner/models/department_name_model.dart';
import 'package:weekplanner/models/displayname_model.dart';

/// Department endpoints
class DepartmentApi {
  /// Default constructor
  DepartmentApi(this._http);

  final Http _http;

  /// Get request for getting all the department names.
  Stream<List<DepartmentNameModel>?> departmentNames() {
    return _http.get('/').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> name) =>
                DepartmentNameModel.fromJson(name))
            .toList();
      } else {
        // TODO(boginw): Throw appropriate error
        return null;
      }
    });
  }

  /// Create a new department. it's only necessary to supply the
  /// departments name
  ///
  /// [model] The department to create
  Stream<DepartmentModel> createDepartment(DepartmentModel model) {
    return _http.post('/', model.toJson()).map((Response res) {
      return DepartmentModel.fromJson(res.json['data']);
    });
  }

  /// Get the department with the specified id.
  ///
  /// [id] The id of the department to retrieve.
  Stream<DepartmentModel> getDepartment(int id) {
    return _http.get('/$id').map((Response res) {
      return DepartmentModel.fromJson(res.json['data']);
    });
  }

  /// Gets the citizen names
  ///
  /// [id] Id of Department to get citizens for
  Stream<List<DisplayNameModel>?> getDepartmentUsers(int id) {
    return _http.get('/$id/citizens').map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> name) => DisplayNameModel.fromJson(name))
            .toList();
      } else {
        // TODO(boginw): Throw appropriate error
        return null;
      }
    });
  }

  /// Add a user that does not have a department to the given department.
  /// Requires role Department, Guardian or SuperUser
  ///
  /// [departmentId] Identifier for the Departmentto add user to
  ///
  /// [userId] The ID of a GirafUser to be added to the department
  Stream<DepartmentModel> addUserToDepartment(int departmentId, String userId) {
    return _http.post('/$departmentId/user/$userId').map((Response res) {
      return DepartmentModel.fromJson(res.json['data']);
    });
  }

  /// Update department name
  ///
  /// [id] ID of the department which should change name
  /// [newName] New name for the department
  Stream<bool> updateName(int id, String newName) {
    return _http.put('/$id/name', <String, String>{'name': newName}).map(
        (Response res) {
      return res.success();
    });
  }

  /// Delete the Department with the given id
  ///
  /// [id] Identifier of Department to delete
  Stream<bool> delete(int id) {
    return _http.delete('/$id').map((Response res) {
      return res.success();
    });
  }
}
