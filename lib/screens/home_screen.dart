import 'journey_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';
import '../widgets/cycle_progress.dart';
import 'human_work_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.profile;
    final recommendations = c.engine.recommend(p);
    final compatibility = c.engine.compatibility(p);
    final firstName = p.name.trim().isEmpty
        ? 'Você'
        : p.name.trim().split(' ').first;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD7C7FF), Color(0xFFB9E7FF)],
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: purpleDark,
                  size: 31,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $firstName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    const Text(
                      'Que bom ter você por aqui.',
                      style: TextStyle(fontSize: 14, color: muted),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 29,
                      color: ink,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5A5F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HeroCard(),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFFF9FBFF),
            child: Column(
              children: [
                Row(
                  children: [
                    const IconBadge(
                      icon: Icons.track_changes_rounded,
                      color: purple,
                      background: purpleSoft,
                      size: 45,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seu objetivo atual',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.targetRole,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: ink,
                            ),
                          ),
                          Text(
                            'Você está na fase de ${p.journeyStage}',
                            style: const TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigate(1),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver meu plano',
                            style: TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 16, color: ink),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CycleProgress(value: compatibility),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth >= 720 ? 4 : 2;
              final width = (box.maxWidth - 12 * (columns - 1)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MiniStatCard(
                    icon: Icons.school_rounded,
                    color: const Color(0xFF009E74),
                    background: greenSoft,
                    value: '${p.completedCourses.length}',
                    label: 'Cursos\nconcluídos',
                  ),
                  MiniStatCard(
                    icon: Icons.description_outlined,
                    color: const Color(0xFF2478E5),
                    background: blueSoft,
                    value: '${p.applications.length}',
                    label: 'Candidaturas\nenviadas',
                  ),
                  MiniStatCard(
                    icon: Icons.groups_rounded,
                    color: const Color(0xFFE46823),
                    background: orangeSoft,
                    value: '${p.interviews.length}',
                    label: 'Entrevistas\nregistradas',
                  ),
                  MiniStatCard(
                    icon: Icons.trending_up_rounded,
                    color: purple,
                    background: purpleSoft,
                    value: '${(compatibility * 100).round()}%',
                    label: 'Compatibilidade\ncom a meta',
                  ),
                ].map((card) => SizedBox(width: width, child: card)).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Próximas ações para você',
            icon: Icons.rocket_launch_rounded,
            action: 'Ver todas',
            onAction: () => onNavigate(1),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.isEmpty
                  ? 1
                  : recommendations.take(3).length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, i) {
                if (recommendations.isEmpty) {
                  return SizedBox(
                    width: 225,
                    child: ActionCard(
                      icon: Icons.check_circle_outline,
                      title: 'Continue avançando',
                      subtitle:
                          'Seu perfil está evoluindo. Explore sua jornada.',
                      color: green,
                      background: greenSoft,
                      onTap: () => onNavigate(1),
                    ),
                  );
                }
                final r = recommendations[i];
                final data = _actionStyle(i, r.title);
                return SizedBox(
                  width: 225,
                  child: ActionCard(
                    icon: data.$1,
                    title: r.title,
                    subtitle: r.action,
                    color: data.$2,
                    background: data.$3,
                    onTap: () => _handleRecommendation(context, r.title),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: 'Trilhas da sua jornada',
            icon: Icons.map_outlined,
            action: 'Continuar de onde parou',
            onAction: () => onNavigate(1),
          ),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _JourneyTile(
                  number: '1',
                  title: 'Descoberta',
                  subtitle: 'Conheça seu perfil',
                  icon: Icons.explore_rounded,
                  colors: const [Color(0xFF8B5CF6), Color(0xFF7054E8)],
                  onTap: () => openJourneyStage(context, 'discovery'),
                ),
                _JourneyTile(
                  number: '2',
                  title: 'Capacitação',
                  subtitle: 'Desenvolva competências',
                  icon: Icons.school_rounded,
                  colors: const [Color(0xFF55B9F8), Color(0xFF2688E9)],
                  onTap: () => openJourneyStage(context, 'training'),
                ),
                _JourneyTile(
                  number: '3',
                  title: 'Currículo',
                  subtitle: 'Organize suas experiências',
                  icon: Icons.fact_check_rounded,
                  colors: const [Color(0xFF57D4A4), Color(0xFF2CBF85)],
                  onTap: () => openJourneyStage(context, 'resume'),
                ),
                _JourneyTile(
                  number: '4',
                  title: 'Busca e seleção',
                  subtitle: 'Candidaturas e entrevistas',
                  icon: Icons.search_rounded,
                  colors: const [Color(0xFFFFB05F), Color(0xFFF37B27)],
                  onTap: () => openJourneyStage(context, 'search'),
                ),
                _JourneyTile(
                  number: '5',
                  title: 'Entrada e adaptação',
                  subtitle: 'Prepare os primeiros dias',
                  icon: Icons.work_rounded,
                  colors: const [Color(0xFFF27695), Color(0xFFE34F76)],
                  onTap: () => openJourneyStage(context, 'entry'),
                ),
                _JourneyTile(
                  number: '6',
                  title: 'Desenvolvimento',
                  subtitle: 'Planeje sua evolução',
                  icon: Icons.trending_up_rounded,
                  colors: const [Color(0xFF8B5CF6), Color(0xFF7054E8)],
                  onTap: () => openJourneyStage(context, 'development'),
                ),
                _JourneyTile(
                  number: '',
                  title: 'Especial',
                  subtitle: 'Ser Humano no Trabalho',
                  icon: Icons.favorite_rounded,
                  colors: const [Color(0xFF8A4BE8), Color(0xFF5B2CBC)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HumanWorkScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SoftCard(
            color: const Color(0xFFF2F8FF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: greenSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: Color(0xFF2BA56E),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pequenas atitudes de hoje constroem grandes oportunidades amanhã.',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: ink,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Você está mais perto do que imagina.',
                        style: TextStyle(fontSize: 11.5, color: muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, Color) _actionStyle(int i, String title) {
    final t = title.toLowerCase();
    if (t.contains('entrevista'))
      return (Icons.chat_bubble_outline_rounded, purple, purpleSoft);
    if (t.contains('ansiedade') || t.contains('emoc'))
      return (Icons.psychology_alt_outlined, blue, blueSoft);
    if (t.contains('excel') || t.contains('desenvolver'))
      return (Icons.laptop_mac_rounded, const Color(0xFF2478E5), blueSoft);
    return i.isEven
        ? (Icons.school_outlined, green, greenSoft)
        : (Icons.auto_awesome_rounded, purple, purpleSoft);
  }

  void _handleRecommendation(BuildContext context, String title) {
    if (title.toLowerCase().contains('ansiedade') ||
        title.toLowerCase().contains('emoc')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HumanWorkScreen()),
      );
    } else {
      onNavigate(1);
    }
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final narrow = box.maxWidth < 430;
        final illustration = Image.asset(
          'assets/images/trilha_profissional.png',
          height: narrow ? 165 : 220,
          width: narrow ? 120 : 160,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        );
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primeiro Passo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Do primeiro passo ao primeiro emprego.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Desenvolva suas habilidades, conheça seu potencial e construa um futuro com mais segurança.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Disciplina hoje, oportunidades amanhã.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF5722C9), Color(0xFF7E4FF1), Color(0xFFAC62C9)],
            ),
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copy,
                    Align(
                      alignment: Alignment.centerRight,
                      child: illustration,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 20),
                    illustration,
                  ],
                ),
        );
      },
    );
  }
}

class _JourneyTile extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _JourneyTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.last, size: 21),
              ),
              const Spacer(),
              Text(
                number.isEmpty ? title : '$number. $title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
