import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  late final TextEditingController summaryController;
  late final TextEditingController educationController;
  final TextEditingController certificateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppController>().profile;
    summaryController = TextEditingController(
      text: profile.professionalSummary,
    );
    educationController = TextEditingController(text: profile.education);
  }

  @override
  void dispose() {
    summaryController.dispose();
    educationController.dispose();
    certificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profile = controller.profile;
    final progress = controller.stageProgress('resume');

    return Scaffold(
      backgroundColor: bg,
      body: AppSurface(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              ScreenHeader(
                title: 'Currículo inteligente',
                subtitle: 'Seu currículo é atualizado a partir da sua jornada.',
                trailing: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SoftCard(
                      color: greenSoft,
                      child: Row(
                        children: [
                          const IconBadge(
                            icon: Icons.sync_rounded,
                            color: green,
                            background: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currículo vivo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cursos, certificados e competências registrados entram automaticamente. ${(progress * 100).round()}% do perfil preenchido.',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 11.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações principais',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: summaryController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Resumo profissional',
                              hintText:
                                  'Ex.: Profissional em início de carreira...',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: educationController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Formação',
                              hintText:
                                  'Ex.: Ensino médio completo / graduação...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                await controller.updateResume(
                                  summary: summaryController.text,
                                  education: educationController.text,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Currículo atualizado.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Salvar informações'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AutoSection(
                      title: 'Objetivo profissional',
                      items: profile.targetRole.isEmpty
                          ? const []
                          : [profile.targetRole],
                    ),
                    _AutoSection(
                      title: 'Competências',
                      items: profile.skills.entries
                          .map(
                            (entry) =>
                                '${entry.key} • ${(entry.value * 100).round()}%',
                          )
                          .toList(),
                    ),
                    _AutoSection(
                      title: 'Cursos e certificações',
                      items: [
                        ...profile.completedCourses.map(
                          (courseId) => 'Curso concluído • $courseId',
                        ),
                        ...profile.certificates,
                      ],
                    ),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adicionar certificado externo',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 9),
                          TextField(
                            controller: certificateController,
                            decoration: const InputDecoration(
                              hintText:
                                  'Ex.: Excel Intermediário — instituição — 20h',
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await controller.addCertificate(
                                certificateController.text,
                              );
                              certificateController.clear();
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Adicionar ao currículo'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SoftCard(
                      color: purpleSoft,
                      child: Text(
                        'Evolução prevista: gerar PDF padronizado por vaga e receber certificados automaticamente por integrações autorizadas.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _AutoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Ainda sem dados.', style: TextStyle(color: muted))
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 17,
                        color: green,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 12.5, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
