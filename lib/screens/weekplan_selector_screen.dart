// ignore_for_file: lines_longer_than_80_chars

import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/weekplan_selector_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/copy_resolve_screen.dart';
import 'package:weekplanner/screens/copy_to_citizens_screen.dart';
import 'package:weekplanner/screens/edit_weekplan_screen.dart';
import 'package:weekplanner/screens/new_weekplan_screen.dart';
import 'package:weekplanner/screens/settings_screens/settings_screen.dart';
import 'package:weekplanner/screens/weekplan_screen.dart';
import 'package:weekplanner/style/font_size.dart';
import 'package:weekplanner/widgets/bottom_app_bar_button_widget.dart';
import 'package:weekplanner/widgets/giraf_3button_dialog.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

import '../style/custom_color.dart' as theme;

/// Screen to select a weekplan for a given user
class WeekplanSelectorScreen extends StatefulWidget {
  /// Constructor for weekplan selector screen.
  /// Requires a user to load weekplans
  WeekplanSelectorScreen(this._user) : _weekBloc = di.get<WeekplansBloc>() {
    _weekBloc.load(_user, true);
  }

  final WeekplansBloc _weekBloc;
  final DisplayNameModel _user;

  @override
  _WeekplanSelectorScreenState createState() => _WeekplanSelectorScreenState();
}

class _WeekplanSelectorScreenState extends State<WeekplanSelectorScreen> {
  bool showOldWeeks = false;

