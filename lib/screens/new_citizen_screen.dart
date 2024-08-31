import 'dart:io';
import 'dart:typed_data';

import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/api/errorcode_translator.dart';
import 'package:weekplanner/blocs/new_citizen_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/new_pictogram_password_screen.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';

/// Role names for Weekplanner
enum Roles {
  /// Guardian role
  guardian,

  /// Trustee  role
  trustee,

  /// Citizen role
  citizen
}

/// Screen for creating a new citizen
// ignore: must_be_immutable
class NewCitizenScreen extends StatefulWidget {
  /// Constructor for the NewCitizenScreen()
  NewCitizenScreen() : _bloc = di.get<NewCitizenBloc>() {
    _bloc.initialize();
  }

  ///Variable representing the screen height
  dynamic screenHeight;

  ///Variable representing the screen width
  dynamic screenWidth;

  final NewCitizenBloc _bloc;

  Widget _displayImage(File? image) {
    return Container(
      //margin: const EdgeInsets.all(10.0),
      child: CircleAvatar(
        key: const Key('WidgetAvatar'),
        radius: 200,
        backgroundImage: FileImage(image!),
      ),
    );
  }

  Widget _displayIfNoImage() {
    return Container(
      //margin: const EdgeInsets.all(10.0),
      child: const CircleAvatar(
        radius: 200,
        backgroundImage: AssetImage('assets/login_screen_background_image.png'),
      ),
    );
  }

  @override
  _NewCitizenScreenState createState() => _NewCitizenScreenState();
}

class _NewCitizenScreenState extends State<NewCitizenScreen> {
  final ApiErrorTranslator _translator = ApiErrorTranslator();
  Roles _role = Roles.citizen;

  void previousRoute(GirafUserModel response) {
    Routes().pop<GirafUserModel>(context, response);
    widget._bloc.resetBloc();
  }

