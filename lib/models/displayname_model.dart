import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/model.dart';

///
class DisplayNameModel implements Model {
  /// Default constructor
  DisplayNameModel(
      {required this.displayName, required this.role, required this.id});

  /// Create object from JSON mapping
  DisplayNameModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[UsernameModel]: Cannot instantiate from null');
    }

    id = json['userId'];
    displayName = json['displayName'];
    role = json['userRole'];
    icon = json['userIcon'];
  }

  ///Create DisplayNameModel from database json
  DisplayNameModel.fromDatabase(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[UsernameModel]: Cannot instantiate from null');
    }

    id = json['id'];
    displayName = json['displayName'];
    role = json['roleName'];
    icon = json['userIcon'];
  }

  /// Create object from GirafUserModel
  DisplayNameModel.fromGirafUser(GirafUserModel user) {
    displayName = user.displayName;
    role = user.roleName;
    id = user.id;
  }

  /// The user's displayName
  String? displayName;

  /// The user's role
  String? role;

  /// The user's ID
  String? id;

  ///The user's icon
  String? icon;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': id,
        'displayName': displayName,
        'userRole': role,
        'userIcon': icon
      };
}
