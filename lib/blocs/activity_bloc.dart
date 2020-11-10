
import 'package:api_client/models/displayname_model.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:api_client/api/api.dart';
import 'package:api_client/models/enums/activity_state_enum.dart';
import 'package:api_client/models/alternate_name_model.dart';

/// Logic for activities
class ActivityBloc extends BlocBase {
  /// Default Constructor.
  /// Initializes values
  ActivityBloc(this._api);

  /// Stream for updated ActivityModel.
  Stream<ActivityModel> get activityModelStream => _activityModelStream.stream;

  /// rx_dart.BehaviorSubject for the updated ActivityModel.
  final rx_dart.BehaviorSubject<ActivityModel> _activityModelStream =
      rx_dart.BehaviorSubject<ActivityModel>();

  final Api _api;
  ActivityModel _activityModel;
  DisplayNameModel _user;
  AlternateNameModel _alternateName;

  /// Loads the ActivityModel and the GirafUser.
  void load(ActivityModel activityModel, DisplayNameModel user) {
    _activityModel = activityModel;
    _user = user;
    _activityModelStream.add(activityModel);
  }
  /// Return the current ActivityModel
  ActivityModel getActivity(){
    return _activityModel;
  }

  /// Mark the selected activity as complete. Toggle function, if activity is
  /// Completed, it will become Normal
  void completeActivity() {
    _activityModel.state = _activityModel.state == ActivityState.Completed
        ? ActivityState.Normal
        : ActivityState.Completed;
    update();
  }

  /// Mark the selected activity as cancelled.Toggle function, if activity is
  /// Canceled, it will become Normal
  void cancelActivity() {
    _activityModel.state = _activityModel.state == ActivityState.Canceled
        ? ActivityState.Normal
        : ActivityState.Canceled;
    update();
  }

  /// Update the Activity with the new state.
  void update() {
    _api.activity
        .update(_activityModel, _user.id)
        .listen((ActivityModel activityModel) {
      _activityModel = activityModel;
      _activityModelStream.add(activityModel);
    });
  }

  /// Set a new alternate Name
  void setAlternateName(String name){
    _alternateName = AlternateNameModel(name: name, citizen: _user.id,
        pictogram: _activityModel.pictograms.first.id);
    _api.alternateName.create(_alternateName
        ).listen((AlternateNameModel an) {
          if(an != null){
           print('aha');
          }
          else{
            print('hmm');
          }
    });
  }

  String getAlternateName(){
    String name;
    _api.alternateName.get(_user.id, _activityModel.pictograms.first.id)
        .listen((AlternateNameModel an) {
          name = an.name; });

    return name;
  }

  @override
  void dispose() {
    _activityModelStream.close();
  }
}
