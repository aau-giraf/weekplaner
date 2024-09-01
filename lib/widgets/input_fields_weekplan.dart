import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weekplanner/blocs/new_weekplan_bloc.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/style/custom_color.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import 'giraf_button_widget.dart';

/// The widget itself for the input fields
class InputFieldsWeekPlan extends StatefulWidget {
  /// Class created for keeping the input fields for the new and
  /// edit week plan screen consisten-t
  const InputFieldsWeekPlan(
      {required this.bloc, required this.button, required this.weekModel});

  /// This is the bloc used to control the input fields
  final NewWeekplanBloc bloc;

  /// This is where you would input the button that should be added after the
  /// input fields
  final GirafButton button;

  /// This is the information from the current weekModel object
  final WeekModel weekModel;

  @override
  InputFieldsWeekPlanState createState() => InputFieldsWeekPlanState();
}

/// The state for the input fields
class InputFieldsWeekPlanState extends State<InputFieldsWeekPlan> {
  final TextStyle _style = const TextStyle(fontSize: GirafFont.small);

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      _titleInputField(),
      _yearInputField(),
      _weekNumberInputField(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          //Stack(
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: _pictogramInputField(),
              )),
          Align(
              alignment: Alignment.center,
              child: Container(
                height: 100,
                child: widget.button,
              ))
        ],
      )
    ]);
  }

  Widget _titleInputField() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: StreamBuilder<bool>(
            stream: widget.bloc.validTitleStream,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return TextFormField(
                key: const Key('WeekTitleTextFieldKey'),
                onChanged: widget.bloc.onTitleChanged.add,
                initialValue: widget.weekModel.name,
                keyboardType: TextInputType.text,
                // To avoid emojis and other special characters
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp('[ -~\u00C0-\u00FF]'))
                ],
                style: _style,
                decoration: InputDecoration(
                    labelText: 'Titel',
                    errorText:
                        (snapshot.data == true) ? null : 'Titel skal angives',
                    border: const OutlineInputBorder(borderSide: BorderSide())),
              );
            }));
  }

  Widget _yearInputField() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: StreamBuilder<bool>(
            stream: widget.bloc.validYearStream,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return TextFormField(
                key: const Key('WeekYearTextFieldKey'),
                keyboardType: TextInputType.number,
                onChanged: widget.bloc.onYearChanged.add,
                initialValue: widget.weekModel.weekYear.toString(),
                style: _style,
                decoration: InputDecoration(
                    labelText: 'År',
                    errorText: (snapshot.data == true)
                        ? null
                        : 'År skal angives som fire cifre',
                    border: const OutlineInputBorder(borderSide: BorderSide())),
              );
            }));
  }

  Widget _weekNumberInputField() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: StreamBuilder<bool>(
            stream: widget.bloc.validWeekNumberStream,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return TextFormField(
                key: const Key('WeekNumberTextFieldKey'),
                keyboardType: TextInputType.number,
                onChanged: widget.bloc.onWeekNumberChanged.add,
                initialValue: widget.weekModel.weekNumber.toString(),
                style: _style,
                decoration: InputDecoration(
                    labelText: 'Ugenummer',
                    errorText: (snapshot.data == true)
                        ? null
                        : 'Ugenummer skal være mellem 1 og 53',
                    border: const OutlineInputBorder(borderSide: BorderSide())),
              );
            }));
  }

  Widget _pictogramInputField() {
    return Container(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          key: const Key('WeekThumbnailKey'),
          width: MediaQuery.of(context).size.width / 2,
          height: 200,
          child: StreamBuilder<PictogramModel?>(
            stream: widget.bloc.thumbnailStream,
            builder: _buildThumbnail,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
      BuildContext context, AsyncSnapshot<PictogramModel?> snapshot) {
    if (snapshot.data == null) {
      return GestureDetector(
        onTap: () => _openPictogramSearch(context, widget.bloc),
        child: Card(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text('Vælg billede til ugeplan',
                    style: _style.apply(color: GirafColors.errorColor)),
              ),
              Expanded(child: Image.asset('assets/icons/galleryBig.png')),
            ],
          ),
        ),
      );
    } else {
      return PictogramImage(
          pictogram: snapshot.data!,
          onPressed: () => _openPictogramSearch(context, widget.bloc),
          haveRights: false,
          key: UniqueKey());
    }
  }

  void _openPictogramSearch(BuildContext context, NewWeekplanBloc bloc) {
    Routes()
        .push<PictogramModel>(
            context,
            const PictogramSearch(
              user: null,
            ))
        .then((PictogramModel? pictogram) {
      if (pictogram != null) {
        bloc.onThumbnailChanged.add(pictogram);
      }
    });
  }
}
