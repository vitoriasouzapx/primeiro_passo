import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/course_catalog.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final gaps = controller.gaps();
    final courses = controller.recommendedCourses();

    return Scaffold(
      backgroundColor: bg,
      body: AppSurface(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ScreenHeader(
                title: 'Capacitação',
                subtitle: controller.profile.targetRole.isEmpty
                    ? 'Cursos priorizados pelas competências que precisam ser desenvolvidas.'
                    : 'Cursos priorizados para ${controller.profile.targetRole}.',
                trailing: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftCard(
                      color: blueSoft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lacunas detectadas automaticamente',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 9),
                          if (gaps.isEmpty)
                            const Text(
                              'Você atende aos requisitos mapeados da vaga-alvo.',
                              style: TextStyle(color: muted),
                            )
                          else
                            ...gaps.entries.map((entry) {
                              final current =
                                  controller.profile.skills[entry.key] ?? 0;
                              final expected = (current + entry.value).clamp(
                                0.0,
                                1.0,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(current * 100).round()}% → ${(expected * 100).round()}%',
                                      style: const TextStyle(
                                        color: purple,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SectionTitle(title: 'Cursos recomendados'),
                    if (courses.isEmpty)
                      const SoftCard(
                        child: Text(
                          'Nenhum curso pendente para as lacunas atuais.',
                          style: TextStyle(color: muted),
                        ),
                      )
                    else
                      ...courses.map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: _CourseCard(course: course),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const SoftCard(
                      color: greenSoft,
                      child: Text(
                        'Nesta versão, os botões abrem as plataformas oficiais. Com APIs ou convênios institucionais, a conclusão poderá ser sincronizada automaticamente.',
                        style: TextStyle(
                          color: ink,
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
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

class _CourseCard extends StatelessWidget {
  final CourseItem course;

  const _CourseCard({required this.course});

  Future<void> _openCourse(BuildContext context) async {
    final uri = Uri.parse(course.url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o curso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final done = controller.profile.completedCourses.contains(course.id);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                icon: Icons.school_rounded,
                color: blue,
                background: blueSoft,
                size: 46,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    Text(
                      '${course.provider} • ${course.workload}',
                      style: const TextStyle(color: muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (done) const Icon(Icons.verified_rounded, color: green),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            course.description,
            style: const TextStyle(color: muted, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(course.skill),
                visualDensity: VisualDensity.compact,
              ),
              if (!done)
                FilledButton.icon(
                  onPressed: () => _openCourse(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Abrir curso'),
                ),
              if (!done)
                OutlinedButton(
                  onPressed: () => controller.completeCourse(course),
                  child: const Text('Já concluí'),
                ),
              if (done) const Chip(label: Text('No currículo ✓')),
            ],
          ),
        ],
      ),
    );
  }
}
