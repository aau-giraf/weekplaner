import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/api/errorcode_translator.dart';
import 'package:weekplanner/blocs/new_pictogram_password_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/giraf_user_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/style/custom_color.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/pictogram_password_widgets/pictogram_password_widget.dart';

/// Screen for the creation of a pictogram password
class NewPictogramPasswordScreen extends StatelessWidget {
  /// Constructor for the new pictogram password screen
  NewPictogramPasswordScreen(
      String userName, String displayName, Uint8List profilePicture)
      : _bloc = di.get<NewPictogramPasswordBloc>() {
    _bloc.initialize(userName, displayName, profilePicture);
  }

  final NewPictogramPasswordBloc _bloc;

  final ApiErrorTranslator _translator = ApiErrorTranslator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
          title: 'Ny bruger',
          key: UniqueKey(),
        ),
        body: ListView(shrinkWrap: false, children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: StreamBuilder<bool>(
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return Text('Opret piktogram kode til ${_bloc.displayName}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: GirafColors.grey,
                        fontSize: 28,
                        fontWeight: FontWeight.bold));
              },
              stream: null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PictogramPassword(
                onPasswordChanged: (String pass) {
                  _bloc.onPictogramPasswordChanged.add(pass);
                },
                api: di.get<Api>(),
                key: UniqueKey(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: StreamBuilder<bool>(
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return GirafButton(
                  key: const Key('saveButton'),
                  icon: const ImageIcon(AssetImage('assets/icons/save.png')),
                  text: 'Gem bruger',
                  isEnabled: false,
                  isEnabledStream: _bloc.validPictogramPasswordStream,
                  onPressed: () {
                    _bloc.createCitizen().listen((GirafUserModel? response) {
                      if (response != null) {
                        // Pop twice, because this screen is on top
                        // of the NewCitizenScreen.
                        Routes().pop(context, response);
                        Routes().pop(context, response);

                        // Maybe not needed, as the
                        // initialize method already resets
                        //_bloc.reset();
                      }
                    }).onError((Object error) =>
                        _translator.catchApiError(error, context));
                  },
                );
              },
              stream: null,
            ),
          ),
        ]));
  }
}
