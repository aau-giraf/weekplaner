import 'package:http/http.dart' as http;

/// Response from HTTP
class Response {
  /// Default constructor
  Response(this.response, this.json);

  /// The HTTP response from the client
  final http.Response response;

  /// Parsed JSON response
  final Map<String, dynamic> json;

  /// HTTP StatusCode
  int statusCode() => response.statusCode;

  /// Check if response is a successful one, or errorneous one
  bool success() => response.statusCode < 300;
}

/// Http interface
abstract class Http {
  /// Makes a GET request to the specified [url]
  Stream<Response> get(String url);

  /// Makes a DELETE request to the specified [url]
  Stream<Response> delete(String url);

  /// Makes a POST request to the specified [url], with the given [body]
  Stream<Response> post(String url, [dynamic body]);

  /// Makes a PUT request to the specified [url], with the given [body]
  Stream<Response> put(String url, [dynamic body]);

  /// Makes a PATCH request to the specified [url], with the given [body]
  Stream<Response> patch(String url, [dynamic body]);

  /// Get the base url for the Http class
  String getBaseUrl();
}
