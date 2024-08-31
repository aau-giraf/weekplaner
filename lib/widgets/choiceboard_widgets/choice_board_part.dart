import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/activity_bloc.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';

import '../../di.dart';
import 'delete_pictogram_from_choice_board_button.dart';

/// Class that defines a pictogram and a button to delete it
class ChoiceBoardPart extends StatelessWidget {
  /// Constructor for ChoiceBoard-part widget.
  ChoiceBoardPart(
      this._pictogramModel, this._bloc, this._activity, this._user) {
    _pictogramImageBloc.load(_pictogramModel);
  }

  final PictogramImageBloc _pictogramImageBloc = di.get<PictogramImageBloc>();

  final PictogramModel _pictogramModel;

  final DisplayNameModel _user;

  final ActivityModel _activity;

  final ActivityBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Image>(
      key: const Key('ChoiceBoardPart'),
      stream: _pictogramImageBloc.image,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              SizedBox.expand(
                child: FittedBox(
                  child: snapshot.data,
                  // Key is used for testing the widget.
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: DeletePictogramFromChoiceBoardButton(() {
                  _bloc.load(_activity, _user);
                  _activity.pictograms.remove(_pictogramModel);
                  if (_activity.pictograms.length == 1) {
                    _activity.isChoiceBoard = false;
                    _bloc.getTitleWhenChoiceboardDeleted();
                  }
                  _bloc.update();
                }),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}
