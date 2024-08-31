import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/settings_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_title_header.dart';

import '../style/custom_color.dart' as theme;
import 'giraf_confirm_dialog.dart';

///This is a class
class WeekplannerChoiceboardSelector extends StatelessWidget {
  ///Constructor
  WeekplannerChoiceboardSelector(
      this._activity, this._activityBloc, this._user) {
    _activityBloc.load(_activity, _user);
    _settingsBloc.loadSettings(_user);
  }

  final ActivityModel _activity;

  final DisplayNameModel _user;

  final ActivityBloc _activityBloc;

  /// The settings bloc which we get the settings from, you need to make sure
  /// you have loaded settings into it before hand otherwise text is never build
  final SettingsBloc _settingsBloc = di.get<SettingsBloc>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        key: const Key('ChoiceBoardActivitySelector'),
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          titlePadding: const EdgeInsets.all(0.0),
          shape: Border.all(
              color: theme.GirafColors.transparentDarkGrey, width: 5.0),
          title: Center(
              child: GirafTitleHeader(
            title: 'Vælg aktivitet',
            key: UniqueKey(),
          )),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(10.0),
                  child: displayPictograms(context)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                        child: GirafButton(
                          key: const Key('ChoiceBoardDialogCancelButton'),
                          onPressed: () => Routes().pop(context),
                          icon: const ImageIcon(
                              AssetImage('assets/icons/cancel.png')),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPictogram(PictogramModel pictogram) {
    final PictogramImageBloc bloc = di.get<PictogramImageBloc>();
    bloc.loadPictogramById(pictogram.id);
    return StreamBuilder<Image>(
      stream: bloc.image,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.data == null) {
          return const CircularProgressIndicator();
        }
        return Container(
            child: snapshot.data, key: const Key('PictogramImage'));
      },
    );
  }

  /// This is a function
  Widget displayPictograms(BuildContext context) {
    final List<Widget> pictograms = <Widget>[];
    for (int i = 0; i < _activity.pictograms.length; i++) {
      pictograms.add(_getPictogram(_activity.pictograms[i]));
    }

    final List<Widget> pictogramImages = <Widget>[];

    for (int i = 0; i < pictograms.length; i++) {
      pictogramImages.add(
        _displayPictogram(context, pictograms, i),
      );
    }

    return Container(
      child: Row(
        key: const Key('SelectorPictogram'),
        children: pictogramImages,
      ),
    );
  }

  Widget _displayPictogram(
      BuildContext context, List<Widget> pictograms, int index) {
    return StreamBuilder<SettingsModel?>(
        stream: _settingsBloc.settings,
        builder: (BuildContext context,
            AsyncSnapshot<SettingsModel?> settingSnapshot) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.height * 0.2,
            child: FittedBox(
              child: GestureDetector(
                  onTap: () {
                    if (settingSnapshot.data!.showPopup!) {
                      _selectPictogramFromChoiceBoardPopup(
                              context, pictograms, index)
                          .then((_) {
                        Routes().pop(context);
                      });
                    } else {
                      _selectPictogramFromChoiceboard(context, index);
                    }
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.GirafColors.blueBorderColor,
                            width: 1)),
                    child: pictograms[index],
                  )),
            ),
          );
        });
  }

  //Shows a popup when selecting a pictogram on a choiceboard
  Future<Center?> _selectPictogramFromChoiceBoardPopup(
      BuildContext context, List<Widget> pictograms, int index) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              key: const Key('PictogramSelectorConfirmDialog'),
              title: 'Vælg aktivitet',
              description: 'Vil du vælge aktiviteten ' +
                  _activity.pictograms[index].title,
              confirmButtonText: 'Ja',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/accept.png')),
              confirmOnPressed: () {
                _selectPictogramFromChoiceboard(context, index);
              },
              cancelOnPressed: () {});
        });
  }

  //Changes activity type so it is not a choiceboard, and only keeps the
  //selected pictogram in the activity
  void _selectPictogramFromChoiceboard(BuildContext context, int index) {
    // if (!_activity.pictograms
    //     .any((PictogramModel element) => element.isCompleted == false)) {
    //   _activity.state = ActivityState.Completed;
    // }
    // if (_activity.pictograms.length == 1) {
    //   _activity.isChoiceBoard = false;
    // } else {
    //   _activity.pictograms.removeAt(index);
    // }

    // final List<PictogramModel> _pictogramModels = <PictogramModel>[
    //   _activity.pictograms[index]
    // ];
    // _activity.pictograms = _pictogramModels;
    _activity.chosenActivity = index;
    _activityBloc.load(_activity, _user);
    _activityBloc.completeActivity();

    _activityBloc.update();
    _activityBloc.activityModelStream.skip(1).take(1).listen((_) {
      Routes().pop(context);
    });
    //Closes the dialog box
  }
}
