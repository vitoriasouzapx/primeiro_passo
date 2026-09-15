import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/journey_topics.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';
import 'jobs_screen.dart';
import 'resume_builder_screen.dart';
import 'training_hub_screen.dart';

class JourneyTopicScreen extends StatefulWidget {
  final JourneyTopic topic;
  const JourneyTopicScreen({super.key, required this.topic});
  @override
  State<JourneyTopicScreen> createState() => _JourneyTopicScreenState();
}

class _JourneyTopicScreenState extends State<JourneyTopicScreen> {
  late final TextEditingController reflection;
  late final TextEditingController plan;
  final completed = <String>{};
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppController>().profile;
    final id = widget.topic.id;
    reflection = TextEditingController(
        text: profile.journeyNotes['$id.reflection'] ?? '');
    plan = TextEditingController(text: profile.journeyNotes['$id.plan'] ?? '');
    completed.addAll(
        profile.journeyActivities.where((key) => key.startsWith('$id.')));
  }

  @override
  void dispose() {
    reflection.dispose();
    plan.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      await context.read<AppController>().saveJourneyActivity(
          widget.topic.id, reflection.text, plan.text, completed.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anotações e atividades salvas.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Não foi possível salvar. Tente novamente.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final color =
        switch (topic.id) { 'search' => orange, 'entry' => pink, _ => purple };
    final soft = switch (topic.id) {
      'search' => orangeSoft,
      'entry' => pinkSoft,
      _ => purpleSoft
    };
    return Scaffold(
        backgroundColor: bg,
        body: AppSurface(
            child: SafeArea(
          child:
              ListView(padding: const EdgeInsets.only(bottom: 24), children: [
            ScreenHeader(
                title: topic.title,
                subtitle: topic.subtitle,
                trailing: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded))),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SoftCard(
                          color: soft,
                          child: Text(topic.outcome,
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4))),
                      const SizedBox(height: 16),
                      ...topic.sections.map((section) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SoftCard(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(section.$1,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: ink)),
                                const SizedBox(height: 8),
                                Text(section.$2,
                                    style: const TextStyle(
                                        color: muted, height: 1.5)),
                              ])))),
                      const SizedBox(height: 6),
                      const SectionTitle(title: 'Coloque em prática'),
                      SoftCard(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                '${completed.length} de ${topic.activities.length} atividades marcadas',
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            for (var i = 0; i < topic.activities.length; i++)
                              Material(
                                  color: Colors.transparent,
                                  child: CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: color,
                                      title: Text(topic.activities[i],
                                          style: const TextStyle(fontSize: 13)),
                                      value:
                                          completed.contains('${topic.id}.$i'),
                                      onChanged: saving
                                          ? null
                                          : (value) => setState(() {
                                                final key = '${topic.id}.$i';
                                                if (value == true) {
                                                  completed.add(key);
                                                } else {
                                                  completed.remove(key);
                                                }
                                              }))),
                            const SizedBox(height: 12),
                            Text(topic.reflectionLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                                key: ValueKey('${topic.id}.reflection'),
                                controller: reflection,
                                enabled: !saving,
                                minLines: 3,
                                maxLines: 8,
                                maxLength: 4000,
                                decoration: InputDecoration(
                                    hintText: topic.reflectionHint)),
                            const SizedBox(height: 12),
                            Text(topic.planLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                                key: ValueKey('${topic.id}.plan'),
                                controller: plan,
                                enabled: !saving,
                                minLines: 3,
                                maxLines: 8,
                                maxLength: 4000,
                                decoration:
                                    InputDecoration(hintText: topic.planHint)),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                                onPressed: saving ? null : save,
                                style: FilledButton.styleFrom(
                                    backgroundColor: color),
                                icon: const Icon(Icons.save_outlined),
                                label: Text(saving
                                    ? 'Salvando...'
                                    : 'Salvar esta etapa')),
                            const SizedBox(height: 8),
                            const Text(
                                'Salve antes de sair. As anotações são separadas por etapa.',
                                style: TextStyle(color: muted, fontSize: 12)),
                          ])),
                      const SizedBox(height: 16),
                      if (topic.id == 'discovery' || topic.id == 'search')
                        OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const JobsScreen(standalone: true))),
                            icon: const Icon(Icons.search_rounded),
                            label: Text(topic.id == 'discovery'
                                ? 'Explorar cargos nas vagas'
                                : 'Consultar vagas disponíveis')),
                      if (topic.id == 'search')
                        OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ResumeBuilderScreen())),
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Revisar meu currículo')),
                      if (topic.id == 'development')
                        OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrainingHubScreen())),
                            icon: const Icon(Icons.school_outlined),
                            label: const Text('Consultar cursos como apoio')),
                    ])),
          ]),
        )));
  }
}
