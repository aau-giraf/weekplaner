import 'package:weekplanner/persistence/persistence.dart';

/// Mocking for the Persistence Provider
class PersistenceMock implements Persistence {
  String? _token;

  @override
  Future<String> get(String key) async {
    return _token!;
  }

  @override
  Future<bool> remove(String key) async {
    _token = null;
    return true;
  }

  @override
  Future<bool> set(String key, String value) async {
    _token = value;
    return true;
  }

  @override
  Future<bool> clear() async {
    _token = null;
    return true;
  }

  @override
  Future<List<String>> getList(String key) async {
    return <String>[_token!];
  }
}
