import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/enums/error_key.dart';

/// Represents an exception from an API call
class ApiException implements Exception {
  /// Create an API exception, when f.x success was false, and errorKey was set
  ApiException(this.response) {
    errorKey = ErrorKey.values.firstWhere(
        (ErrorKey? f) =>
            f.toString() == 'ErrorKey.' + response.json['errorKey'],
        orElse: () => 'null' as ErrorKey);

    final String? message = response.json['message'];
    if (message?.isNotEmpty ?? false) {
      errorMessage = response.json['message'].toString();
    } else {
      errorMessage = 'Something went wrong.';
    }

    final String? details = response.json['details'];
    if (details != null) {
      errorDetails = response.json['details'];
    } else {
      errorDetails = '';
    }
  }

  /// Response involved in the exception
  final Response response;

  /// The error key derived from the response
  ErrorKey errorKey = ErrorKey.NoError;

  /// The message describing the error
  String? errorMessage;

  /// The details of the error that happened, most of the time it is empty
  String? errorDetails;

  @override
  String toString() => '[ApiException]: ${response.json['errorKey']}';
}
