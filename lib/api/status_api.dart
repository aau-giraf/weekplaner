import 'package:weekplanner/http/http.dart';

/// Status endpoints
class StatusApi {
  /// Default constructor
  StatusApi(this._http);

  final Http _http;

  /// End-point for checking if the API is running.
  Stream<bool> status() {
    return _http.get('/').map((Response res) => res.statusCode() == 200);
  }

  /// End-point for checking connection to the database.
  Stream<bool> databaseStatus() {
    return _http
        .get('/database')
        .map((Response res) => res.statusCode() == 200);
  }

  /// End-point for getting git version info, i.e. branch and commit hash
  Stream<String> versionInfo() {
    return _http.get('/version-info').map((Response res) => res.json['data']);
  }
}
