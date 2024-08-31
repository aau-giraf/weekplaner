import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/persistence/persistence.dart';

/// Default implementation of Http
class HttpClient implements Http {
  /// Default constructor
  HttpClient(
      {required this.baseUrl,
      required Persistence persist,
      String tokenKey = 'token',
      Duration timeout = const Duration(seconds: 5)})
      : _persist = persist,
        _tokenKey = tokenKey,
        _timeout = timeout;

  Future<Map<String, String>> get _headers async {
    final Map<String, String> headers = <String, String>{
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    final String? token = await _persist.get(_tokenKey);

    if (token != null) {
      headers['Authorization'] = 'Bearer ' + token;
    }

    return headers;
  }

  /// The base of all requests.
  ///
  /// Example: if set to `http://google.com`, then a get request with url
  /// `/search` will resolve to `http://google.com/search`
  final String baseUrl;
  final Persistence _persist;

  /// The key for which, in the SharedPreferences, the token is stored
  final String _tokenKey;

  final Duration _timeout;

  @override
  Stream<Response> get(String url) {
    return Stream<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) =>
            _parseJson(http.get(Uri.parse(baseUrl + url), headers: headers)));
  }

  @override
  Stream<Response> delete(String url) {
    return Stream<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(
            http.delete(Uri.parse(baseUrl + url), headers: headers)));
  }

  @override
  Stream<Response> post(String url, [dynamic body]) {
    return Stream<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(http.post(
            Uri.parse(baseUrl + url),
            headers: headers,
            body: _bodyHandler(body))));
  }

  @override
  Stream<Response> put(String url, [dynamic body]) {
    return Stream<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(http.put(
            Uri.parse(baseUrl + url),
            headers: headers,
            body: _bodyHandler(body))));
  }

  @override
  Stream<Response> patch(String url, [dynamic body]) {
    return Stream<Map<String, String>>.fromFuture(_headers).flatMap(
        (Map<String, String> headers) => _parseJson(http.patch(
            Uri.parse(baseUrl + url),
            headers: headers,
            body: _bodyHandler(body))));
  }

  dynamic _bodyHandler(dynamic body) {
    return body is Map ? jsonEncode(body) : body;
  }

  Stream<Response> _parseJson(Future<http.Response> res) {
    // Add timeout for request
    res = res.timeout(_timeout);

    return Stream<http.Response>.fromFuture(res).map((http.Response res) {
      Map<String, dynamic>? json;
      // ensure all headers are in lowercase
      final Map<String, String> headers = res.headers.map(
          (String h, String v) => MapEntry<String, String>(h.toLowerCase(), v));

      // only decode json if response says it's json
      if (headers.containsKey('content-type') &&
          headers['content-type']!.toLowerCase().contains('application/json')) {
        json = jsonDecode(res.body);

        if (res.statusCode > 300) {
          throw ApiException(Response(res, json!));
        }
      }

      return Response(res, json ?? jsonDecode('{}'));
    });
  }

  @override
  String getBaseUrl() {
    return baseUrl;
  }
}
