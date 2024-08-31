import 'package:weekplanner/models/model.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/timer_model.dart';
import 'enums/activity_state_enum.dart';

/// The model for the activity in the api client.
class ActivityModel implements Model {
  /// Constructor for Activity
  ActivityModel(
      {required this.id,
      required this.pictograms,
      required this.order,
      required this.state,
      required this.isChoiceBoard,
      this.choiceBoardName,
      this.timer,
      this.title});

  /// Constructer from json for the offlineDb
  ActivityModel.fromDatabase(Map<String, dynamic>? json,
      {this.timer, this.pictograms = const <PictogramModel>[]}) {
    if (json == null) {
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
    }
    id = json['key'];
    order = json['order'];
    int stateIndex;
    if (json['state'] is int) {
      stateIndex = json['state'];
    } else {
      final String stateString = json['state'];
      stateIndex = int.tryParse(stateString)!;
    }
    state = ActivityState.values[stateIndex];
    isChoiceBoard = json['isChoiceBoard'] == 1;
  }

  /// Constructs the activityModel from json.
  ActivityModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException(
          '[ActivityModel]: Cannot initialize from null');
    }

    id = json['id'];
    pictograms = <PictogramModel>[];
    for (Map<String, dynamic> pictogram in json['pictograms']) {
      pictograms.add(PictogramModel.fromJson(pictogram));
    }
    order = json['order'];
    state = ActivityState.values[(json['state']) - 1];
    isChoiceBoard = json['isChoiceBoard'];
    choiceBoardName = json['choiceBoardName'];
    if (json['timer'] != null) {
      timer = TimerModel.fromJson(json['timer']);
    }
    title = json['title'];
  }

  /// The ID of the activity.
  int id = 0;

  /// The pictogram for the activity.
  // ignore: always_specify_types
  List<PictogramModel> pictograms = List.empty(growable: true);

  /// The order that the activity will appear on in a weekschedule. If two has
  /// same order it is a choice
  int order = 0;

  /// The current ActivityState
  ActivityState state = ActivityState.Normal;

  /// This is used in the WeekPlanner app by the frontend groups and should
  /// never be set from our side
  bool isChoiceBoard = false;

  /// name of the choiceboard
  String? choiceBoardName;

  /// The timer for the activity
  TimerModel? timer;

  ///The title of the activity
  String? title;

  /// The index of the chosen pictogram activity
  int chosenActivity = -1;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'pictograms': pictograms
          .map((PictogramModel pictogram) => pictogram.toJson())
          .toList(),
      'order': order,
      'state': state.index + 1,
      'isChoiceBoard': isChoiceBoard,
      'choiceBoardName': choiceBoardName,
      'timer': timer != null ? timer!.toJson() : null,
      'title': title ?? ''
    };
  }
}
