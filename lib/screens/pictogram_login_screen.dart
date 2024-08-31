import 'package:weekplanner/api/api.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/login_screen.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/pictogram_password_widgets/pictogram_password_widget.dart';
import '../di.dart';
import '../style/custom_color.dart' as theme;
import '../style/custom_color.dart';

/// The screen that contains functionality for logging in with pictograms.
class PictogramLoginScreen extends LoginScreen {
  @override
  _PictogramLoginState createState() => _PictogramLoginState();
}

class _PictogramLoginState extends LoginScreenState {
  final Api _api = di.get<Api>();
  late PictogramPassword pictogramPassword;
  void onPasswordUpdate(String? password) {
    if (password != null) {
      passwordCtrl.text = password;
    }
  }

  @override
  void initState() {
    pictogramPassword = PictogramPassword(
      key: const Key('pictogramPasswordWidget'),
      onPasswordChanged: (String pass) {
        onPasswordUpdate(pass);
      },
      api: _api,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      key: const Key('backgroundContainer'),
      width: screenSize.width,
      height: screenSize.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login_screen_background_image.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(shrinkWrap: false, children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: MediaQuery.of(context).orientation ==
                          Orientation.portrait
                      ? const EdgeInsets.symmetric(vertical: 15, horizontal: 52)
                      : const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 230),
                  child: TextFormField(
                    key: const Key('usernameField'),
                    style: const TextStyle(fontSize: GirafFont.large),
                    controller: usernameCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: GirafColors.white,
                        hintText: 'Brugernavn',
                        hintStyle: const TextStyle(
                            color: theme.GirafColors.loginFieldText),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide())),
                  ),
                ),
              ),
            ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            pictogramPassword,
          ],
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Transform.scale(
                  scale: 1.2,
                  child: ElevatedButton(
                    key: const Key('backButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.GirafColors.loginButtonColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onPressed: () {
                      Routes().pop(context);
                    },
                    child: const Text(
                      'Tilbage',
                      style: TextStyle(color: theme.GirafColors.white),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.5,
                  child: ElevatedButton(
                    key: const Key('picLoginButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.GirafColors.loginButtonColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    onPressed: () {
                      loginAction(context);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: theme.GirafColors.white),
                    ),
                  ),
                )
              ],
            )),
      ]),
    ));
  }
}
