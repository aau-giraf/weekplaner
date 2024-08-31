import 'package:weekplanner/persistence/persistence_client.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  void mockMethodCallHandler() {
    //Necessary for tests to pass on macos
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // WidgetsFlutterBinding.ensureInitialized();
    TestWidgetsFlutterBinding.ensureInitialized();

    //The old package is deprecated so we had to write it ourselves
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // set initial values here if desired
      }

      if (methodCall.method == 'setString') {
        // pass here
        return null;
      }
      fail('Should call setString');
    });
  }

  test('Should store', () async {
    mockMethodCallHandler();

    const String token = 'Test Token';
    await PersistenceClient().set('token', token);
  });

  test('Should get token', () async {
    mockMethodCallHandler();

    await PersistenceClient().get('token');
  });
}
