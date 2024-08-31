import 'package:weekplanner/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/pictogram_login_screen.dart';

class MockApi extends Api {
  MockApi(String baseUrl) : super(baseUrl);
}

void main() {
  Api api;

  setUp(() {
    api = MockApi('any');

    di.clearAll();
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
  });

  testWidgets('Screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramLoginScreen()));
  });

  testWidgets('Background is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramLoginScreen()));

    expect(find.byKey(const Key('backgroundContainer')), findsOneWidget);
  });

  testWidgets('Username input field is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramLoginScreen()));

    expect(find.byKey(const Key('usernameField')), findsOneWidget);
  });

  testWidgets('Pictogram password widget is rendered',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramLoginScreen()));

    expect(find.byKey(const Key('pictogramPasswordWidget')), findsOneWidget);
  });

  testWidgets('Both buttons are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: PictogramLoginScreen()));

    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
