import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/timer_model.dart';

void main() {
  final Map<String, dynamic> response1 = <String, dynamic>{
    'startTime': 123,
    'progress': 123,
    'fullLength': 1234,
    'paused': false
  };

  final Map<String, dynamic> response2 = <String, dynamic>{
    'startTime': 456,
    'progress': 456,
    'fullLength': 4567,
    'paused': true
  };

  test('Should be able to instantiate from JSON', () {
    final TimerModel week1 = TimerModel.fromJson(response1);
    final TimerModel week2 = TimerModel.fromJson(response2);

    expect(week1.startTime,
        DateTime.fromMillisecondsSinceEpoch(response1['startTime']));
    expect(week1.progress, response1['progress']);
    expect(week1.fullLength, response1['fullLength']);
    expect(week1.paused, response1['paused']);

    expect(week2.startTime,
        DateTime.fromMillisecondsSinceEpoch(response2['startTime']));
    expect(week2.progress, response2['progress']);
    expect(week2.fullLength, response2['fullLength']);
    expect(week2.paused, response2['paused']);
  });
}
