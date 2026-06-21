import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aware/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('aware'), findsOneWidget);
    expect(find.text('Stay informed, effortlessly'), findsOneWidget);

    // Advance past the splash timer to avoid pending timer assertion.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump();
  });
}
