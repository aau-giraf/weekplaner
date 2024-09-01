import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/widgets/citizen_avatar_widget.dart';

class MockScreen extends StatelessWidget {
  MockScreen({required this.callback});

  final VoidCallback callback;
  final DisplayNameModel usernameModel =
      DisplayNameModel(displayName: 'Testname', role: 'Guardian', id: '2');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:
            CitizenAvatar(displaynameModel: usernameModel, onPressed: callback),
      ),
    );
  }
}

void main() {
  int i = 0;
  const Key widgetAvatar = Key('WidgetAvatar');
  const Key widgetText = Key('WidgetText');
  final MockScreen mockScreen = MockScreen(callback: () => ++i);

  testWidgets('Test if citizen text appears', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: mockScreen));
    await tester.pumpAndSettle();
    expect(find.byKey(widgetText), findsOneWidget);
  });

  testWidgets('Test if citizen avatar appears', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: mockScreen));
    await tester.pumpAndSettle();
    expect(find.byKey(widgetAvatar), findsOneWidget);
  });

  testWidgets('Test if text is the username', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: mockScreen));
    await tester.pumpAndSettle();
    expect(find.text('Testname'), findsOneWidget);
  });

  testWidgets('Test if callback is working on avatar',
      (WidgetTester tester) async {
    i = 0;
    await tester.pumpWidget(MaterialApp(home: mockScreen));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(widgetAvatar));
    expect(i, 1);
  });

  testWidgets('Test if callback is working on text',
      (WidgetTester tester) async {
    i = 0;
    await tester.pumpWidget(MaterialApp(home: mockScreen));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(widgetText));
    expect(i, 1);
  });
}
