// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:io';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import 'package:weekplanner/widgets/giraf_title_header.dart';
import '../../style/custom_color.dart' as theme;

/// Change username screen
class ChangeUsernameScreen extends StatelessWidget {
  /// Constructor
  ChangeUsernameScreen(DisplayNameModel user) : _user = user {
    _settingsBloc.loadSettings(_user);
  }

  final GlobalKey<FormState> _outerForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _innerForm = GlobalKey<FormState>();

  /// This is the username control, that allows for username extraction
  final TextEditingController usernameCtrl = TextEditingController();

  /// This is the username control, that allows for new username extraction
  final TextEditingController newUsernameCtrl = TextEditingController();

  /// This is the username control,
  /// that allows for username confirmation extraction
  final TextEditingController confirmUsernameCtrl = TextEditingController();

  /// Using the authBloc makes it possible to find the user that is logged in.
  final AuthBloc authBloc = di.get<AuthBloc>();
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();
  final Api _api = di.get<Api>();
  final DisplayNameModel _user;
  late BuildContext currentContext; //ignore: public_member_api_docs
  bool loginStatus = false; //ignore: public_member_api_docs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
          title: 'Skift brugernavn',
          key: UniqueKey(),
        ),
        body: buildUsernameChange(context));
  }

  /// Change username screen build
  Widget buildUsernameChange(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        padding: portrait
            ? const EdgeInsets.fromLTRB(50, 0, 50, 0)
            : const EdgeInsets.fromLTRB(200, 0, 200, 8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _outerForm,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Nyt brugernavn',
                      style: TextStyle(
                        fontSize: GirafFont.large,
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
                          key: const Key('UsernameKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: newUsernameCtrl,
                          obscureText: false,
                          decoration: const InputDecoration.collapsed(
                            hintStyle: TextStyle(
                                color: theme.GirafColors.loginFieldText),
                            fillColor: theme.GirafColors.white,
                            hintText: 'Brugernavn',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Container(
                        child: Transform.scale(
                          scale: 1.5,
                          child: MaterialButton(
                            key: const Key('SaveUsernameKey'),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: const Text(
                              'Gem',
                              style: TextStyle(color: theme.GirafColors.white),
                            ),
                            onPressed: () {
                              verifyUsername(context);
                            },
                            color: theme.GirafColors.dialogButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }

  /// Method that creates a dialog that confirms the user.
  void usernameConfirmationDialog(Stream<GirafUserModel> girafUser) {
    showDialog<Center>(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0.0),
            title: Center(
                child: GirafTitleHeader(
              title: 'Verificer bruger',
              key: UniqueKey(),
            )),
            content: Form(
              key: _innerForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ignore: always_specify_types
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      'For at skifte brugernavn, indtast dit '
                      'kodeord for \n${authBloc.loggedInUser.username}',
                      style: const TextStyle(
                        fontSize: GirafFont.small,
                      ),
                    ),
                  ),
                  TextFormField(
                    key: const Key('UsernameConfirmationDialogPasswordForm'),
                    obscureText: true,
                    controller: confirmUsernameCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Adgangskode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      //ignore: always_specify_types
                      GirafButton(
                          key: const Key(
                              'UsernameConfirmationDialogCancelButton'),
                          text: 'Fortryd',
                          width: 121,
                          icon: const ImageIcon(
                            AssetImage('assets/icons/cancel.png'),
                            color: theme.GirafColors.transparentBlack,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      GirafButton(
                          key:
                              const Key('UsernameConfirmationDialogSaveButton'),
                          text: 'Gem',
                          width: 121,
                          icon: const ImageIcon(
                              AssetImage('assets/icons/accept.png'),
                              color: theme.GirafColors.transparentBlack),
                          onPressed: () async {
                            confirmUser(girafUser);
                          }),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  /// This method checks if the password is correct
  /// if not, an error dialog will be displayed
  void confirmUser(Stream<GirafUserModel> girafUser) {
    loginStatus = false;

    /// This authenticates the user with username and password.
    authBloc
        .authenticateFromPopUp(
            authBloc.loggedInUser.username!, confirmUsernameCtrl.text)
        .then((dynamic result) {
      StreamSubscription<bool>? loginListener;
      loginListener = authBloc.loggedIn.listen((bool snapshot) {
        loginStatus = snapshot;
        if (snapshot) {
          updateUser(girafUser);
          Routes().pop(currentContext);
          showDialog<Center>(
              barrierDismissible: false,
              context: currentContext,
              builder: (BuildContext context) {
                return const GirafNotifyDialog(
                    title: 'Brugernavn er gemt',
                    description: 'Dine ændringer er blevet gemt',
                    key: Key('ChangesCompleted'));
              });
        }

        /// Stop listening for future logins
        loginListener!.cancel();
      });
    }).catchError((Object error) {
      if (error is ApiException) {
        creatingErrorDialog('Forkert adgangskode.', error.errorKey.toString());
      } else if (error is SocketException) {
        authBloc.checkInternetConnection().then((bool hasInternetConnection) {
          if (hasInternetConnection) {
            /// Checking server connection, if true check username/password
            authBloc.getApiConnection().then((bool hasServerConnection) {
              if (hasServerConnection) {
                unknownErrorDialog(error.message);
              } else {
                creatingErrorDialog(
                    'Der er i øjeblikket ikke forbindelse til serveren',
                    'ServerConnectionError');
              }
            }).catchError((Object error) {
              unknownErrorDialog(error.toString());
            });
          } else {
            creatingErrorDialog('Der er ingen forbindelse til internettet',
                'NoConnectionToInternet');
          }
        });
      } else {
        unknownErrorDialog('UnknownError');
      }
    });
  }

  /// This method verifies the username.
  Future<void> verifyUsername(BuildContext context) async {
    currentContext = context;
    final GirafUserModel girafUser = await getGirafUser(_api.user.me());

    if (newUsernameCtrl.text == girafUser.username) {
      creatingErrorDialog(
          'Nyt brugernavn må ikke være det '
              'samme som det nuværende brugernavn',
          'NewUsernameEqualOld');
    } else if (newUsernameCtrl.text == '') {
      creatingErrorDialog('Udfyld venligst nyt brugernavn', 'NewUsernameEmpty');
    } else if (newUsernameCtrl.text != girafUser.username) {
      usernameConfirmationDialog(_api.user.get(_user.id!));
    }
  }

  /// Function that creates the notify dialog,
  /// depeninding which login error occured
  void creatingErrorDialog(String description, String key) {
    /// Show the new NotifyDialog
    showDialog<Center>(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: 'Fejl', description: description, key: Key(key));
        });
  }

  /// This method is used to extract a GirafUserModel object from the stream.
  Future<GirafUserModel> getGirafUser(Stream<GirafUserModel> stream) async {
    late GirafUserModel girafUser;
    await for (GirafUserModel value in stream) {
      girafUser = value;
    }
    return girafUser;
  }

  /// Create an unknown error dialog
  void unknownErrorDialog(String key) {
    creatingErrorDialog(
        'Der skete en ukendt fejl, prøv igen eller '
        'kontakt en administrator',
        key);
  }

  /// Updates the user with new username
  //ignore: always_specify_types
  Future updateUser(Stream<GirafUserModel> userStream) async {
    await for (final GirafUserModel value in userStream) {
      value.username = newUsernameCtrl.text;
      _api.user.update(value);
    }
  }
}
