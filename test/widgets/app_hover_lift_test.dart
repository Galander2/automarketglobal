import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1_car_sales/widgets/app_hover_lift.dart';

void main() {
  testWidgets('custom controls lift when hovered', (tester) async {
    const targetKey = Key('hover-target');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppHoverLift(
              child: SizedBox(key: targetKey, width: 120, height: 48),
            ),
          ),
        ),
      ),
    );

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(targetKey)));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      closeTo(1.018, 0.0001),
    );

    await mouse.removePointer();
  });

  testWidgets('disabled custom controls stay still', (tester) async {
    const targetKey = Key('disabled-hover-target');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppHoverLift(
            enabled: false,
            child: SizedBox(key: targetKey, width: 120, height: 48),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(targetKey)));
    await tester.pumpAndSettle();

    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);

    await mouse.removePointer();
  });
}
