import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primeiro_passo/main.dart';
import 'package:primeiro_passo/services/app_controller.dart';

void main() {
  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(844, 390),
    const Size(800, 1000),
    const Size(1440, 900),
  ]) {
    testWidgets('Navegação e layout em ${size.width} x ${size.height}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController();
      await controller.init();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const PrimeiroPassoApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byType(NavigationRail),
        size.width >= 760 && size.height >= 480 ? findsOneWidget : findsNothing,
      );
      for (final label in [
        'Trilhas',
        'Assistente',
        'Vagas',
        'Perfil',
        'Início',
      ]) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
      }
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }
}
