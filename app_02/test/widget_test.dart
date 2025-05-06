import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_02/main.dart'; // Thay đổi nếu cần, đảm bảo đường dẫn chính xác

void main() {
  testWidgets('Adding a new task works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());  // Chú ý sửa lại ở đây nếu tên widget chính của bạn là MyApp

    // Verify that no task is initially present.
    expect(find.text('Không có công việc nào'), findsOneWidget);

    // Tap the FloatingActionButton (add task button).
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the 'Thêm công việc mới' dialog appears.
    expect(find.text('Thêm công việc mới'), findsOneWidget);

    // Enter text into the task title and description fields.
    await tester.enterText(find.byType(TextField).at(0), 'New Task');
    await tester.enterText(find.byType(TextField).at(1), 'Description of new task');

    // Tap the 'Thêm' button to add the task.
    await tester.tap(find.text('Thêm'));
    await tester.pump();

    // Verify that the task was added and no longer shows 'Không có công việc nào'.
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Description of new task'), findsOneWidget);

    // Verify that the dialog is closed after adding the task.
    expect(find.text('Thêm công việc mới'), findsNothing);
  });
}
