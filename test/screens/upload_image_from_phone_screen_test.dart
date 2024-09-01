import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api_client.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/blocs/upload_from_gallery_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/access_level_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/screens/upload_image_from_phone_screen.dart';

class MockPictogramApi extends Mock implements PictogramApi {}

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> me() {
    return Stream<GirafUserModel>.value(GirafUserModel(
      id: '1',
      department: 3,
      role: Role.Guardian,
      roleName: 'Guardian',
      displayName: 'Kurt',
      username: 'SpaceLord69',
    ));
  }
}

class MockUploadFromGalleryBloc extends UploadFromGalleryBloc {
  MockUploadFromGalleryBloc(Api api) : super(api);

  @override
  Stream<bool> get isInputValid => _isInputValid.stream;

  final rx_dart.BehaviorSubject<bool> _isInputValid =
      rx_dart.BehaviorSubject<bool>.seeded(false);

  void setInputIsValid(bool b) {
    _isInputValid.add(b);
  }
}

class UploadMock extends MockUploadFromGalleryBloc
    implements UploadFromGalleryBloc {
  UploadMock(Api api) : super(api);
}

void main() {
  late UploadMock bloc;
  late Api api;
  //How the fuck do i initialize Pictogrammodel :/
  setUpAll(() {
    registerFallbackValue(
        PictogramModel(title: '', accessLevel: AccessLevel.PRIVATE));
  });

  setUp(() {
    api = Api('Any');
    api.pictogram = MockPictogramApi();
    api.user = MockUserApi();
    bloc = UploadMock(api);

    di.clearAll();
    di.registerDependency<UploadFromGalleryBloc>(() => bloc);
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc());
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
  });

  testWidgets('Tests error dialog pops up on upload error',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UploadImageFromPhone(
        key: UniqueKey(),
      ),
    ));
    await tester.pumpAndSettle();
    when(() => api.pictogram.create(any()))
        .thenAnswer((_) => Stream<PictogramModel>.error(Exception()));
    bloc.setInputIsValid(true);

    await tester.tap(find.byKey(const Key('SavePictogramButtonKey')));
    await tester.pumpAndSettle();
    expect(find.text('Upload af pictogram fejlede.'), findsOneWidget);
  });
}
