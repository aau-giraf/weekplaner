import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/models/enums/error_key.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

/// Class for translating error codes to readable messages for the users
class ApiErrorTranslator {
  /// Catch errors thrown by the api_client
  /// (Can only handle ApiExceptions for now)
  void catchApiError(Object error, BuildContext context) {
    showDialog<Center>(

        /// exception handler to handle web_api exceptions
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: 'Fejl',
              description: getErrorMessage(error as ApiException),
              key: const Key('ErrorMessageDialog'));
        });
  }

  ///Get apropriate error message based on error code
  String getErrorMessage(ApiException error) {
    switch (error.errorKey) {
      case ErrorKey.UserAlreadyExists:
        return 'Brugernavnet eksisterer allerede';
      case ErrorKey.Error:
        // Undefined errors, the message is in english
        // as we cant predict why it was cast
        return 'message: ' +
            (error.errorMessage ?? 'No error message provided') +
            '\nDetails: ' +
            (error.errorDetails ?? 'No error details provided');
      default:
        return 'Fejl: ' +
            (error.errorMessage ?? 'No error message provided') +
            '\nDetails: ' +
            (error.errorDetails ?? 'No error details provided');
    }
  }
}
