import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/bootstrap.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/screens/choose_citizen_screen.dart';
import 'package:weekplanner/screens/login_screen.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    // Register all dependencies for injector
    Bootstrap().register();

    runApp(const Giraf());
  } catch (e) {
    print('Error loading .env file: $e');
    // Handle the error appropriately, maybe show an error screen
  }
}

class Giraf extends StatelessWidget {
  const Giraf({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekplanner',
      theme: ThemeData(fontFamily: 'Quicksand'),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthBloc _authBloc = di.get<AuthBloc>();
  final Api _api = di.get<Api>();

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _api.connectivity.connectivityStream.listen((dynamic event) {
      if (event == false) {
        _lostConnectionDialog();
      }
    });
  }

  void _lostConnectionDialog() {
    showDialog<Center>(
        context: context,
        builder: (BuildContext context) {
          return const GirafNotifyDialog(
              key: ValueKey<String>('noConnectionKey'),
              title: 'Mistet forbindelse',
              description: 'Ændringer bliver gemt når du får forbindelse igen');
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _authBloc.loggedIn,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final bool loggedIn = snapshot.data ?? false;

        if (loggedIn) {
          return ChooseCitizenScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
