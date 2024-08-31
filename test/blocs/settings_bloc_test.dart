import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/cancel_mark_enum.dart';
import 'package:weekplanner/models/enums/complete_mark_enum.dart';
import 'package:weekplanner/models/enums/default_timer_enum.dart';
import 'package:weekplanner/models/enums/giraf_theme_enum.dart';
import 'package:weekplanner/models/enums/orientation_enum.dart';
import 'package:weekplanner/models/enums/role_enum.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';

class MockUserApi extends Mock implements UserApi {
  @override
  Stream<GirafUserModel> get(String id) {
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

class MockSettingsModel extends Mock implements SettingsModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockSettingsModel());
  });

  Api api = Api('any');
  SettingsBloc settingsBloc = SettingsBloc(api);

  final DisplayNameModel user = DisplayNameModel(
      role: Role.Citizen.toString(), displayName: 'Citizen', id: '1');
  SettingsModel settings = SettingsModel(
    orientation: Orientation.Portrait,
    completeMark: CompleteMark.Checkmark,
    cancelMark: CancelMark.Cross,
    defaultTimer: DefaultTimer.PieChart,
    timerSeconds: 1,
    activitiesCount: 1,
    theme: GirafTheme.GirafYellow,
    weekDayColors: null,
    pictogramText: false,
    nrOfActivitiesToDisplay: null,
    showOnlyActivities: false,
    showSettingsForCitizen: false,
  );

  final SettingsModel updatedSettings = SettingsModel(
    orientation: Orientation.Landscape,
    completeMark: CompleteMark.MovedRight,
    cancelMark: CancelMark.Removed,
    defaultTimer: DefaultTimer.Hourglass,
    timerSeconds: 2,
    activitiesCount: 3,
    theme: GirafTheme.GirafYellow,
    weekDayColors: null,
    pictogramText: true,
  );

  setUp(() {
    api = Api('any');
    api.user = MockUserApi();

    // Mocks the api call to get settings
    when(() => api.user.getSettings(any())).thenAnswer((Invocation inv) {
      return Stream<SettingsModel>.value(settings);
    });

    // Mocks the api call to update settings
    when(() => api.user.updateSettings(any(), any()))
        .thenAnswer((Invocation inv) {
      settings = updatedSettings;
      return Stream<bool>.value(true);
    });

    settingsBloc = SettingsBloc(api);
  });

  test('Can load settings from username model', async((DoneFn done) {
    settingsBloc.settings.listen((SettingsModel? response) {
      expect(response, isNotNull);
      expect(response!.toJson(), equals(settings.toJson()));
      verify(() => api.user.getSettings(any()));
      done();
    });

    settingsBloc.loadSettings(user);
  }));

  test('Can update settings', async((DoneFn done) {
    settingsBloc.settings.listen((SettingsModel? loadedSettings) {
      expect(loadedSettings, isNotNull);
      expect(loadedSettings!.toJson(), equals(updatedSettings.toJson()));
      done();
    });

    settingsBloc.updateSettings(user.id!, settings);
    settingsBloc.loadSettings(user);
  }));

  test('Should dispose stream', async((DoneFn done) {
    settingsBloc.settings.listen((_) {}, onDone: done);
    settingsBloc.dispose();
  }));
}
