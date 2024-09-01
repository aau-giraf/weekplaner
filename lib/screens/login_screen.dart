import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/exceptions/custom_exceptions.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/pictogram_login_screen.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import 'package:weekplanner/widgets/loading_spinner_widget.dart';

import '../style/custom_color.dart' as theme;

/// Logs the user in
class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

/// This is the login state
class LoginScreenState extends State<LoginScreen> {
  /// AuthBloC used to communicate with API
  final AuthBloc authBloc = di.get<AuthBloc>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// This is the username control, that allows for username extraction
  final TextEditingController usernameCtrl = TextEditingController();

  /// This is the password control, that allows for password extraction
  final TextEditingController passwordCtrl = TextEditingController();

  /// Stores the context
  late BuildContext currentContext;

  /// Stores the login status, used for dismissing the LoadingSpinner
  bool loginStatus = false;

  /// This is called when login should be triggered
  void loginAction(BuildContext context) {
    showLoadingSpinner(context, true);
    currentContext = context;
    loginStatus = false;
    authBloc
        .authenticate(usernameCtrl.value.text, passwordCtrl.value.text)
        .then((dynamic result) {
      StreamSubscription<bool>? loginListener;
      loginListener = authBloc.loggedIn.listen((bool snapshot) {
        loginStatus = snapshot;
        // Return if logging out
        if (snapshot) {
          // Pop the loading spinner
          Routes().goHome(context);
        }
        // Stop listening for future logins
        loginListener!.cancel();
      });
    }).catchError((Object error) {
      if (error is ApiException) {
        creatingNotifyDialog('Forkert brugernavn og/eller adgangskode.',
            error.errorKey.toString());
      } else if (error is SocketException) {
        authBloc.checkInternetConnection().then((bool hasInternetConnection) {
          //Not sure this try-catch statement will
          //ever fail and therefore catch anything
          try {
            if (hasInternetConnection) {
              // Checking server connection, if true check username/password
              authBloc.getApiConnection().then((bool hasServerConnection) {
                if (hasServerConnection) {
                  creatingNotifyDialog(
                      'Der er forbindelse'
                      ' til serveren, men der opstod et problem',
                      error.message);
                } else {
                  creatingNotifyDialog(
                      'Der er i øjeblikket'
                          ' ikke forbindelse til serveren.',
                      'ServerConnectionError');
                }
              }).catchError((Object error) {
                unknownErrorDialog(error.toString());
              });
            } else {
              creatingNotifyDialog(
                  'Der er ingen forbindelse'
                      ' til internettet.',
                  'NoConnectionToInternet');
            }
          } catch (err) {
            throw ServerException(
                'There was an error with the server' '\n Error: ',
                err.toString());
          }
        });
      } else {
        unknownErrorDialog('The error is neither an Api problem nor'
            'a socket problem');
      }
    });
  }

  /// Function that creates the notify dialog,
  /// depeninding which login error occured
  void creatingNotifyDialog(String description, String key) {
    /// Remove the loading spinner
    Routes().pop(currentContext);

    /// Show the new NotifyDialog
    showDialog<Center>(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: 'Fejl', description: description, key: Key(key));
        });
  }

  /// Create an unknown error dialog
  void unknownErrorDialog(String key) {
    creatingNotifyDialog(
        'Der skete en ukendt fejl, prøv igen eller '
            'kontakt en administrator',
        'key');
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    ///Used to check if the keyboard is visible
    final bool keyboard = MediaQuery.of(context).viewInsets.bottom > 0;

    final ButtonStyle girafButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.GirafColors.loginButtonColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        padding: portrait
            ? const EdgeInsets.fromLTRB(50, 0, 50, 0)
            : const EdgeInsets.fromLTRB(200, 0, 200, 8),
        decoration: const BoxDecoration(
          // The background of the login-screen
          image: DecorationImage(
            image: AssetImage('assets/login_screen_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              getLogo(keyboard, portrait),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: portrait
                          ? const EdgeInsets.fromLTRB(0, 20, 0, 10)
                          : const EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.GirafColors.grey, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            color: theme.GirafColors.white),
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                        child: TextField(
                          key: const Key('UsernameKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: usernameCtrl,
                          keyboardType: TextInputType.text,
                          // Use email input type for emails.
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Brugernavn',
                            hintStyle: TextStyle(
                                color: theme.GirafColors.loginFieldText),
                            fillColor: theme.GirafColors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.GirafColors.grey, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            color: theme.GirafColors.white),
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          key: const Key('PasswordKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Adgangskode',
                            hintStyle: TextStyle(
                                color: theme.GirafColors.loginFieldText),
                            fillColor: theme.GirafColors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Container(
                        child: Transform.scale(
                          scale: 1.5,
                          child: ElevatedButton(
                            key: const Key('LoginBtnKey'),
                            style: girafButtonStyle,
                            child: const Text(
                              'Login',
                              style: TextStyle(color: theme.GirafColors.white),
                            ),
                            onPressed: () {
                              loginAction(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Transform.scale(
                        scale: 1.2,
                        child: ElevatedButton(
                          style: girafButtonStyle,
                          child: const Text(
                            'Piktogram login',
                            key: Key('UsePictogramLoginKey'),
                            style: TextStyle(color: theme.GirafColors.white),
                          ),
                          onPressed: () {
                            Routes().push(context, PictogramLoginScreen());
                          },
                        ),
                      ),
                    ),
                    // Autologin button, only used for debugging
                    (dotenv.env['DEBUG']) == 'true'
                        ? Container(
                            child: Transform.scale(
                              scale: 1.2,
                              child: ElevatedButton(
                                style: girafButtonStyle,
                                child: const Text(
                                  'Auto-Login',
                                  key: Key('AutoLoginKey'),
                                  style:
                                      TextStyle(color: theme.GirafColors.white),
                                ),
                                onPressed: () {
                                  usernameCtrl.text =
                                      dotenv.env['AUTOFILL_USERNAME']!;
                                  passwordCtrl.text =
                                      dotenv.env['AUTOFILL_PASSWORD']!;
                                  loginAction(context);
                                },
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            ]),
      ),
    );
  }

  /// Returns the giraf logo
  Widget getLogo(bool keyboard, bool portrait) {
    if (keyboard && !portrait) {
      return Container();
    }

    return Container(
      child: const Image(
        image: AssetImage('assets/giraf_splash_logo.png'),
      ),
      padding: const EdgeInsets.only(bottom: 10),
    );
  }
}
