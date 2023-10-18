@Timeout(Duration(seconds: 5))

import 'package:api_client/api/api.dart';
import 'package:async_test/async_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';

void main() {
  Api api = Api('baseUrl');
  ToolbarBloc bloc = ToolbarBloc();

  setUp(() {
    di.clearAll();
    api = Api('any');
    di.registerDependency<Api>(() => api);
    di.registerDependency<AuthBloc>(() => AuthBloc(api));
    bloc = ToolbarBloc();
    di.registerDependency<ToolbarBloc>(() => bloc);
  });

  test('Should insert log out icon when none are defined', async((DoneFn done) {
    bloc.visibleButtons.skip(1).listen((List<IconButton> response) {
      expect(response.length, 1);
      done();
    });
    bloc.updateIcons(null, null);
  })); // FIXME: Timout

  // test('Defined icon is added to stream', async((DoneFn done) {
  //   final Map<AppBarIcon, VoidCallback> icons = <AppBarIcon, VoidCallback>{
  //     AppBarIcon.undo: () {}
  //   };

  //   bloc.visibleButtons.skip(1).listen((List<IconButton> response) {
  //     expect(response.length, 1);
  //     done();
  //   });

  //   bloc.updateIcons(icons, null);
  // })); FIXME: Timeout

  // test('Defined icons are added to stream', async((DoneFn done) {
  //   final Map<AppBarIcon, VoidCallback> icons = <AppBarIcon, VoidCallback>{
  //     AppBarIcon.undo: () {},
  //     AppBarIcon.search: () {}
  //   };

  //   bloc.visibleButtons.skip(1).listen((List<IconButton> response) {
  //     expect(response.length, 2);
  //     done();
  //   });

  //   bloc.updateIcons(icons, null);
  // })); FIXME: Timeout
}
