import 'dart:async';
import 'package:api_client/models/timer_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:api_client/models/activity_model.dart';
import 'package:countdown/countdown.dart';

/// Logic for activities
class TimerBloc extends BlocBase {
  ActivityModel _activityModel;

  /// Stream for the progress of the timer.
  Stream<double> get timerProgressStream => _timerProgressStream.stream;

  /// BehaivorSubject for the updated weekmodel.
  final BehaviorSubject<double> _timerProgressStream =
  BehaviorSubject<double>.seeded(0.0);

  /// stream for checking if the timer is running
  Stream<bool> get timerIsRunning => _timerRunningStream.stream;

  /// BehaivorSubject for to check if timer is running.
  final BehaviorSubject<bool> _timerRunningStream =
  BehaviorSubject<bool>.seeded(false);

  CountDown _countDown;
  StreamSubscription<Duration> _timerStream;


  void load(ActivityModel activity) {
    _activityModel = activity;
  }

  void initTimer() {
    _activityModel.timer = TimerModel(
        startTime: DateTime.now(), progress: 3, fullLength: 10, paused: true);

    final DateTime endTime = _activityModel.timer.startTime.add(Duration(
        seconds:
        _activityModel.timer.fullLength - _activityModel.timer.progress));
    if (_activityModel.timer != null) {
      if (_activityModel.timer.startTime.isBefore(DateTime.now()) &&
          DateTime.now().isBefore(endTime) &&
          !_activityModel.timer.paused) {
        _startCounter(endTime, _activityModel.timer.paused);
      } else if (_activityModel.timer.paused) {
        _timerProgressStream.add(1 -
            (1 /
                _activityModel.timer.fullLength *
                (_activityModel.timer.fullLength -
                    _activityModel.timer.progress)));
        _startCounter(endTime, _activityModel.timer.paused);
      }
    }
  }

  void _startCounter(DateTime endTime, bool paused) {
    _countDown = CountDown(endTime.difference(DateTime.now()));
    _timerStream = _countDown.stream.listen(null);
    paused ? _timerStream.pause() : null;

    _timerStream.onData((Duration d) {
      addProgress(d);
    });

    _timerStream.onDone(() {
      _activityModel.timer.progress = _activityModel.timer.fullLength;
    });
  }

  void addProgress(Duration d) {
    _timerProgressStream
        .add(1 - (1 / _activityModel.timer.fullLength * (d.inSeconds)));
  }

  void playTimer() {
    if (_activityModel.timer != null &&
        _timerStream != null &&
        _activityModel.timer.paused) {
      _activityModel.timer.paused = false;
      _activityModel.timer.startTime = DateTime.now();
      _timerStream.resume();
      _timerRunningStream.add(!_activityModel.timer.paused);
    }
    //update();
  }

  void pauseTimer() {
    if (_activityModel.timer != null &&
        _timerStream != null &&
        !_activityModel.timer.paused) {
      _activityModel.timer.paused = true;
      _activityModel.timer.progress +=
          _activityModel.timer.startTime
              .difference(DateTime.now())
              .inSeconds;
      _timerStream.pause();
      _timerRunningStream.add(!_activityModel.timer.paused);
    }
    //update();
  }

  void stopTimer() {
    _activityModel.timer.paused = true;
    _timerRunningStream.add(!_activityModel.timer.paused);
    //update();
  }

  @override
  void dispose() {
    _timerProgressStream.close();
    _timerRunningStream.close();
  }
}