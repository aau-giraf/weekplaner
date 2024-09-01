import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/blocs/copy_activities_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_copy_activities_dialog.dart';

List<bool> checkboxValues = <bool>[];

class MockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Column(
        children: <Widget>[
          GirafButton(
              key: const Key('FirstButton'),
              onPressed: () {
                confirmDialog(context);
              }),
        ],
      )),
    );
  }

  void confirmDialog(BuildContext context) {
    showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafCopyActivitiesDialog(
              title: 'test',
              description: 'test',
              confirmButtonText: 'test',
              confirmButtonIcon: const ImageIcon(null),
              confirmOnPressed: (List<bool> days, BuildContext context) {
                checkboxValues = days;
                Routes().pop(context);
              },
              key: UniqueKey());
        });
  }
}

void main() {
  setUp(() {
    di.clearAll();
    di.registerDependency<CopyActivitiesBloc>(() => CopyActivitiesBloc());
  });

  testWidgets('Test if Confirm Dialog is shown', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MockScreen()));
    await tester.tap(find.byKey(const Key('FirstButton')));
    await tester.pump();
    expect(find.byType(GirafCopyActivitiesDialog), findsOneWidget);
  });

  testWidgets('Test if Confirm Dialog is closed when tapping Cancel button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MockScreen()));
    await tester.tap(find.byKey(const Key('FirstButton')));
    await tester.pump();
    expect(find.byType(GirafCopyActivitiesDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('DialogCancelButton')));
    await tester.pump();
    expect(find.byType(GirafCopyActivitiesDialog), findsNothing);
  });

  //In this case, the confirmed action is closing the widget
  testWidgets(
      'Test if confirmed action is performed when tapping Confirm button',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MockScreen()));
    await tester.tap(find.byKey(const Key('FirstButton')));
    await tester.pump();
    expect(find.byType(GirafCopyActivitiesDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('DialogConfirmButton')));
    await tester.pump();
    expect(find.byType(GirafCopyActivitiesDialog), findsNothing);
  });

  testWidgets(
      'Test that values get changed when clicking all the checkboxes '
      'independetly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MockScreen()));

    final List<String> keys = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    for (Weekday day in Weekday.values) {
      await tester.tap(find.byKey(const Key('FirstButton')));
      await tester.pump();
      expect(find.byType(GirafCopyActivitiesDialog), findsOneWidget);
      await tester.tap(find.byKey(Key(keys[day.index] + 'Checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('DialogConfirmButton')));
      await tester.pumpAndSettle();
      expect(checkboxValues[day.index], isTrue);
    }
  });
}
