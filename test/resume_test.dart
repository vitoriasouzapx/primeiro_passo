import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:primeiro_passo/models/user_profile.dart';
import 'package:primeiro_passo/services/resume_data.dart';
import 'package:primeiro_passo/services/resume_pdf.dart';
import 'package:primeiro_passo/services/app_controller.dart';
import 'package:primeiro_passo/screens/resume_builder_screen.dart';

void main() {
  test('Cursos usam catálogo, evitam duplicidade e preservam dados manuais',
      () {
    final p = UserProfile(completedCourses: [
      'evg-etica'
    ], certificates: [
      'Ética e Serviço Público'
    ], resume: {
      'courses': ['Curso manual'],
      'email': 'teste@example.com',
      'cpf': '123',
      'hidden': ['cpf']
    });
    final restored = UserProfile.fromMap(p.toMap());
    final data = ResumeData(restored);
    expect(data.courses.length, 2);
    expect(data.courses.first, contains('20h'));
    expect(data.certificates, isEmpty);
    expect(data.contacts.containsKey('CPF'), false);
    expect(data.contacts['E-mail Pessoal'], 'teste@example.com');
  });
  test('PDF de várias páginas é gerado com conteúdo extenso', () async {
    final p = UserProfile(
        name: 'Marina Exemplo',
        professionalSummary:
            'Profissional com experiência em organização, atendimento e gestão de documentos.',
        education:
            'Graduação em Administração\nUniversidade Exemplo\n2022 - 2026 - Em andamento',
        resume: {
          'email': 'marina@example.com',
          'courses': List.generate(
              35,
              (i) =>
                  'Curso de desenvolvimento profissional ${i + 1}\nInstituição de Ensino\n2026 - Concluído - 20h')
        });
    final bytes = await buildResumePdf(ResumeData(p));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    final dir = Directory('../pdf-qa')..createSync(recursive: true);
    File('${dir.path}/curriculo_teste.pdf').writeAsBytesSync(bytes);
  });
  testWidgets('Abas, edição persistente, configuração e voltar em celular',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = AppController();
    await c.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: c, child: const MaterialApp(home: ResumeBuilderScreen())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Formação'));
    await tester.tap(find.text('Formação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Adicionar Acadêmica'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Ensino médio');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(
        ResumeData(c.profile).list('education').single.trim(), 'Ensino médio');
    final loaded = await c.local.load();
    expect(ResumeData(loaded).list('education').single.trim(), 'Ensino médio');
    await tester.tap(find.text('Visualizar currículo'));
    await tester.pumpAndSettle();
    expect(find.text('Escolha o que aparece no PDF'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Meu currículo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
