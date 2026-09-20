import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_controller.dart';
import '../services/resume_data.dart';
import '../widgets/ui.dart';
import '../widgets/cycle_progress.dart';
import 'resume_builder_screen.dart';

class ResumeOverviewScreen extends StatelessWidget {
  const ResumeOverviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final d = ResumeData(c.profile);
    final rows = [
      (
        'Dados pessoais',
        d.field('email').isNotEmpty && c.profile.name.isNotEmpty
      ),
      ('Objetivo profissional', c.profile.targetRole.isNotEmpty),
      ('Formação', d.sections['FORMAÇÃO']!.isNotEmpty),
      ('Experiências', d.sections['EXPERIÊNCIAS']!.isNotEmpty),
      (
        'Cursos e habilidades',
        d.courses.isNotEmpty || c.profile.skills.isNotEmpty
      ),
      ('Idiomas', d.sections['IDIOMAS']!.isNotEmpty)
    ];
    void open(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    return SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Meu currículo',
                      style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: ink)),
                  SizedBox(height: 6),
                  Text('Complete suas informações\ne aumente suas chances.',
                      style: TextStyle(color: muted))
                ])),
            CycleProgress(value: rows.where((r) => r.$2).length / rows.length)
          ]),
          const SizedBox(height: 22),
          SoftCard(
              padding: EdgeInsets.zero,
              child: Material(
                  color: Colors.transparent,
                  child: Column(children: [
                    for (var i = 0; i < rows.length; i++)
                      ListTile(
                          leading: Icon(
                              [
                                Icons.person_outline,
                                Icons.flag_outlined,
                                Icons.school_outlined,
                                Icons.work_outline,
                                Icons.verified_outlined,
                                Icons.language
                              ][i],
                              color: rows[i].$2 ? green : ink,
                              size: 21),
                          title: Text(rows[i].$1,
                              style: const TextStyle(fontSize: 14, color: ink)),
                          trailing: Icon(
                              rows[i].$2
                                  ? Icons.check_circle
                                  : Icons.chevron_right,
                              color: rows[i].$2 ? green : muted,
                              size: 19),
                          onTap: () => open(const ResumeBuilderScreen()))
                  ]))),
          const SizedBox(height: 18),
          const SoftCard(
              color: purpleSoft,
              child: Row(children: [
                Icon(Icons.lightbulb_outline, color: purple),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'Um bom currículo te aproxima de grandes oportunidades. Suas conquistas nas trilhas aparecem aqui.',
                        style: TextStyle(
                            color: purple, fontSize: 13, height: 1.5)))
              ])),
          const SizedBox(height: 22),
          FilledButton(
              onPressed: () => open(ResumePreviewScreen(data: d)),
              child: const Text('Visualizar currículo')),
          const SizedBox(height: 9),
          OutlinedButton(
              onPressed: () => open(const ResumeExportScreen()),
              child: const Text('Gerar PDF')),
          const SizedBox(height: 9),
          TextButton(
              onPressed: () => open(const ResumeBuilderScreen()),
              child: const Text('Editar informações'))
        ]));
  }
}
