import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:netravest/main.dart';
import 'package:netravest/providers/emergency_provider.dart';
import 'package:netravest/widgets/expanded_settings_panel.dart';

void main() {
  testWidgets('Settings panel expand and simulation toggle test', (WidgetTester tester) async {
    // Set a phone-like screen size for testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => EmergencyProvider(enableMqtt: false),
        child: const NetravestApp(),
      ),
    );

    // 1. Verify "Pengaturan" button exists initially
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.byType(ExpandedSettingsPanel), findsNothing);

    // 2. Tap the "Pengaturan" button
    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    // 3. Verify settings panel is now expanded
    expect(find.byType(ExpandedSettingsPanel), findsOneWidget);
    expect(find.text('Ketukan SOS'), findsOneWidget);
    expect(find.text('Simulasi Telemetri'), findsOneWidget);

    // 4. Find and toggle the Simulation mode Switch to ON
    final switchFinder = find.byKey(const Key('switch_simulation'));
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // 5. Toggle the Simulation mode Switch to OFF
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // 6. Close the settings panel
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 6. Verify settings panel is closed
    expect(find.byType(ExpandedSettingsPanel), findsNothing);
    expect(find.text('Pengaturan'), findsOneWidget);
  });
}
