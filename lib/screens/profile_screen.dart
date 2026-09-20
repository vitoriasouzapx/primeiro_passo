import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../data/catalog.dart';
import '../widgets/ui.dart';
import 'resume_builder_screen.dart';
import 'journey_screen.dart';
import 'jobs_screen.dart';
import 'assistant_screen.dart';
import '../widgets/brand.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.profile;
    final compatibility = c.engine.compatibility(p);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const ScreenHeader(
            title: 'Meu perfil',
            subtitle: 'Seu perfil vivo muda conforme você avança.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                SoftCard(
                  color: const Color(0xFFFBF9FF),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFD6C5FF), Color(0xFFB8EAFF)],
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 39,
                          color: purpleDark,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              p.targetRole,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ProgressLine(value: compatibility),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(compatibility * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ResumeBuilderScreen())),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Meu currículo'),
                ),
                const SectionTitle(
                  title: 'Informações principais',
                  icon: Icons.badge_outlined,
                ),
                TextFormField(
                  initialValue: p.name,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  onChanged: (v) {
                    p.name = v;
                    c.persist();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  key: ValueKey(p.targetRole),
                  value: p.targetRole,
                  decoration: const InputDecoration(
                    labelText: 'Vaga-alvo',
                    prefixIcon: Icon(Icons.track_changes_rounded),
                  ),
                  items: {p.targetRole, ...jobs.map((job) => job.title)}
                      .map(
                        (j) => DropdownMenuItem(
                          value: j,
                          child: Text(j, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      c.setTargetRole(v);
                    }
                  },
                ),
                const SizedBox(height: 22),
                const SectionTitle(
                  title: 'Competências',
                  icon: Icons.auto_graph_rounded,
                ),
                ...p.skills.entries.map(
                  (e) => _SkillSlider(
                    name: e.key,
                    value: e.value,
                    onChanged: (v) {
                      p.skills[e.key] = v;
                      c.persist();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'Sinais emocionais',
                  icon: Icons.psychology_alt_outlined,
                ),
                ...p.emotionalSignals.entries.map(
                  (e) => _SkillSlider(
                    name: e.key,
                    value: e.value,
                    color: pink,
                    onChanged: (v) {
                      p.emotionalSignals[e.key] = v;
                      c.persist();
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const SectionTitle(
                  title: 'Registrar evolução',
                  icon: Icons.add_task_rounded,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _EventButton(
                        icon: Icons.description_outlined,
                        label: 'Candidatura',
                        color: blue,
                        onTap: () {
                          p.applications.add('Candidatura ${DateTime.now()}');
                          c.addEvent('application');
                          c.persist();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EventButton(
                        icon: Icons.groups_outlined,
                        label: 'Entrevista',
                        color: orange,
                        onTap: () {
                          p.interviews.add('Entrevista ${DateTime.now()}');
                          c.addEvent('interview');
                          c.persist();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EventButton(
                        icon: Icons.celebration_rounded,
                        label: 'Contratação',
                        color: green,
                        onTap: () {
                          p.hired = true;
                          c.addEvent('hired');
                          c.persist();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SoftCard(
                  color: blueSoft,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: purple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Quanto mais você atualiza seu perfil, mais o motor de recomendação ajusta prioridades e trilhas.',
                          style: TextStyle(
                            color: ink.withOpacity(.8),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
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

class _SkillSlider extends StatelessWidget {
  final String name;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SkillSlider({
    required this.name,
    required this.value,
    required this.onChanged,
    this.color = purple,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(fontWeight: FontWeight.w900, color: color),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: 1,
              activeColor: color,
              inactiveColor: const Color(0xFFE5E9F1),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _EventButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withOpacity(.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppController>().profile;
    void open(String title, Widget page) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                Scaffold(appBar: AppBar(title: Text(title)), body: page)));
    return SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.all(22), children: [
          const Text('Perfil',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 26),
          Center(
              child: CircleAvatar(
                  radius: 38,
                  backgroundColor: purpleSoft,
                  child: Text(
                      p.name.isEmpty
                          ? 'P'
                          : p.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 30, color: purple)))),
          const SizedBox(height: 12),
          Text(p.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.bold, color: ink)),
          const SizedBox(height: 5),
          Text(p.targetRole,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted)),
          const SizedBox(height: 26),
          SoftCard(
              padding: EdgeInsets.zero,
              child: Material(
                  color: Colors.transparent,
                  child: Column(children: [
                    ListTile(
                        leading: const Icon(Icons.explore_outlined),
                        title: const Text('Minha jornada'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            open('Minha jornada', const JourneyScreen())),
                    ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Meu currículo e certificados'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ResumeBuilderScreen()))),
                    ListTile(
                        leading: const Icon(Icons.work_outline),
                        title: const Text('Oportunidades'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => open('Oportunidades', const JobsScreen())),
                    ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: const Text('Meu assistente'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            open('Assistente', const AssistantScreen())),
                    ListTile(
                        leading: const Icon(Icons.tune),
                        title: const Text('Editar perfil e competências'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            open('Meu perfil', const ProfileDetailsScreen())),
                  ]))),
          const SizedBox(height: 30),
          const Center(child: BrandLogo()),
          const SizedBox(height: 12),
          const Text('Mais que vagas, novos horizontes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12))
        ]));
  }
}
