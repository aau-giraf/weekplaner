import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/api/connectivity_api.dart';
import 'package:weekplanner/api/status_api.dart';
import 'package:weekplanner/http/http_mock.dart';

class ConnectivityMock implements Connectivity {
  bool isConnected = true;

  @override
  Future<ConnectivityResult> checkConnectivity() async {
    if (!isConnected) {
      return ConnectivityResult.none;
    }
    return ConnectivityResult.wifi;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      throw UnimplementedError();
}

void main() {
  late ConnectivityMock connectivityMock;
  late ConnectivityApi connectivityApi;
  late HttpMock httpMock;

  setUp(() {
    httpMock = HttpMock();
    connectivityMock = ConnectivityMock();
    connectivityApi =
        ConnectivityApi.withConnectivity(StatusApi(httpMock), connectivityMock);
  });

  test('ShouldReturnFalse_WhenDeviceConnectivity_IsNone', () {
    connectivityMock.isConnected = false;

    connectivityApi.connectivityStream.listen((bool value) {
      expect(value, false);
    });

    connectivityApi.check().then(expectAsync1((bool connectivity) {
      expect(connectivity, false);
    }));
  });

  test('ShouldReturnTrue_WhenDeviceConnectivity_IsWifi', () async {
    connectivityApi.check().then(expectAsync1((bool connectivity) {
      expect(connectivity, true);
    }));

    await Future<dynamic>.delayed(const Duration(seconds: 1));

    httpMock.expectOne(url: '/', method: Method.get).flush(<String, dynamic>{
      'data': true,
      'success': true,
      'message': '',
      'errorKey': 'NoError'
    });
  });

  tearDown(() {
    httpMock.verify();
  });
}
