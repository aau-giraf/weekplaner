import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/alternate_name_model.dart';

/// AlternateName endpoints
class AlternateNameApi {
  /// constructor
  AlternateNameApi(this._http);

  final Http _http;

  ///Create new AlternateName
  Stream<AlternateNameModel> create(AlternateNameModel an) {
    return _http.post('/', an.toJson()).map((Response res) {
      return AlternateNameModel.fromJson(res.json['data']);
    });
  }

  ///Get Alternate name from user and pictogram
  Stream<AlternateNameModel> get(String userId, int picId) {
    return _http.get('/$userId/$picId').map((Response res) {
      return AlternateNameModel.fromJson(res.json['data']);
    });
  }

  ///Edit alternate name
  Stream<AlternateNameModel> put(int id, AlternateNameModel an) {
    return _http.put('/$id', an.toJson()).map((Response res) {
      return AlternateNameModel.fromJson(res.json['data']);
    });
  }
}
