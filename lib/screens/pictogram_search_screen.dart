import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/pictogram_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/upload_image_from_phone_screen.dart';
import 'package:weekplanner/widgets/bottom_app_bar_button_widget.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/pictogram_image.dart';

import '../style/custom_color.dart' as theme;

/// Screen for searching for pictograms
///
/// This screen will return `null` back is pressed, otherwise it will return the
/// chosen pictogram.
class PictogramSearch extends StatefulWidget {
  /// Constructor
  const PictogramSearch({required this.user});

  /// The current authenticated user
  final DisplayNameModel? user;

  @override
  _PictogramSearchState createState() => _PictogramSearchState();
}

class _PictogramSearchState extends State<PictogramSearch> {
  final PictogramBloc _bloc = di.get<PictogramBloc>();

  //Search after pictograms when the page loads
  @override
  void initState() {
    super.initState();
    _bloc.search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
          title: 'Piktogram',
          key: UniqueKey(),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: _bloc.search,
                      decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.search),
                          hintText: 'Søg her...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50))),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<PictogramModel>?>(
                    stream: _bloc.pictograms,
                    initialData: const <PictogramModel>[],
                    builder: (BuildContext context,
                        AsyncSnapshot<List<PictogramModel>?> snapshot) {
                      if (snapshot.hasData) {
                        return Column(children: <Widget>[
                          Expanded(
                              child: GridView.count(
                                  crossAxisCount: 4,
                                  children: snapshot.data!
                                      .map((PictogramModel pictogram) =>
                                          PictogramImage(
                                            pictogram: pictogram,
                                            haveRights: widget.user == null ||
                                                    pictogram.userId == null
                                                ? false
                                                : pictogram.userId ==
                                                    widget.user!.id,
                                            needsTitle: true,
                                            onPressed: () => Routes()
                                                .pop(context, pictogram),
                                            key: UniqueKey(),
                                          ))
                                      .toList(),
                                  controller: _bloc.sc)),
                          _bloc.loadingPictograms == true
                              ? Container(
                                  height: 80,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                )
                              : Container()
                        ]);
                      } else if (snapshot.hasError) {
                        return InkWell(
                          key: const Key('timeoutWidget'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(snapshot.error.toString()),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: <double>[
                            1 / 3,
                            2 / 3
                          ],
                              colors: <Color>[
                            theme.GirafColors.appBarYellow,
                            theme.GirafColors.appBarOrange,
                          ])),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            BottomAppBarButton(
                              buttonText: 'Tilføj fra galleri',
                              buttonKey: 'TilføjFraGalleriButton',
                              assetPath: 'assets/icons/gallery.png',
                              dialogFunction: (BuildContext context) {
                                Routes().push(
                                    context,
                                    UploadImageFromPhone(
                                      key: const Key('uploadFromPhone'),
                                    ));
                              },
                              key: const Key('addFromGallery'),
                            ),
                          ])))
            ])));
  }
}
