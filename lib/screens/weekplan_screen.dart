import 'package:flutter/material.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/enums/weekday_enum.dart';
import 'package:api_client/models/username_model.dart';
import 'package:api_client/models/week_model.dart';
import 'package:weekplanner/blocs/pictogram_image_bloc.dart';
import 'package:weekplanner/blocs/weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/user_week_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/screens/show_activity_screen.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/screens/pictogram_search_screen.dart';
import 'package:api_client/models/pictogram_model.dart';

/// Color of the add buttons
const Color buttonColor = Color(0xA0FFFFFF);

/// <summary>
/// The WeekplanScreen is used to display a week
/// and all the activities that occur in it.
/// </summary>
class WeekplanScreen extends StatelessWidget {
  /// <summary>
  /// WeekplanScreen constructor
  /// </summary>
  /// <param name="key">Key of the widget</param>
  /// <param name="week">Week that should be shown on the weekplan</param>
  /// <param name="user">owner of the weekplan</param>
  WeekplanScreen(this._week, this._user, {Key key}) : super(key: key) {
    weekplanBloc.setWeek(_week, _user);
  }

  /// The WeekplanBloc that contains the current chosen weekplan
  final WeekplanBloc weekplanBloc = di.getDependency<WeekplanBloc>();
  final UsernameModel _user;
  final WeekModel _week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GirafAppBar(
        title: 'Ugeplan',
        appBarIcons: <AppBarIcon, VoidCallback>{
          AppBarIcon.edit: () => weekplanBloc.toggleEditMode(),
          AppBarIcon.settings: null,
          AppBarIcon.logout: null
        },
      ),
      body: StreamBuilder<UserWeekModel>(
        stream: weekplanBloc.userWeek,
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<UserWeekModel> snapshot) {
          if (snapshot.hasData) {
            return _buildWeeks(snapshot.data.week, context);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: StreamBuilder<bool>(
        stream: weekplanBloc.editMode,
        initialData: false,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data) {
            return buildBottomAppBar(context);
          } else {
            return Container(width: 0.0, height: 0.0);
          }
        },
      ),
    );
  }

  /// Builds the BottomAppBar when in edit mode
  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
        color: const Color(0xAAFF6600),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              key: const Key('DeleteActivtiesButton'),
              iconSize: 50,
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                /// Shows dialog to confirm/cancel deletion
                buildShowDialog(context);
              },
            ),
          ],
        ));
  }

  /// Builds dialog box to confirm/cancel deletion
  Future<Center> buildShowDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
              title: 'Bekræft',
              description: 'Vil du slette ' +
                  weekplanBloc.getNumberOfMarkedActivities().toString() +
                  ' aktivitet(er)',
              confirmButtonText: 'Bekræft',
              confirmButtonIcon:
                  const ImageIcon(AssetImage('assets/icons/accept.png')),
              confirmOnPressed: () {
                weekplanBloc.deleteMarkedActivities();
                weekplanBloc.toggleEditMode();

                /// Closes the dialog box
                Routes.pop(context);
              });
        });
  }

  Row _buildWeeks(WeekModel weekModel, BuildContext context) {
    const List<int> weekColors = <int>[
      0xFF08A045,
      0xFF540D6E,
      0xFFF77F00,
      0xFF004777,
      0xFFF9C80E,
      0xFFDB2B39,
      0xFFFFFFFF
    ];
    final List<Widget> weekDays = <Widget>[];
    for (int i = 0; i < weekModel.days.length; i++) {
      weekDays.add(Expanded(
          child: Card(
              color: Color(weekColors[i]),
              child: _day(weekModel.days[i].day, weekModel.days[i].activities,
                  context))));
    }
    return Row(children: weekDays);
  }

  Column _day(
      Weekday day, List<ActivityModel> activities, BuildContext context) {
    return Column(
      children: <Widget>[
        _translateWeekDay(day),
        buildDayActivities(activities, day),
        Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ButtonTheme(
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                  key: const Key('AddActivityButton'),
                  child: Image.asset('assets/icons/add.png'),
                  color: buttonColor,
                  onPressed: () async {
                    final PictogramModel newActivity =
                        await Routes.push(context, PictogramSearch());
                    if (newActivity != null) {
                      weekplanBloc.addActivity(
                          ActivityModel(
                              id: newActivity.id,
                              pictogram: newActivity,
                              order: activities.length,
                              state: ActivityState.Active,
                              isChoiceBoard: false),
                          day.index);
                    }
                  }),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a day's activities
  StreamBuilder<List<ActivityModel>> buildDayActivities(
      List<ActivityModel> activities, Weekday day) {
    return StreamBuilder<List<ActivityModel>>(
        stream: weekplanBloc.markedActivities,
        builder: (BuildContext context,
            AsyncSnapshot<List<ActivityModel>> markedActivities) {
          return StreamBuilder<bool>(
              initialData: false,
              stream: weekplanBloc.editMode,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      final bool isMarked =
                          weekplanBloc.isActivityMarked(activities[index]);
                      return GestureDetector(
                        key: Key(day.index.toString() +
                            activities[index].id.toString()),
                        onTap: () {
                          handleOnTapActivity(
                              snapshot, isMarked, activities, index, context);
                        },
                        child:
                            buildIsMarked(isMarked, context, activities, index),
                      );
                    },
                    itemCount: activities.length,
                  ),
                );
              });
        });
  }

  /// Handles tap on a activity
  void handleOnTapActivity(AsyncSnapshot<bool> snapshot, bool isMarked,
      List<ActivityModel> activities, int index, BuildContext context) {
    if (snapshot.data) {
      if (isMarked) {
        weekplanBloc.removeMarkedActivity(activities[index]);
      } else {
        weekplanBloc.addMarkedActivity(activities[index]);
      }
    } else {
      Routes.push(context, ShowActivityScreen(_week, activities[index], _user));
    }
  }

  /// Builds activity card with a complete if is marked
  StatelessWidget buildIsMarked(bool isMarked, BuildContext context,
      List<ActivityModel> activities, int index) {
    if (isMarked) {
      return Container(
          key: const Key('isSelectedKey'),
          margin: const EdgeInsets.all(1),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 10)),
          child: buildActivityCard(
            context,
            activities,
            index,
            activities[index].state,
          ));
    } else {
      return buildActivityCard(
          context, activities, index, activities[index].state);
    }
  }

  Widget _getPictogram(ActivityModel activity) {
    final PictogramImageBloc bloc = di.getDependency<PictogramImageBloc>();
    bloc.loadPictogramById(activity.pictogram.id);
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

  /// Builds card that displays the activity
  Card buildActivityCard(
    BuildContext context,
    List<ActivityModel> activities,
    int index,
    ActivityState activityState,
  ) {
    Widget icon = Container();
    if (activityState == ActivityState.Completed) {
      icon = Icon(
        Icons.check,
        key: const Key('IconComplete'),
        color: Colors.green,
        size: MediaQuery.of(context).size.width,
      );
    }

    return Card(
        child: FittedBox(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: FittedBox(
              child: _getPictogram(activities[index]),
            ),
          ),
          icon
        ],
      ),
    ));
  }

  Card _translateWeekDay(Weekday day) {
    String translation;
    switch (day) {
      case Weekday.Monday:
        translation = 'Mandag';
        break;
      case Weekday.Tuesday:
        translation = 'Tirsdag';
        break;
      case Weekday.Wednesday:
        translation = 'Onsdag';
        break;
      case Weekday.Thursday:
        translation = 'Torsdag';
        break;
      case Weekday.Friday:
        translation = 'Fredag';
        break;
      case Weekday.Saturday:
        translation = 'Lørdag';
        break;
      case Weekday.Sunday:
        translation = 'Søndag';
        break;
      default:
        translation = '';
        break;
    }

    return Card(
        key: Key(translation),
        color: buttonColor,
        child: ListTile(
            title: Text(
          translation,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )));
  }
}
