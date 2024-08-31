import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/model.dart';

/// Model with a pictogram
class PictogramModel implements Model {
  /// Constructor
  PictogramModel({
    this.id,
    this.lastEdit,
    required this.title,
    required this.accessLevel,
    this.imageUrl,
    this.imageHash,
    this.userId,
  });

  /// Constructor from Json
  PictogramModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[PictogramModel]: Cannot initialize from null');
    }

    id = json['id'];
    lastEdit =
        json['lastEdit'] == null ? null : DateTime.tryParse(json['lastEdit']);
    title = json['title'];
    accessLevel = AccessLevel.values[(json['accessLevel']) - 1];
    imageUrl = json['imageUrl'];
    imageHash = json['imageHash'];
    userId = json['userId'];
  }

  /// Constructor for json from the database
  PictogramModel.fromDatabase(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[PictogramModel]: Cannot initialize from null');
    }

    id = json['onlineId'];
    lastEdit =
        json['lastEdit'] == null ? null : DateTime.tryParse(json['lastEdit']);
    title = json['title'];
    accessLevel = AccessLevel.values[json['accessLevel']];
    imageHash = json['imageHash'];
  }

  /// pictogram id
  int? id;

  /// The last time the pictogram was edited.
  DateTime? lastEdit;

  /// The title of the pictogram.
  String title = '';

  /// The access level of the pictogram.
  AccessLevel accessLevel = AccessLevel.PRIVATE;

  /// Url for image
  String? imageUrl;

  /// Hash for image
  String? imageHash;

  /// Id of the user which the pictogram is owned by
  String? userId;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{
      'title': title,
      'accessLevel': accessLevel.index + 1,
    };

    if (id != 0) {
      result['id'] = id;
    }

    if (lastEdit != null) {
      result['lastEdit'] = lastEdit!.toIso8601String();
    }

    if (imageUrl != null) {
      result['imageUrl'] = imageUrl;
    }

    if (imageHash != null) {
      result['imageHash'] = imageHash;
    }

    if (userId != null) {
      result['userId'] = userId;
    }

    return result;
  }
}
