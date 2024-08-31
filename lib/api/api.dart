import 'package:weekplanner/api/account_api.dart';
import 'package:weekplanner/api/activity_api.dart';
import 'package:weekplanner/api/alternate_name_api.dart';
import 'package:weekplanner/api/department_api.dart';
import 'package:weekplanner/api/pictogram_api.dart';
import 'package:weekplanner/api/status_api.dart';
import 'package:weekplanner/api/user_api.dart';
import 'package:weekplanner/api/week_api.dart';
import 'package:weekplanner/api/week_template_api.dart';
import 'package:weekplanner/http/http_client.dart';
import 'package:weekplanner/persistence/persistence.dart';
import 'package:weekplanner/persistence/persistence_client.dart';

import 'connectivity_api.dart';

/// Weekplanner API
class Api {
  /// Default constructor
  Api(this.baseUrl,
      [String tokenKey = 'token',
      Duration timeout = const Duration(seconds: 5)]) {
    final Persistence persist = PersistenceClient();
    status = StatusApi(HttpClient(
        baseUrl: '$baseUrl/v1/Status',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    connectivity = ConnectivityApi(status);
    account = AccountApi(
        HttpClient(
            baseUrl: '$baseUrl/v2/Account',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        persist);
    department = DepartmentApi(HttpClient(
        baseUrl: '$baseUrl/v1/Department',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    week = WeekApi(HttpClient(
        baseUrl: '$baseUrl/v1/Week',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    pictogram = PictogramApi(HttpClient(
        baseUrl: '$baseUrl/v1/Pictogram',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    activity = ActivityApi(HttpClient(
        baseUrl: '$baseUrl/v2/Activity',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    weekTemplate = WeekTemplateApi(HttpClient(
        baseUrl: '$baseUrl/v1/WeekTemplate',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
    user = UserApi(
        HttpClient(
            baseUrl: '$baseUrl/v1/User',
            persist: persist,
            tokenKey: tokenKey,
            timeout: timeout),
        connectivity);
    alternateName = AlternateNameApi(HttpClient(
        baseUrl: '$baseUrl/v2/AlternateName',
        persist: persist,
        tokenKey: tokenKey,
        timeout: timeout));
  }

  /// To access account endpoints
  late AccountApi account;

  /// To access department endpoints
  late DepartmentApi department;

  /// To access pictogram endpoints
  late PictogramApi pictogram;

  /// To access activity endpoints
  late ActivityApi activity;

  /// To access week endpoints
  late WeekApi week;

  /// To access status endpoints
  late StatusApi status;

  /// To access status endpoints
  late ConnectivityApi connectivity;

  /// To access weekTemplate endpoints
  late WeekTemplateApi weekTemplate;

  /// To access user endpoints
  late UserApi user;

  /// To access alternateName endpoints
  late AlternateNameApi alternateName;

  /// The base of all requests.
  ///
  /// Example: if set to `http://google.com`, then a get request with url
  /// `/search` will resolve to `http://google.com/search`
  String baseUrl;

  /// Destroy the API
  void dispose() {}
}