  void _toggleOldWeeks() {
    setState(
      () {
        showOldWeeks = !showOldWeeks;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GirafAppBar(
          key: const ValueKey<String>('weekplanSelectorKey'),
          title: widget._user.displayName ?? 'No Name',
          appBarIcons: <AppBarIcon, VoidCallback>{
            AppBarIcon.edit: () => widget._weekBloc.toggleEditMode(),
            AppBarIcon.logout: () {},
            AppBarIcon.settings: () =>
                Routes().push(context, SettingsScreen(widget._user))
          },
        ),
        bottomNavigationBar: StreamBuilder<bool>(
          stream: widget._weekBloc.editMode,
          initialData: false,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data!) {
              return _buildBottomAppBar(context);
            } else {
              return Container(width: 0.0, height: 0.0);
            }
          },
        ),
        body: _buildWeekplanColumnview(context));
  }

  // Entire screen
  Widget _buildWeekplanColumnview(BuildContext context) {
    final Stream<List<WeekModel>> weekModels = widget._weekBloc.weekModels;
    final Stream<List<WeekModel>> oldWeekModels =
        widget._weekBloc.oldWeekModels;
    // Container which holds all of the UI elements on the screen
    return Container(
        child: Column(children: <Widget>[
      Expanded(
          flex: 5, child: _buildWeekplanGridview(context, weekModels, true)),
      // Overstået Uger bar
      InkWell(
        child: Container(
          color: Colors.grey,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(10.0, 3, 0, 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const AutoSizeText(
                'Overståede uger',
                style: TextStyle(fontSize: GirafFont.small),
                maxLines: 1,
                minFontSize: 14,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              showOldWeeks
                  // Icons for showing and hiding the old weeks are inside this
                  // When the old weeks are shown, show the hide icon
                  ? Expanded(
                      flex: 1,
                      child: IconButton(
                        key: const Key('HideOldWeeks'),
                        padding: const EdgeInsets.all(0.0),
                        alignment: Alignment.centerRight,
                        color: Colors.black,
                        icon: const Icon(Icons.remove, size: 50),
                        onPressed: () {
                          _toggleOldWeeks();
                        },
                      ),
                    )
                  // Icons for showing and hiding the old weeks are inside this
                  // When the old weeks are hidden, show the hide icon
                  : Expanded(
                      flex: 1,
                      child: IconButton(
                        key: const Key('ShowOldWeeks'),
                        padding: const EdgeInsets.all(0.0),
                        alignment: Alignment.centerRight,
                        color: Colors.black,
                        icon: const Icon(Icons.add, size: 50),
                        onPressed: () {
                          _toggleOldWeeks();
                        },
                      ),
                    ),
            ],
          ),
        ),
        onTap: () {
          _toggleOldWeeks();
        },
      ),

      Visibility(
          visible: showOldWeeks,
          child: Expanded(
              flex: 5,
              child: Container(
                  // Container with old weeks if shown
                  // Background color of the old weeks
                  color: Colors.grey.shade600,
                  child:
                      _buildWeekplanGridview(context, oldWeekModels, false))))
    ]));
  }

  Widget _buildWeekplanGridview(BuildContext context,
      Stream<List<WeekModel>> weekModels, bool isUpcomingWeekplan) {
    List<WeekModel> initial = <WeekModel>[WeekModel(name: 'Tilføj ugeplan')];
    if (!isUpcomingWeekplan) {
      initial = <WeekModel>[];
    }
    return StreamBuilder<List<WeekModel>>(
        initialData: initial,
        stream: weekModels,
        builder: (BuildContext context,
            AsyncSnapshot<List<WeekModel>> weekplansSnapshot) {
          return StreamBuilder<List<WeekModel>>(
              stream: widget._weekBloc.markedWeekModels,
              builder: (BuildContext context,
                  AsyncSnapshot<List<WeekModel>> markedWeeksSnapshot) {
                return GridView.count(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    crossAxisCount: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 4
                        : 3,
                    crossAxisSpacing:
                        MediaQuery.of(context).size.width / 100 * 1.5,
                    mainAxisSpacing:
                        MediaQuery.of(context).size.width / 100 * 1.5,
                    children: weekplansSnapshot.data!.map((WeekModel weekplan) {
                      return _buildWeekPlanSelector(
                          context,
                          weekplan,
                          markedWeeksSnapshot.hasData &&
                              markedWeeksSnapshot.data!.contains(weekplan),
                          isUpcomingWeekplan);
                    }).toList());
              });
        });
  }

  Widget _buildWeekPlanSelector(
      BuildContext context, WeekModel weekplan, bool isMarked, bool current) {
    final PictogramImageBloc bloc = di.get<PictogramImageBloc>();

    if (weekplan.thumbnail != null) {
      bloc.loadPictogramById(weekplan.thumbnail!.id);
    }

    if (isMarked) {
      return Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.GirafColors.black, width: 15),
          ),
          child: _buildWeekplanCard(
            context,
            weekplan,
            bloc,
            current,
          ));
    } else {
      return _buildWeekplanCard(
        context,
        weekplan,
        bloc,
        current,
      );
    }
  }

  Widget _buildWeekplanCard(BuildContext context, WeekModel weekplan,
      PictogramImageBloc bloc, bool current) {
    return StreamBuilder<bool>(
        stream: widget._weekBloc.editMode,
        builder:
            (BuildContext context, AsyncSnapshot<bool> inEditModeSnapshot) {
          return GestureDetector(
              key: Key(weekplan.name!),
              onTap: () =>
                  handleOnTap(context, weekplan, inEditModeSnapshot.data!),
              child: ColorFiltered(
                // Color of each of the Overstået Uger cards
                colorFilter: ColorFilter.mode(Colors.grey.shade400,
                    current ? BlendMode.dst : BlendMode.modulate),
                child: Card(
                    child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraint) {
                        if (weekplan.thumbnail != null) {
                          return _getPictogram(weekplan, bloc);
                        } else {
                          return Icon(
                            Icons.add,
                            size: constraint.maxHeight,
                          );
                        }
                      }),
                    ),
                    Expanded(child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return AutoSizeText(
                        weekplan.name!,
                        style: const TextStyle(fontSize: GirafFont.small),
                        maxLines: 1,
                        minFontSize: 14,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      );
                    })),
                    Container(
                      child: Expanded(child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return AutoSizeText(
                          'Uge: ${weekplan.weekNumber}      '
                          'År: ${weekplan.weekYear}',
                          key: const Key('weekYear'),
                          style: const TextStyle(fontSize: GirafFont.small),
                          maxLines: 1,
                          minFontSize: 14,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        );
                      })),
                    )
                  ],
                )),
              ));
        });
  }

  /// Handles on tap on a weekplan card
  void handleOnTap(BuildContext context, WeekModel weekplan, bool inEditMode) {
    if (weekplan.thumbnail != null) {
      handleOnTapWeekPlan(inEditMode, weekplan, context);
    } else {
      handleOnTapWeekPlanAdd(context);
    }
  }

  /// Handles on tap on a add new weekplan card
  void handleOnTapWeekPlanAdd(BuildContext context) {
    Routes()
        .push<WeekModel>(
          context,
          NewWeekplanScreen(
            user: widget._user,
            existingWeekPlans: widget._weekBloc.weekNameModels,
          ),
        )
        .then((WeekModel? newWeekPlan) =>
            widget._weekBloc.load(widget._user, true));
  }

  /// Handles on tap on a weekplan card
  void handleOnTapWeekPlan(
      bool inEditMode, WeekModel weekplan, BuildContext context) {
    if (inEditMode) {
      widget._weekBloc.toggleMarkedWeekModel(weekplan);
    } else {
      Routes()
          .push(
              context,
              WeekplanScreen(
                weekplan,
                widget._user,
                key: UniqueKey(),
              ))
          .then((_) => widget._weekBloc.load(widget._user, true));
    }
  }

  Widget _getPictogram(WeekModel weekplan, PictogramImageBloc bloc) {
    return StreamBuilder<Image>(
      stream: bloc.image,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.data == null) {
          return const FittedBox(child: CircularProgressIndicator());
        }
        return Container(
            child: snapshot.data, key: const Key('PictogramImage'));
      },
    );
  }

  /// Builds the BottomAppBar when in edit mode
  BottomAppBar _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
        child: Row(
      mainAxisSize: MainAxisSize.min,
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
                  GirafButton(
                      key: const Key('EditButtonKey'),
                      text: 'Redigér',
                      icon:
                          const ImageIcon(AssetImage('assets/icons/edit.png')),
                      onPressed: () async => _pushEditWeekPlan(context)),
                  BottomAppBarButton(
                      key: const Key('copyButtonKey'),
                      buttonText: 'Kopiér',
                      buttonKey: 'CopyWeekplanButton',
                      assetPath: 'assets/icons/copy.png',
                      dialogFunction: _buildCopyDialog),
                  BottomAppBarButton(
                      key: const Key('deleteButtonKey'),
                      buttonText: 'Slet',
                      buttonKey: 'DeleteActivtiesButton',
                      assetPath: 'assets/icons/delete.png',
                      dialogFunction: _buildDeletionDialog),
                ],
              )),
        ),
      ],
    ));
  }

  Future<void> _pushEditWeekPlan(BuildContext context) async {
    final int markedCount = widget._weekBloc.getNumberOfMarkedWeekModels();
    bool reload = false;
    widget._weekBloc.oldWeekModels.listen((List<WeekModel> list) {
      reload = list.length < 2;
    });
    widget._weekBloc.weekModels.listen((List<WeekModel> list) {
      reload |= list.length < 3;
    });
    if (markedCount > 1) {
      const String description = 'Der kan kun redigeres en ugeplan af gangen';
      showDialog<Center>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return GirafNotifyDialog(
              title: 'Fejl',
              description: description,
              key: UniqueKey(),
            );
          });
      return;
    }
    if (markedCount < 1) {
      return;
    }
    await Routes()
        .push<WeekModel>(
      context,
      EditWeekPlanScreen(
        user: widget._user,
        weekModel: widget._weekBloc.getMarkedWeekModels()[0],
        selectorBloc: widget._weekBloc,
      ),
    )
        .then((WeekModel? newWeek) {
      widget._weekBloc.load(widget._user, true);
      widget._weekBloc.toggleEditMode();
      widget._weekBloc.clearMarkedWeekModels();
      if (reload) {
        Routes().pop<bool>(context, true);
      }
    });
  }

  ///Builds dialog box to select where to copy weekplan or cancel
  Future<Center?> _buildCopyDialog(BuildContext context) async {
    if (widget._weekBloc.getNumberOfMarkedWeekModels() < 1) {
      return null;
    } else if (widget._weekBloc.getNumberOfMarkedWeekModels() != 1) {
      final List<WeekModel> weekModelList =
          await widget._weekBloc.getMarkedWeeks();
      return showDialog<Center>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return GirafConfirmDialog(
                title: 'Kopiér ugeplaner',
                description: 'Hvor vil du kopiére de valgte ugeplaner hen?',
                confirmButtonText: 'Andre borgere',
                confirmButtonIcon:
                    const ImageIcon(AssetImage('assets/icons/copy.png')),
                confirmOnPressed: () {
                  Routes().push(context,
                      CopyToCitizensScreen(weekModelList, widget._user));
                },
                key: UniqueKey());
          });
    } else {
      final List<WeekModel> weekModelList =
          await widget._weekBloc.getMarkedWeeks();
      return showDialog<Center>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return Giraf3ButtonDialog(
              title: 'Kopiér ugeplaner',
              description: 'Hvor vil du kopiére den valgte ugeplan hen? ',
              option1Text: 'Andre borgere',
              option1OnPressed: () {
                Routes().push(
                    context, CopyToCitizensScreen(weekModelList, widget._user));
              },
              option1Icon: const ImageIcon(AssetImage('assets/icons/copy.png')),
              option2Text: 'Denne borger',
              option2OnPressed: () {
                widget._weekBloc
                    .getMarkedWeekModel()
                    .then((WeekModel weekmodel) {
                  Routes().push(
                      context,
                      CopyResolveScreen(
                        currentUser: widget._user,
                        weekModel: weekmodel,
                        forThisCitizen: true,
                      ));
                });
              },
              option2Icon: const ImageIcon(AssetImage('assets/icons/copy.png')),
              key: UniqueKey(),
            );
          });
    }
  }

  /// Builds dialog box to confirm/cancel deletion
  Future<Center?> _buildDeletionDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Slet ugeplaner',
              description: 'Vil du slette ' +
                  widget._weekBloc.getNumberOfMarkedWeekModels().toString() +
                  '${widget._weekBloc.getNumberOfMarkedWeekModels() == 1 ? ' ugeplan' : ' ugeplaner'}?',
              confirmButtonText: 'Slet',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/delete.png')),
              confirmOnPressed: () {
                widget._weekBloc.deleteMarkedWeekModels();
                widget._weekBloc.toggleEditMode();

                // Closes the dialog box
                Routes().pop(context);
              },
              key: UniqueKey());
        });
  }
}
