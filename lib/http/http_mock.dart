import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/http/http.dart';

import '../api/api_exception.dart';

/// HTTP Method
// ignore: public_member_api_docs
enum Method { get, post, put, delete, patch }

/// A call to the Http
class Call {
  /// Default constructor
  Call(this.method, this.url, [this.body, this.statusCode = 200]) {
    flush = PublishSubject<dynamic>();
  }

  /// Which method was used
  final Method method;

  /// Body of the request
  final dynamic body;

  /// What url was the call made on
  final String url;

  /// Statuscode of the request
  final int statusCode;

  /// Flush results
  late PublishSubject<dynamic> flush; // ignore: close_sinks

  @override
  String toString() {
    return "Call($method, $url, $statusCode: '$body')";
  }
}

/// Flush results to test
class Flusher {
  /// Default constructor
  Flusher(this._call);

  final Call _call;

  /// Flush a body to our listener
  ///
  /// [response] The response to flush
  void flush(dynamic response) {
    _call.flush.add(response);
  }

  /// Send an exception to our listener
  ///
  /// [exception] The exception to send
  void throwError(Exception exception) {
    _call.flush.add(exception);
  }
}

/// Mocking class for HttpClient
class HttpMock implements Http {
  final List<Call> _calls = <Call>[];

  /// Ensure that there are no requests that are not already expected
  void verify() {
    if (_calls.isNotEmpty) {
      throw Exception('Expected no requests, found: \n' +
          _calls
              .map((Call call) =>
                  '[${call.method} ${call.statusCode}] ${call.url}')
              .join('\n'));
    }
  }

  /// Expect a request with the given method and url.
  ///
  /// [method] One of delete, get, patch, post, or put.
  /// [url] The url that is expected
  Flusher expectOne(
      {Method? method,
      required String url,
      dynamic body,
      int statusCode = 200}) {
    final int index = _calls.indexWhere((Call call) =>
        call.url == url &&
        (method == null || method == call.method) &&
        (body == null || body == call.body));

    if (index == -1) {
      throw Exception('Expected [$method $statusCode] $url, found none');
    }

    final Call call = _calls[index];
    _calls.removeAt(index);
    return Flusher(call);
  }

  /// Ensure that no request with the given method and url is send
  ///
  /// [method] One of delete, get, patch, post, or put.
  /// [url] The url that not expected
  void expectNone({Method? method, required String url}) {
    for (Call call in _calls) {
      if (call.url == url && (method == null || method == call.method)) {
        throw Exception('Found [$method] $url, expected none');
      }
    }
  }

  @override
  Stream<Response> delete(String url, {bool raw = false}) {
    return _reqToRes(Method.delete, url, null);
  }

  @override
  Stream<Response> get(String url, {bool raw = false}) {
    return _reqToRes(Method.get, url, null);
  }

  @override
  Stream<Response> patch(String url, [dynamic body, int? statusCode]) {
    return _reqToRes(Method.patch, url, body);
  }

  @override
  Stream<Response> post(String url, [dynamic body, int? statusCode]) {
    return _reqToRes(Method.post, url, body);
  }

  @override
  Stream<Response> put(String url, [dynamic body, int? statusCode]) {
    return _reqToRes(Method.put, url, body);
  }

  Stream<Response> _reqToRes(Method method, String url,
      [dynamic body, int? statusCode]) {
    final Call call = Call(method, url, body);
    _calls.add(call);

    return call.flush.map((dynamic response) {
      if (response is Response) {
        return response;
      }

      if (response is Exception) {
        throw response;
      }
      http.Response? httpResponse;

      Map<String, dynamic> json = <String, dynamic>{};

      if (response is Map<String, dynamic>) {
        // The response is parsed json
        json = response;
        httpResponse = http.Response(jsonEncode(json), statusCode ?? 200);
      } else if (response is List<int>) {
        // The response is a binary stream
        httpResponse = http.Response.bytes(response, statusCode ?? 200);
      }
      if (httpResponse!.statusCode > 300) {
        throw ApiException(Response(httpResponse, json));
      }

      return Response(httpResponse, json);
    });
  }

  @override
  String getBaseUrl() {
    throw UnimplementedError();
  }
}
