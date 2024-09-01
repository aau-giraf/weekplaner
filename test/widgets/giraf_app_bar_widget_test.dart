import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/toolbar_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/enums/weekplan_mode.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';

/// Mocked authbloc by the use of Mockito
class MockAuth extends Mock implements AuthBloc {
  @override
  Stream<bool> get loggedIn => _loggedIn.stream;
  final rx_dart.BehaviorSubject<bool> _loggedIn =
      rx_dart.BehaviorSubject<bool>.seeded(true);

  String loggedInUsername = 'Graatand';

  @override
  void logout() {
    _loggedIn.add(false);
  }
}

/// Mockec authbloc without the use of Mockito
class MockAuthBloc extends AuthBloc {
  MockAuthBloc(Api api) : super(api);

  @override
  Future<void> authenticateFromPopUp(String username, String password) async {
    if (password == 'password') {
      setAttempt(true);
      setMode(WeekplanMode.guardian);
    }
  }
}

class MockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
      title: 'TestTitle',
      appBarIcons: <AppBarIcon, VoidCallback>{
        AppBarIcon.logout: () {},
        AppBarIcon.changeToGuardian: () {},
      },
      key: UniqueKey(),
    ));
  }
}

class MockScreenForErrorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ToolbarBloc bloc = di.get<ToolbarBloc>();
    return Scaffold(
        body: GirafButton(
      key: const Key('IconChangeToGuardian'),
      onPressed: () {
        bloc.createPopupDialog(context).show();
      },
    ));
  }
}

