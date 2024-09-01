import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api_client.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/new_pictogram_password_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/persistence/persistence_client.dart';
import 'package:weekplanner/screens/new_pictogram_password_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/pictogram_password_widgets/pictogram_password_widget.dart';

class MockAccountApi extends AccountApi {
  MockAccountApi(PersistenceClient persist)
      : super(HttpClient(baseUrl: '', persist: persist), persist);
}

/// Mock api needed to chance the UserApi to MockUserApi
class MockApi extends Api {
  MockApi(String baseUrl) : super(baseUrl) {
    account = MockAccountApi(PersistenceClient());
    user = MockUserApi();
  }
}

class MockNewPictogramPasswordBloc extends NewPictogramPasswordBloc {
  MockNewPictogramPasswordBloc(this.api) : super(api);

  Api api;
}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
        id: '1',
        department: 1,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Piktogram Benytter',
        username: 'pictogramUser'));
  }
}

void main() {
  late Api api;
  late MockNewPictogramPasswordBloc mockNewPictogramPasswordBloc;

  setUp(() {
    api = MockApi('any');
    mockNewPictogramPasswordBloc = MockNewPictogramPasswordBloc(api);

    di.clearAll();
    di.registerDependency(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<NewPictogramPasswordBloc>(
        () => mockNewPictogramPasswordBloc);
  });

  testWidgets('Screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NewPictogramPasswordScreen(
            'testUserName', 'testDisplayName', Uint8List(1))));
  });

  testWidgets('The screen has a Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NewPictogramPasswordScreen(
            'testUserName', 'testDisplayName', Uint8List(1))));

    expect(find.byType(GirafAppBar), findsOneWidget);
  });

  testWidgets('Text is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NewPictogramPasswordScreen(
            'testUserName', 'testDisplayName', Uint8List(1))));

    expect(
        find.text('Opret piktogram kode til testDisplayName'), findsOneWidget);
  });

  testWidgets('Pictogram password widget is rendered',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NewPictogramPasswordScreen(
            'testUserName', 'testDisplayName', Uint8List(1))));

    expect(find.byType(PictogramPassword), findsOneWidget);
  });

  testWidgets('Save button is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: NewPictogramPasswordScreen(
            'testUserName', 'testDisplayName', Uint8List(1))));

    expect(find.byType(GirafButton), findsOneWidget);
  });
}
