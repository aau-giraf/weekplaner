import 'dart:async';

import 'package:weekplanner/api/status_api.dart';
import 'package:connectivity/connectivity.dart';

/// Connectivity methods
class ConnectivityApi {
  /// Default constructor
  ConnectivityApi(this._status) : _connectivity = Connectivity();

  /// Constructor with custom connectivity object
  ConnectivityApi.withConnectivity(this._status, this._connectivity);

  final StatusApi _status;
  final Connectivity _connectivity;
  final Duration _successConnectivityDuration = const Duration(seconds: 10);
  final Duration _failureConnectivityDuration = const Duration(seconds: 5);
  final StreamController<bool> _hasConnection =
      StreamController<bool>.broadcast();

  /// This stream can be listened to, to get all connectivity updates
  Stream<bool> get connectivityStream => _hasConnection.stream;
  bool _lastStatus = true;
  DateTime _timeOfLastCheck = DateTime(0);

  /// This method is used when you need to handle specific cases,
  /// when you have connectivity and when you don't, asynchronously.
  ///
  /// If you are connected, the connected function is called,
  /// otherwise, the disconnected function is called.
  ///
  /// A stream of type T is returned, which only receives one event,
  /// when the complete function is called on the completer,
  /// after which the stream is closed.
  Stream<T> handle<T>(
      FutureOr<T> Function() connected, FutureOr<T> Function() disconnected) {
    final Completer<T> completer = Completer<T>();

    check().then((bool isConnected) {
      if (isConnected) {
        completer.complete(connected());
      } else {
        completer.complete(disconnected());
      }
    });

    return Stream<T>.fromFuture(completer.future);
  }

  /// This method is used for checking the connection to the internet,
  /// and the server.
  ///
  /// If this method is called within [_successConnectivityDuration] seconds
  /// from last success, it returns true.
  /// If this method is called within [_failureConnectivityDuration] seconds
  /// from last failure, it returns false.
  ///
  /// Returns true if a connection is present, otherwise returns false.
  Future<bool> check() async {
    final Duration diff = DateTime.now().difference(_timeOfLastCheck);
    if (_lastStatus && diff < _successConnectivityDuration ||
        !_lastStatus && diff < _failureConnectivityDuration) {
      return _lastStatus;
    }

    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      _setConnection(false);
      return false;
    }

    final Completer<bool> completer = Completer<bool>();
    _status.status().listen((bool status) {
      _setConnection(status);
      completer.complete(status);
    }).onError((Object error) {
      _setConnection(false);
      completer.complete(false);
    });

    return completer.future;
  }

  /// This method is used to update the value of [_lastStatus],
  /// to the value of [value], as well as updating the value
  /// of [_timeOfLastCheck], to [DateTime.now].
  ///
  /// If the value of [value] is different from the value of [_lastStatus],
  /// then an event is fired on the [_hasConnection] stream.
  void _setConnection(bool value) {
    if (_lastStatus != (_lastStatus = value)) {
      _hasConnection.add(value);
    }
    _timeOfLastCheck = DateTime.now();
  }
}
