import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api_client.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/new_citizen_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/persistence/persistence_client.dart';
import 'package:weekplanner/screens/new_citizen_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';

/// Mock Account Api needed to insert errors int othe datastream from a place
/// where listen().onError could catch it
class MockAccountApi extends AccountApi {
  MockAccountApi(PersistenceClient persist)
      : super(HttpClient(baseUrl: '', persist: persist), persist);

  /// override of the register function, which returns an error
  /// if 'username' == alreadyExists. Returns a normal GirafUserModel otherwise
  @override
  Stream<GirafUserModel> register(String username, String password,
      String displayName, List<int>? profilePicture,
      {required int departmentId, required Role role}) {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'displayName': displayName,
      'password': password,
      'department': departmentId,
      'id': '2',
      'role': 2,
      'roleName': '' + role.toString().split('.').last,
    };

    if (username == 'alreadyExists') {
      final http.Response mockHttpResponse = http.Response(
          // ignore: lines_longer_than_80_chars
          'message: User already exists, details: A user with the given username already exists, errorKey: UserAlreadyExists',
          401);
      final Stream<Response> mockResponse = Stream<Response>.fromFuture(
          userAlreadyExistsResponse(mockHttpResponse));
      return mockResponse.map((Response res) => throw ApiException(res));
    } else if (username == 'defaultError') {
      final http.Response mockHttpResponse = http.Response(
          // ignore: lines_longer_than_80_chars
          'message: something went wrong, details: unexpected error, errorKey: Error',
          401);
      final Stream<Response> mockResponse = Stream<Response>.fromFuture(
          unexpectedErrorResponse(mockHttpResponse));
      return mockResponse.map((Response res) => throw ApiException(res));
    }
    return Stream<GirafUserModel>.fromFuture(createMockUserModel(body));
  }

  /// Creates the Error for the stream
  Future<Response> userAlreadyExistsResponse(http.Response response) async {
    return Response(response, <String, dynamic>{
      'message': 'User already exists',
      'details': 'A user with the given username already exists',
      'errorKey': 'UserAlreadyExists'
    });
  }

  Future<Response> unexpectedErrorResponse(http.Response response) async {
    return Response(response, <String, dynamic>{
      'message': 'something went wrong',
      'details': 'unexpected error',
      'errorKey': 'Error'
    });
  }

  /// Creates the model for the stream
  Future<GirafUserModel> createMockUserModel(Map<String, dynamic> body) async {
    return GirafUserModel.fromJson(body);
  }
}

/// Mock api needed to chance the UserApi to MockUserApi
class MockApi extends Api {
  MockApi(String baseUrl) : super(baseUrl) {
    account = MockAccountApi(PersistenceClient());
    user = MockUserApi();
  }
}

class MockNewCitizenBloc extends NewCitizenBloc {
  MockNewCitizenBloc(this.api) : super(api);

  bool acceptAllInputs = true;
  Api api;

  @override
  Stream<bool> get validDisplayNameStream =>
      Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get validUsernameStream => Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get validPasswordStream => Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get validPasswordVerificationStream =>
      Stream<bool>.value(acceptAllInputs);

  @override
  Stream<bool> get allInputsAreValidStream => Stream<bool>.value(true);
}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
        id: '1',
        department: 1,
        role: Role.Guardian,
        roleName: 'Guardian',
        displayName: 'Kirsten Birgit',
        username: 'kb7913'));
  }
}

void main() {
  late Api api;
  late MockNewCitizenBloc mockNewCitizenBloc;

  setUp(() {
    api = MockApi('any');
    mockNewCitizenBloc = MockNewCitizenBloc(api);

    di.clearAll();
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<NewCitizenBloc>(() => mockNewCitizenBloc);
  });

  testWidgets('Screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
  });

  testWidgets('The screen has a Giraf App Bar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));

    expect(find.byWidgetPredicate((Widget widget) => widget is GirafAppBar),
        findsOneWidget);
  });

  testWidgets('Input fields are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));

    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('Switch is rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));

    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('Buttons are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    final TestGesture gesture = await tester.startGesture(const Offset(0, 300));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pump();

    expect(find.byType(GirafButton, skipOffstage: false), findsNWidgets(3));
  });

  testWidgets('You can input a display name', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.enterText(
        find.byKey(const Key('displayNameField')), 'Birgit Jensen');
    await tester.pump();

    expect(find.text('Birgit Jensen'), findsNWidgets(1));
  });

  testWidgets('You can input a username', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.enterText(find.byKey(const Key('usernameField')), 'birgit');
    await tester.pump();

    expect(find.text('birgit'), findsNWidgets(1));
  });

  testWidgets('Role radio buttons are rendered', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));

    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('You can input a password', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    await tester.pump();

    expect(find.text('password'), findsNWidgets(1));
  });

  testWidgets('You can input a password verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.enterText(
        find.byKey(const Key('passwordVerifyField')), 'password');
    await tester.pump();

    expect(find.text('password'), findsNWidgets(1));
  });

  testWidgets('Save button is disabled by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    final TestGesture gesture = await tester.startGesture(const Offset(0, 300));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pump();

    expect(
        tester
            .widget<GirafButton>(
                find.byKey(const Key('saveButton'), skipOffstage: false))
            .isEnabled,
        isFalse);
  });

  testWidgets('New user so, no error message should appear',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.pump();

    await tester.enterText(
        find.byKey(const Key('displayNameField')), 'mockDisplayName');
    await tester.enterText(find.byKey(const Key('usernameField')), 'NewUser');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');
    await tester.enterText(
        find.byKey(const Key('passwordVerifyField')), 'password');

    final TestGesture gesture = await tester.startGesture(const Offset(0, 300));
    await gesture.moveBy(const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveButton'), skipOffstage: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ErrorMessageDialog')), findsNWidgets(0));
  });

  testWidgets('"Videre" button should be disabled by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NewCitizenScreen()));
    await tester.pump();

    expect(
        tester
            .widget<GirafButton>(find.byKey(const Key('nextButton')))
            .isEnabled,
        isFalse);
  });
}