void main() {
  late ToolbarBloc bloc;
  late MockAuth authBloc;
  late final Api api = Api('any');

  setUp(() {
    di.clearAll();
    di.registerDependency<Api>(() => api);
    authBloc = MockAuth();
    di.registerDependency<AuthBloc>(() => authBloc);
    bloc = ToolbarBloc();
    di.registerDependency<ToolbarBloc>(() => bloc);
  });

  // Used to wrap a widget into a materialapp, otherwise the widget is not
  // testable
  Widget makeTestableWidget({Widget? child}) {
    return MaterialApp(
      home: child,
    );
  }

  void setupAlternativeDependencies() {
    di.registerDependency<AuthBloc>(() => MockAuthBloc(api), override: true);
    di.registerDependency<ToolbarBloc>(() => ToolbarBloc(), override: true);
  }

  testWidgets('Elements on dialog should be visible',
      (WidgetTester tester) async {
    // we have to use a diffent authbloc, where everything is not overridden
    setupAlternativeDependencies();
    await tester.pumpWidget(MaterialApp(home: MockScreenForErrorDialog()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('IconChangeToGuardian')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('SwitchToGuardianPassword')), findsOneWidget);

    expect(find.byKey(const Key('SwitchToGuardianSubmit')), findsOneWidget);
  });

  testWidgets('Wrong credentials should show error dialog',
      (WidgetTester tester) async {
    // we have to use a diffent authbloc, where everything is not overridden
    setupAlternativeDependencies();
    await tester.pumpWidget(MaterialApp(home: MockScreenForErrorDialog()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('IconChangeToGuardian')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('SwitchToGuardianPassword')), 'abc');

    await tester.tap(find.byKey(const Key('SwitchToGuardianSubmit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('WrongPasswordDialog')), findsOneWidget);
  });

  testWidgets('Right credentials should not show error dialog',
      (WidgetTester tester) async {
    setupAlternativeDependencies();
    await tester
        .pumpWidget(makeTestableWidget(child: MockScreenForErrorDialog()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('IconChangeToGuardian')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('SwitchToGuardianPassword')), 'password');
    await tester.tap(find.byKey(const Key('SwitchToGuardianSubmit')));

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byKey(const Key('WrongPasswordDialog')), findsNothing);
  });

  testWidgets('Has toolbar with title', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));

    expect(find.text('Ugeplan'), findsOneWidget);
  });

  testWidgets('Display default icon when given no icons to display',
      (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: null,
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();
    expect(find.byTooltip('Log ud'), findsOneWidget);
  });

  testWidgets('Accept button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.accept: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Accepter').first, findsOneWidget);
  });

  testWidgets('Add button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.add: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Tilføj').first, findsOneWidget);
  });

  testWidgets('Add timer button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.addTimer: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Tilføj timer').first, findsOneWidget);
  });

  testWidgets('Back button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.back: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Tilbage').first, findsOneWidget);
  });

  testWidgets('Burger menu button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.burgerMenu: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Åbn menu').first, findsOneWidget);
  });

  testWidgets('Cancel button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.cancel: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Fortryd').first, findsOneWidget);
  });

  testWidgets('Change to citizen button is displayed',
      (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{
        AppBarIcon.changeToCitizen: () {}
      },
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Skift til borger tilstand').first, findsOneWidget);
  });

  testWidgets('Change to guardian button is displayed',
      (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{
        AppBarIcon.changeToGuardian: () {}
      },
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Skift til værge tilstand').first, findsOneWidget);
  });

  testWidgets('Copy button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.copy: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Kopier').first, findsOneWidget);
  });

  testWidgets('Delete button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.delete: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Slet').first, findsOneWidget);
  });

  testWidgets('Edit button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.edit: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Rediger').first, findsOneWidget);
  });

  testWidgets('Help button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.help: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Hjælp').first, findsOneWidget);
  });

  testWidgets('Home button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.home: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Gå til startside').first, findsOneWidget);
  });

  testWidgets('Log out button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.logout: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Log ud').first, findsOneWidget);
  });

  testWidgets('Profile button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.profile: () {}},
      key: UniqueKey(),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Vis profil').first, findsOneWidget);
  });

  testWidgets('Redo button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
        title: 'Ugeplan',
        appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.redo: () {}},
        key: UniqueKey());

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Gendan').first, findsOneWidget);
  });

  testWidgets('Save button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
        title: 'Ugeplan',
        appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.save: () {}},
        key: UniqueKey());

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Gem').first, findsOneWidget);
  });

  testWidgets('Search button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
        title: 'Ugeplan',
        appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.search: () {}},
        key: UniqueKey());

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Søg').first, findsOneWidget);
  });

  testWidgets('Settings button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
        title: 'Ugeplan',
        appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.settings: () {}},
        key: UniqueKey());

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Indstillinger').first, findsOneWidget);
  });

  testWidgets('Undo button is displayed', (WidgetTester tester) async {
    final GirafAppBar girafAppBar = GirafAppBar(
      title: 'Ugeplan',
      appBarIcons: <AppBarIcon, VoidCallback>{AppBarIcon.undo: () {}},
      key: const ValueKey<String>('undoBtnKey'),
    );

    await tester.pumpWidget(makeTestableWidget(child: girafAppBar));
    await tester.pump();

    expect(find.byTooltip('Fortryd').first, findsOneWidget);
  });

  testWidgets('GirafConfirmDialog is shown on logout icon press',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MockScreen()));
    await tester.pump();
    final Finder logoutIconFinder = find.byTooltip('Log ud').last;
    expect(logoutIconFinder, findsOneWidget);
    await tester.tap(logoutIconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(GirafConfirmDialog), findsOneWidget);
  });

  testWidgets('User is logged out on confirmation in GirafConfirmDialog',
      (WidgetTester tester) async {
    final Completer<bool> done = Completer<bool>();
    await tester.pumpWidget(MaterialApp(home: MockScreen()));
    await tester.pump();
    expect(find.byTooltip('Log ud').last, findsOneWidget);
    await tester.tap(find.byTooltip('Log ud').last);
    await tester.pumpAndSettle();
    expect(find.byType(GirafConfirmDialog), findsOneWidget);
    expect(find.byKey(const Key('ConfirmDialogConfirmButton')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ConfirmDialogConfirmButton')));
    authBloc.loggedIn.listen((bool statusLogout) async {
      if (statusLogout == false) {
        expect(statusLogout, isFalse);
        done.complete(true);
      }
    });
    await done.future;
  });
}
