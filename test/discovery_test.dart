import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primeiro_passo/models/discovery.dart';
import 'package:primeiro_passo/models/user_profile.dart';
import 'package:primeiro_passo/services/app_controller.dart';
import 'package:primeiro_passo/services/local_memory_service.dart';
import 'package:primeiro_passo/services/conversation_service.dart';
import 'package:primeiro_passo/screens/discovery_screen.dart';
import 'package:primeiro_passo/data/course_catalog.dart';
import 'package:primeiro_passo/services/cloud_service.dart';

class SimulatedConversation extends ConversationService {
  const SimulatedConversation() : super(baseUrl: 'https://example.com');
  @override
  Future<ConversationReply> send(String message, List<ChatMessage> history,
          Map<String, dynamic> discovery, String? token) async =>
      const ConversationReply('Podemos explorar desenho como interesse.', [
        ProfileSuggestion(
            'interests', 'Desenho', 'Você contou que gosta de desenhar')
      ]);
}

class FakeCloud extends CloudService {
  String? current;
  final users = <String, UserProfile>{};
  @override
  String? get uid => current;
  @override
  bool get signedIn => current != null;
  @override
  Future<UserProfile?> load() async => users[current];
  @override
  Future<void> save(UserProfile p) async {
    users[current!] = p;
  }

  @override
  Future<void> logout() async {
    current = null;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('login never uploads guest or previous account memory', () async {
    final cloud = FakeCloud();
    final c = AppController(cloud: cloud);
    await c.init();
    await c.confirmSuggestion(
        const ProfileSuggestion('interests', 'Visitante', 'manual'));
    cloud.current = 'a';
    await c.enterAccount();
    expect(c.profile.discovery, isEmpty);
    await c.confirmSuggestion(
        const ProfileSuggestion('interests', 'Conta A', 'manual'));
    await c.leaveAccount();
    expect(c.profile.discovery['interests'], ['Visitante']);
    cloud.current = 'b';
    await c.enterAccount();
    expect(c.profile.discovery, isEmpty);
    expect(cloud.users['a']!.discovery['interests'], ['Conta A']);
  });
  testWidgets(
      'simulated conversation proposes but only confirmation changes map',
      (tester) async {
    final c = AppController();
    await c.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: c,
        child: const MaterialApp(
            home: DiscoveryScreen(service: SimulatedConversation()))));
    await tester.enterText(find.byType(TextField).first, 'Gosto de desenhar');
    await tester.ensureVisible(find.text('Enviar'));
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(c.profile.discovery, isEmpty);
    expect(c.profile.conversation.length, 2);
    await tester.ensureVisible(find.text('Confirmar no meu mapa'));
    await tester.tap(find.text('Confirmar no meu mapa'));
    await tester.pumpAndSettle();
    expect(c.profile.discovery['interests'], ['Desenho']);
    expect((await LocalMemoryService().load()).conversation.last.suggestions,
        isEmpty);
    expect(tester.takeException(), isNull);
  });
  test('confirmed memories persist without inventing skills or resume',
      () async {
    final c = AppController();
    await c.init();
    final skills = Map.of(c.profile.skills);
    await c.confirmSuggestion(
        const ProfileSuggestion('interests', 'Desenho', 'Você contou'));
    await c.confirmSuggestion(const ProfileSuggestion(
        'targetRole', 'Designer', 'Você escolheu explorar'));
    expect(c.profile.skills, skills);
    expect(c.profile.resume, isEmpty);
    expect(c.engine.requirements(c.profile), isEmpty);
    final restored = await LocalMemoryService().load();
    expect(restored.discovery['interests'], ['Desenho']);
    expect(restored.targetRole, 'Designer');
    await c.removeMemory('interests', 'Desenho');
    expect((await LocalMemoryService().load()).discovery['interests'], isEmpty);
  });
  test('conversation survives reload and account caches stay separate',
      () async {
    final a = LocalMemoryService()..userId = 'a';
    final b = LocalMemoryService()..userId = 'b';
    final p = UserProfile(
        conversation: [const ChatMessage('user', 'Gosto de desenhar')]);
    await a.save(p);
    expect((await b.load()).conversation, isEmpty);
    expect((await a.load()).conversation.single.content, 'Gosto de desenhar');
    expect((await LocalMemoryService().load()).conversation, isEmpty);
  });
  test('chosen learning areas prioritize courses, completion is idempotent',
      () async {
    final c = AppController();
    await c.init();
    await c.confirmSuggestion(
        const ProfileSuggestion('focusSkills', 'Comunicação', 'Aprender'));
    expect(c.recommendedCourses().first.skill, 'Comunicação');
    final course = courseCatalog.first;
    await c.completeCourse(course);
    final score = c.profile.skills[course.skill];
    await c.completeCourse(course);
    expect(c.profile.skills[course.skill], score);
  });
  test('API sends history and only approved professional memory', () async {
    final service = ConversationService(
        baseUrl: 'https://example.com',
        client: MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(body['history'][0]['content'], 'Design');
          expect(body.containsKey('profile'), false);
          expect(request.headers['Authorization'], 'Bearer test-token');
          return http.Response(
              jsonEncode({'answer': 'Vamos explorar.', 'suggestions': []}),
              200);
        }));
    final reply = await service.send(
        'Como?',
        [const ChatMessage('user', 'Design')],
        {
          'interests': ['Desenho']
        },
        'test-token');
    expect(reply.answer, 'Vamos explorar.');
  });
  test('no configured provider never impersonates live AI', () async {
    expect(() => const ConversationService().send('Olá', [], {}, null),
        throwsStateError);
  });
  testWidgets('discovery works without AI and fits narrow screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController();
    await c.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: c, child: const MaterialApp(home: DiscoveryScreen())));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('A IA ainda não está conectada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
