import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';
import '../widgets/brand.dart';
import '../widgets/cycle_progress.dart';
import 'journey_routes.dart';
import 'assistant_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final name = c.profile.name.trim();
    const stages = [
      ('discovery', 'Descoberta', 'Conheça seus interesses'),
      ('training', 'Capacitação', 'Desenvolva suas habilidades'),
      (
        'resume',
        'Currículo inteligente',
        'Prepare sua apresentação profissional'
      ),
      ('search', 'Busca e seleção', 'Encontre novas oportunidades'),
      ('entry', 'Entrada e adaptação', 'Prepare seus primeiros dias'),
      ('development', 'Desenvolvimento', 'Continue evoluindo')
    ];
    final progress =
        stages.map((s) => c.stageProgress(s.$1)).reduce((a, b) => a + b) /
            stages.length;
    return SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const BrandLogo(),
          const SizedBox(height: 24),
          Row(children: [
            CircleAvatar(
                backgroundColor: purpleSoft,
                child: Text(
                    name.isEmpty ? 'P' : name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: purple, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Olá, ${name.isEmpty ? 'você' : name.split(' ').first}!',
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: ink)),
                  const Text('Que bom te ver por aqui!',
                      style: TextStyle(color: muted, fontSize: 12))
                ])),
            IconButton(
                tooltip: 'Assistente',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Assistente')),
                            body: const AssistantScreen()))),
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: ink))
          ]),
          const SizedBox(height: 18),
          Container(
              height: 190,
              clipBehavior: Clip.antiAlias,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(18)),
              child: Stack(fit: StackFit.expand, children: [
                Image.asset('assets/images/horizontes.png', fit: BoxFit.cover),
                const DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xDDFFFFFF), Color(0x00FFFFFF)]))),
                const Padding(
                    padding: EdgeInsets.all(22),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                            width: 205,
                            child: Text(
                                'Grandes conquistas começam com pequenos passos.',
                                style: TextStyle(
                                    fontSize: 23,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: ink)))))
              ])),
          const SizedBox(height: 20),
          SoftCard(
              color: purpleSoft,
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Seu objetivo atual',
                          style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(c.profile.targetRole,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ink)),
                      const SizedBox(height: 6),
                      const Text('Cada conquista te aproxima.',
                          style: TextStyle(color: muted, fontSize: 12))
                    ])),
                CycleProgress(value: c.compatibility())
              ])),
          const SizedBox(height: 22),
          Row(children: [
            const Expanded(
                child: Text('Sua jornada',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: ink))),
            Text('${(progress * 100).round()}%',
                style:
                    const TextStyle(color: purple, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 8),
          ProgressLine(value: progress),
          const SizedBox(height: 14),
          for (var i = 0; i < stages.length; i++)
            Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: SoftCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    onTap: () => openJourneyStage(context, stages[i].$1),
                    child: Row(children: [
                      CircleAvatar(
                          radius: 19,
                          backgroundColor: purpleSoft,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: purple, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('${i + 1}. ${stages[i].$2}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: ink)),
                            Text(stages[i].$3,
                                style:
                                    const TextStyle(fontSize: 12, color: muted))
                          ])),
                      Icon(
                          c.stageProgress(stages[i].$1) >= 1
                              ? Icons.check_circle
                              : Icons.chevron_right,
                          color: c.stageProgress(stages[i].$1) >= 1
                              ? green
                              : purple,
                          size: 20)
                    ]))),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: () => onNavigate(2),
              child: const Text('Explorar oportunidades')),
          const SizedBox(height: 16),
          const Text('Mais que vagas, novos horizontes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12))
        ]));
  }
}
