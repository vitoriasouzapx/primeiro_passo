import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';
import 'journey_routes.dart';

import 'human_work_screen.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final stages = [
      _Stage(
        '1',
        'Descoberta',
        'Interesses, experiências e comparação de caminhos profissionais.',
        Icons.explore_rounded,
        purple,
        purpleSoft,
        c.stageProgress('discovery'),
        () => openJourneyStage(context, 'discovery'),
      ),
      _Stage(
        '2',
        'Capacitação',
        'Cursos recomendados pelas lacunas reais da sua vaga-alvo.',
        Icons.school_rounded,
        blue,
        blueSoft,
        c.stageProgress('training'),
        () => openJourneyStage(context, 'training'),
      ),
      _Stage(
        '3',
        'Currículo inteligente',
        'Currículo padrão alimentado por perfil, competências, cursos e certificados.',
        Icons.description_rounded,
        green,
        greenSoft,
        c.stageProgress('resume'),
        () => openJourneyStage(context, 'resume'),
      ),
      _Stage(
        '4',
        'Busca e seleção',
        'Critérios de busca, acompanhamento de candidaturas e entrevistas.',
        Icons.business_center_rounded,
        orange,
        orangeSoft,
        c.stageProgress('search'),
        () => openJourneyStage(context, 'search'),
      ),
      _Stage(
        '5',
        'Entrada e adaptação',
        'Primeiros dias, prioridades, procedimentos e alinhamento com a equipe.',
        Icons.trending_up_rounded,
        pink,
        pinkSoft,
        c.stageProgress('entry'),
        () => openJourneyStage(context, 'entry'),
      ),
      _Stage(
        '6',
        'Desenvolvimento',
        'Feedback, prática e um plano de evolução para os próximos 90 dias.',
        Icons.auto_graph_rounded,
        purple,
        purpleSoft,
        c.stageProgress('development'),
        () => openJourneyStage(context, 'development'),
      ),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const ScreenHeader(
            title: 'Trilhas',
            subtitle:
                'Sua posição é calculada automaticamente a partir das suas ações e dados.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                SoftCard(
                  color: const Color(0xFFF7F3FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jornada inteligente',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Sem aulas e sem pedir que você estime seu próprio progresso. Cursos, currículo, vagas, candidaturas e contratação movimentam a jornada.',
                        style: TextStyle(color: muted, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      ProgressLine(value: c.overallProgress()),
                      const SizedBox(height: 7),
                      Text(
                        '${(c.overallProgress() * 100).round()}% da jornada mapeada',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ...stages.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StageCard(s: s),
                  ),
                ),
                SoftCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HumanWorkScreen()),
                  ),
                  child: const Row(
                    children: [
                      IconBadge(
                        icon: Icons.psychology_alt_rounded,
                        color: purple,
                        background: purpleSoft,
                        size: 52,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ser Humano no Trabalho',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gestão emocional, crenças, valores, expectativas e relações no trabalho.',
                              style: TextStyle(color: muted, height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage {
  final String n, title, sub;
  final IconData icon;
  final Color color, bg;
  final double progress;
  final VoidCallback tap;
  _Stage(
    this.n,
    this.title,
    this.sub,
    this.icon,
    this.color,
    this.bg,
    this.progress,
    this.tap,
  );
}

class _StageCard extends StatelessWidget {
  final _Stage s;
  const _StageCard({required this.s});
  @override
  Widget build(BuildContext context) => SoftCard(
        onTap: s.tap,
        child: Row(
          children: [
            IconBadge(icon: s.icon, color: s.color, background: s.bg, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s.n}. ${s.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.sub,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: muted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: ProgressLine(value: s.progress, color: s.color),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(s.progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      );
}
