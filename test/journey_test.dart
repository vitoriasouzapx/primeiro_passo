import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primeiro_passo/services/app_controller.dart';
import 'package:primeiro_passo/screens/journey_screen.dart';
import 'package:primeiro_passo/screens/journey_topic_screen.dart';
import 'package:primeiro_passo/screens/home_screen.dart';
import 'package:primeiro_passo/models/user_profile.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stage activities persist independently and old profiles still load',
      () async {
    expect(UserProfile.fromMap({}).journeyNotes, isEmpty);
    final c = AppController();
    await c.init();
    await c.saveJourneyActivity(
        'discovery', 'Interesses', 'Explorar RH', ['discovery.0']);
    await c.saveJourneyActivity(
        'development', 'Feedback', 'Plano de 90 dias', ['development.1']);
    final restored = AppController();
    await restored.init();
    expect(restored.profile.journeyNotes['discovery.plan'], 'Explorar RH');
    expect(
        restored.profile.journeyNotes['development.plan'], 'Plano de 90 dias');
    expect(restored.profile.journeyActivities,
        containsAll(['discovery.0', 'development.1']));
    c.dispose();
    restored.dispose();
  });

  const routes = {
    '1. Descoberta': 'Interesses e rotina de trabalho',
    '2. Capacitação': 'Lacunas detectadas automaticamente',
    '3. Currículo inteligente': 'Meu currículo',
    '4. Busca e seleção': 'Faça uma busca com critérios',
    '5. Entrada e adaptação': 'Antes do primeiro dia',
    '6. Desenvolvimento': 'Observe sua atuação atual',
  };
  for (final route in routes.entries) {
    testWidgets('${route.key} opens its own subject', (tester) async {
      final c = AppController();
      await c.init();
      await tester.pumpWidget(ChangeNotifierProvider.value(
          value: c,
          child: const MaterialApp(home: Scaffold(body: JourneyScreen()))));
      await tester.scrollUntilVisible(find.text(route.key), 250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(route.key));
      await tester.pumpAndSettle();
      expect(find.text(route.value), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    });
  }

  testWidgets('home discovery opens the discovery content directly',
      (tester) async {
    final c = AppController();
    await c.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: c,
        child:
            MaterialApp(home: Scaffold(body: HomeScreen(onNavigate: (_) {})))));
    await tester.scrollUntilVisible(find.text('1. Descoberta'), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1. Descoberta'));
    await tester.pumpAndSettle();
    expect(find.byType(JourneyTopicScreen), findsOneWidget);
    expect(find.text('Interesses e rotina de trabalho'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}

