import 'package:api_client/models/pictogram_model.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/new_weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

/// Screen for creating a new weekplan.
class NewWeekplanScreen extends StatelessWidget {
  /// Screen for creating a new weekplan.
  /// Requires a [UsernameModel] to be able to save the new weekplan.
  NewWeekplanScreen(UsernameModel user)
      : _bloc = di.getDependency<NewWeekplanBloc>() {
    _bloc.initialize(user);
  }

  final NewWeekplanBloc _bloc;

  @override
  Widget build(BuildContext context) {
    const TextStyle _style = TextStyle(fontSize: 20);

    return Scaffold(
        appBar: GirafAppBar(title: 'Ny Ugeplan'),
        body: ListView(children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: StreamBuilder<bool>(
                  stream: _bloc.validTitleStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return TextField(
                      onChanged: _bloc.onTitleChanged.add,
                      style: _style,
                      decoration: InputDecoration(
                          labelText: 'Titel',
                          errorText: (snapshot?.data == false)
                              ? 'Titel skal være mellem 1 og 32 tegn'
                              : null,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide())),
                    );
                  })),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: StreamBuilder<bool>(
                  stream: _bloc.validYearStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return TextField(
                      keyboardType: TextInputType.number,
                      onChanged: _bloc.onYearChanged.add,
                      style: _style,
                      decoration: InputDecoration(
                          labelText: 'År',
                          errorText: (snapshot?.data == false)
                              ? 'År skal angives som fire cifre'
                              : null,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide())),
                    );
                  })),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: StreamBuilder<bool>(
                  stream: _bloc.validWeekNumberStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    return TextField(
                      keyboardType: TextInputType.number,
                      onChanged: _bloc.onWeekNumberChanged.add,
                      style: _style,
                      decoration: InputDecoration(
                          labelText: 'Ugenummer',
                          errorText: (snapshot?.data == false)
                              ? 'Ugenummer skal være mellem 1 og 53'
                              : null,
                          border: const OutlineInputBorder(
                              borderSide: BorderSide())),
                    );
                  })),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Container(
              width: 200,
              height: 200,
              child: StreamBuilder<PictogramModel>(
                stream: _bloc.thumbnailStream,
                builder: _buildThumbnail,
              ),
            ),
          ),
          ButtonTheme(
            minWidth: 130,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    child: RaisedButton(
                      child: Text(
                        'Vælg skabelon',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: null,
                      // Handle when a weekplan is made from a template
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    child: StreamBuilder<bool>(
                      stream: _bloc.allInputsAreValidStream,
                      builder: _buildSaveButton,
                    ),
                  ),
                ]),
          ),
        ]));
  }

  Widget _buildThumbnail(
      BuildContext context, AsyncSnapshot<PictogramModel> snapshot) {
    if (snapshot?.data == null) {
      return GestureDetector(
        onTap: () => _openPictogramSearch(context),
        child: Card(
          child: FittedBox(fit: BoxFit.contain, child: const Icon(Icons.image)),
        ),
      );
    } else {
      return PictogramImage(
          pictogram: snapshot.data,
          onPressed: () => _openPictogramSearch(context));
    }
  }

  Widget _buildSaveButton(BuildContext context, AsyncSnapshot<bool> snapshot) {
    return RaisedButton(
      child: const Text(
        'Gem ugeplan',
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.blue,
      onPressed: (snapshot?.data == true)
          ? () {
              _bloc.saveWeekplan().listen((WeekModel response) {
                if (response != null) {
                  Routes.pop(context, response);
                }
              });
            }
          : null,
    );
  }

  void _openPictogramSearch(BuildContext context) {
    Routes.push<PictogramModel>(context, PictogramSearch())
        .then((PictogramModel pictogram) {
      if (pictogram != null) {
        _bloc.onThumbnailChanged.add(pictogram);
      }
    });
  }
}