  @override
  Widget build(BuildContext context) {
    widget.screenHeight = MediaQuery.of(context).size.height;
    widget.screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GirafAppBar(
        title: 'Ny bruger',
        key: UniqueKey(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 6, right: 16, bottom: 2.5),
              child: StreamBuilder<bool>(
                  stream: widget._bloc.validDisplayNameStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return TextFormField(
                      key: const Key('displayNameField'),
                      decoration: InputDecoration(
                        border:
                            const OutlineInputBorder(borderSide: BorderSide()),
                        labelText: 'Navn',
                        errorText: (snapshot.data == true) &&
                                widget._bloc.displayNameController.value != null
                            ? null
                            : 'Navn skal udfyldes',
                      ),
                      onChanged: widget._bloc.onDisplayNameChange.add,
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 6, right: 16, bottom: 2.5),
              child: StreamBuilder<bool>(
                  stream: widget._bloc.validDisplayNameStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                key: const Key('guardianRadioButton'),
                                title: const Text('Guardian'),
                                leading: Radio<Roles>(
                                  value: Roles.guardian,
                                  groupValue: _role,
                                  onChanged: (Roles? value) {
                                    setState(() {
                                      _role = value!;
                                      widget._bloc.onUsePictogramPasswordChange
                                          .add(value == Roles.citizen);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                key: const Key('trusteeRadioButton'),
                                title: const Text('Trustee'),
                                leading: Radio<Roles>(
                                  value: Roles.trustee,
                                  groupValue: _role,
                                  onChanged: (Roles? value) {
                                    setState(() {
                                      _role = value!;
                                      widget._bloc.onUsePictogramPasswordChange
                                          .add(value == Roles.citizen);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                key: const Key('citizenRadioButton'),
                                title: const Text('Citizen'),
                                leading: Radio<Roles>(
                                  value: Roles.citizen,
                                  groupValue: _role,
                                  onChanged: (Roles? value) {
                                    setState(() {
                                      _role = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              child: StreamBuilder<bool>(
                  stream: widget._bloc.validUsernameStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return TextFormField(
                      key: const Key('usernameField'),
                      decoration: InputDecoration(
                        border:
                            const OutlineInputBorder(borderSide: BorderSide()),
                        labelText: 'Brugernavn',
                        errorText: (snapshot.data == true) &&
                                widget._bloc.usernameController.value != null
                            ? null
                            // cant make it shorter because of the string
                            // ignore: lines_longer_than_80_chars
                            : 'Brugernavn er tomt eller indeholder et ugyldigt tegn',
                      ),
                      onChanged: widget._bloc.onUsernameChange.add,
                    );
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Brug piktogram kode?'),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    child: StreamBuilder<Object>(
                        stream: null,
                        builder: (BuildContext context,
                            AsyncSnapshot<Object> snapshot) {
                          return Switch.adaptive(
                              key: const Key('usePictogramSwitch'),
                              value: widget
                                  ._bloc.usePictogramPasswordController.value!,
                              onChanged: _role == Roles.citizen
                                  ? (bool value) {
                                      setState(() {
                                        widget
                                            ._bloc.onUsePictogramPasswordChange
                                            .add(value);
                                      });
                                    }
                                  : null);
                        }))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              child: StreamBuilder<bool>(
                  stream: widget._bloc.validPasswordStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return Visibility(
                      visible:
                          !widget._bloc.usePictogramPasswordController.value!,
                      child: TextFormField(
                        key: const Key('passwordField'),
                        enabled:
                            !widget._bloc.usePictogramPasswordController.value!,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide()),
                          labelText: 'Kodeord',
                          errorText: (snapshot.data == true) &&
                                  widget._bloc.passwordController.value != null
                              ? null
                              // cant make it shorter because of the string
                              // ignore: lines_longer_than_80_chars
                              : 'Kodeord må ikke indeholde mellemrum eller være tom',
                        ),
                        onChanged: widget._bloc.onPasswordChange.add,
                        obscureText: true,
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              child: StreamBuilder<bool>(
                  stream: widget._bloc.validPasswordVerificationStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return Visibility(
                      visible:
                          !widget._bloc.usePictogramPasswordController.value!,
                      child: TextFormField(
                        key: const Key('passwordVerifyField'),
                        enabled:
                            !widget._bloc.usePictogramPasswordController.value!,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide()),
                          labelText: 'Gentag kodeord',
                          errorText: (snapshot.data == true)
                              ? null
                              : 'Kodeord skal være ens',
                        ),
                        onChanged: widget._bloc.onPasswordVerifyChange.add,
                        obscureText: true,
                      ),
                    );
                  }),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              //child: Text('Profil billede af borger (valgfri):'),
              child: AutoSizeText(
                'Profil billede af borger (valgfri):',
                style: TextStyle(fontSize: GirafFont.small),
              ),
            ),

            /// Profile preview picture
            Center(
              child: StreamBuilder<File?>(
                stream: widget._bloc.file,
                builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                  final File? fileData =
                      snapshot.data; // Store the data in a local variable
                  return fileData != null
                      ? widget._displayImage(fileData) // Use the local variable
                      : widget._displayIfNoImage();
                },
              ),
            ),

            Row(
              //mainAxisAlignment:,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),

                  /// Add from gallery button
                  child: GirafButton(
                    key: const Key('TilføjFraGalleriButton'),
                    icon:
                        const ImageIcon(AssetImage('assets/icons/gallery.png')),
                    text: 'Tilføj fra galleri',
                    onPressed: widget._bloc.chooseImageFromGallery,
                    child: StreamBuilder<File?>(
                        stream: widget._bloc.file,
                        builder: (BuildContext context,
                            AsyncSnapshot<File?> snapshot) {
                          final File? fileData = snapshot
                              .data; // Store the data in a local variable
                          return fileData != null
                              ? widget._displayImage(
                                  fileData) // Use the local variable
                              : widget._displayIfNoImage();
                        }),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: GirafButton(
                    key: const Key('saveButton'),
                    icon: const ImageIcon(AssetImage('assets/icons/save.png')),
                    text: 'Gem bruger',
                    isEnabled: false,
                    isEnabledStream: widget._bloc.allInputsAreValidStream,
                    onPressed: () {
                      switch (_role) {
                        case Roles.guardian:
                          widget._bloc
                              .createGuardian()
                              .listen((GirafUserModel? response) {
                            if (response != null) {
                              previousRoute(response);
                            }
                          }).onError((Object error) =>
                                  _translator.catchApiError(error, context));
                          break;
                        case Roles.trustee:
                          widget._bloc
                              .createTrustee()
                              .listen((GirafUserModel? response) {
                            if (response != null) {
                              previousRoute(response);
                            }
                          }).onError((Object error) =>
                                  _translator.catchApiError(error, context));
                          break;
                        case Roles.citizen:
                          widget._bloc
                              .createCitizen()
                              .listen((GirafUserModel? response) {
                            if (response != null) {
                              previousRoute(response);
                            }
                          }).onError((Object error) =>
                                  _translator.catchApiError(error, context));
                          break;
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GirafButton(
                    key: const Key('nextButton'),
                    icon:
                        const ImageIcon(AssetImage('assets/icons/accept.png')),
                    text: 'Videre',
                    isEnabled: false,
                    isEnabledStream: widget._bloc.validUsePictogramStream,
                    onPressed: () {
                      Navigator.push(
                          context,
                          // ignore: always_specify_types
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  NewPictogramPasswordScreen(
                                    widget._bloc.usernameController.value!,
                                    widget._bloc.displayNameController.value!,
                                    widget._bloc.encodePicture(
                                            widget._bloc.fileController.value)
                                        as Uint8List,
                                  )));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
