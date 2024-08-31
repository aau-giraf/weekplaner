import 'package:weekplanner/models/model.dart';

/// A model for a department id and a name
class DepartmentNameModel implements Model {
  /// Constructor with an department [id] and [name]
  DepartmentNameModel({this.id, this.name});

  /// Contructor from json
  DepartmentNameModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[DepartmentNameModel]: Cannot instantiate from null');
    }

    id = json['id'];
    name = json['name'];
  }

  /// The id of the department.
  int? id;

  /// The name of the department.
  String? name;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
      };
}
