// ignore_for_file: must_be_immutable, public_member_api_docs

import 'dart:async';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/api_exception.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/auth_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';
import '../../style/custom_color.dart' as theme;

/// Screen for changing password
class ChangePasswordScreen extends StatelessWidget {
  /// Constructor
  ChangePasswordScreen(DisplayNameModel user) : _user = user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// This is the username control, that allows for username extraction
  final TextEditingController usernameCtrl = TextEditingController();

  /// This is the password control, that allows for password extraction
  final TextEditingController currentPasswordCtrl = TextEditingController();

  /// Password controller, that allows for extracting the new password
  final TextEditingController newPasswordCtrl = TextEditingController();

  /// Controller for the repeated new password.
  final TextEditingController repeatNewPasswordCtrl = TextEditingController();

  final DisplayNameModel _user;
  final AuthBloc authBloc = di.get<AuthBloc>();
  final Api _api = di.get<Api>();
  late BuildContext currentContext;
  bool loginStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
          key: const ValueKey<String>('widgetKey'),
          title: 'Skift password',
          appBarIcons: const <AppBarIcon, VoidCallback>{},
        ),
        body: buildPasswordChange(context));
  }

  /// Change password screen build
  Widget buildPasswordChange(BuildContext context) {
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: portrait
            ? const EdgeInsets.fromLTRB(50, 300, 50, 0)
            : const EdgeInsets.fromLTRB(200, 125, 200, 8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Nuværende adgangskode',
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
                          key: const Key('OldPasswordKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: currentPasswordCtrl,
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
                    const Text(
                      'Ny adgangskode',
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
                          key: const Key('NewPasswordKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: newPasswordCtrl,
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
                    const Text(
                      'Gentag ny adgangskode',
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
                          key: const Key('RepeatedPasswordKey'),
                          style: const TextStyle(fontSize: GirafFont.large),
                          controller: repeatNewPasswordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Gentag adgangskode',
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
                          child: MaterialButton(
                            key: const Key('ChangePasswordBtnKey'),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: const Text(
                              'Gem',
                              style: TextStyle(color: theme.GirafColors.white),
                            ),
                            onPressed: () {
                              validatePasswords(context);
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

  /// Authenticate User before changing password to new password.
  /// After authentication, the method changes the password to the new password.
  void changePassword(
      DisplayNameModel user, String oldPassword, String newPassword) {
    //Checks if user is logged in
    authBloc
        .authenticate(authBloc.loggedInUser.username!, oldPassword)
        .then((dynamic result) {
      StreamSubscription<bool>? loginListener;
      loginListener = authBloc.loggedIn.listen((bool snapshot) {
        loginStatus = snapshot;
        if (snapshot) {
          _api.account
              .changePasswordWithOld(user.id!, oldPassword, newPassword)
              .listen((_) {})
              .onDone(() {
            createDialog('Kodeord ændret', 'Dit kodeord er blevet ændret',
                const Key('PasswordChanged'));
          });
        }

        /// Stop listening for future logins
        loginListener!.cancel();
      });
    }).catchError((Object error) {
      if (error is ApiException) {
        createDialog('Forkert adgangskode',
            'Den nuværende adgangskode er forkert', const Key('WrongPassword'));
      } else {
        print(error.toString());
        createDialog('Fejl', 'Der skete en ukendt fejl',
            const Key('UnknownErrorOccured'));
      }
    });
  }

  ///Functionality for validating whether input fields are empty
  ///and whether the repeated password for
  ///confirmation is the same as the new password
  void validatePasswords(BuildContext context) {
    currentContext = context;

    if (newPasswordCtrl.text != repeatNewPasswordCtrl.text) {
      createDialog('Fejl', 'Den gentagne adgangskode stemmer ikke overens',
          const Key('NewPasswordNotRepeated'));
    } else if (currentPasswordCtrl.text == '' ||
        newPasswordCtrl.text == '' ||
        repeatNewPasswordCtrl.text == '') {
      createDialog('Fejl', 'Udfyld venligst alle felterne',
          const Key('NewPasswordEmpty'));
    } else if (newPasswordCtrl.text == currentPasswordCtrl.text) {
      createDialog(
          'Fejl',
          'Det nye kodeord må ikke være det samme som det gamle',
          const Key('NewPasswordSameAsOld'));
    } else {
      changePassword(_user, currentPasswordCtrl.text, newPasswordCtrl.text);
    }
  }

  /// Dialog for notifying the user if the occurrs an error or
  /// if the password has been changed
  void createDialog(String title, String description, Key key) {
    /// Show the new NotifyDialog
    showDialog<Center>(
        barrierDismissible: false,
        context: currentContext,
        builder: (BuildContext context) {
          return GirafNotifyDialog(
              title: title, description: description, key: key);
        });
  }
}
