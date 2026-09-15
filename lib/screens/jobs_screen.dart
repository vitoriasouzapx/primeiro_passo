import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../widgets/ui.dart';

class JobsScreen extends StatefulWidget {
  final bool standalone;
  const JobsScreen({super.key, this.standalone = false});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String query = '';
  bool savedOnly = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final p = c.profile;
    final visibleJobs = c.availableJobs.where(
      (job) =>
          (!savedOnly || p.savedJobs.contains(job.storageKey)) &&
          ('${job.title} ${job.company} ${job.location} ${job.requirements.keys.join(' ')}')
              .toLowerCase()
              .contains(query.trim().toLowerCase()),
    );
    final content = SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScreenHeader(
            title: 'Vagas',
            subtitle: 'Oportunidades alinhadas ao seu perfil.',
            trailing: widget.standalone
                ? IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.demoJobs
                            ? 'Vagas de demonstração'
                            : 'Vagas de empresas',
                        style: const TextStyle(color: muted),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Atualizar vagas',
                      onPressed: c.jobsLoading ? null : c.refreshJobs,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                if (c.jobsLoading) const LinearProgressIndicator(),
                if (c.jobsError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      c.jobsError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: purple),
                    hintText: 'Buscar cargo ou área',
                    suffixIcon: IconButton(
                      tooltip: savedOnly
                          ? 'Mostrar todas as vagas'
                          : 'Mostrar vagas salvas',
                      onPressed: () => setState(() => savedOnly = !savedOnly),
                      icon: Icon(
                        Icons.tune_rounded,
                        color: savedOnly ? purple : muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (savedOnly)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Exibindo apenas vagas salvas',
                      style: TextStyle(color: purple),
                    ),
                  ),
                if (!c.jobsLoading &&
                    c.jobsError == null &&
                    visibleJobs.isEmpty)
                  const SoftCard(
                    child: Text(
                      'Nenhuma vaga encontrada. Altere a busca ou o filtro.',
                    ),
                  ),
                ...visibleJobs.map((job) {
                  double score = 0;
                  job.requirements.forEach(
                    (skill, req) => score += (req <= 0
                        ? 1.0
                        : ((p.skills[skill] ?? 0) / req).clamp(0, 1)),
                  );
                  score = job.requirements.isEmpty
                      ? 1
                      : score / job.requirements.length;
                  final selected = job.id.isEmpty
                      ? p.targetJobId.isEmpty && p.targetRole == job.title
                      : p.targetJobId == job.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      onTap: () => c.viewJob(job.storageKey),
                      color: selected ? const Color(0xFFFBF9FF) : Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconBadge(
                                icon: Icons.business_center_rounded,
                                color: selected ? purple : blue,
                                background: selected ? purpleSoft : blueSoft,
                                size: 48,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        job.company,
                                        job.location,
                                        job.modality,
                                      ].where((v) => v.isNotEmpty).join(' • '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: green,
                                ),
                            ],
                          ),
                          if (job.description.isNotEmpty)
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(job.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: muted))),
                          const SizedBox(height: 13),
                          if (job.requirements.isEmpty)
                            const Text(
                                'Compatibilidade indisponível: requisitos não informados.',
                                style: TextStyle(color: muted))
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: ProgressLine(
                                    value: score,
                                    color: score >= .8 ? green : purple,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${(score * 100).round()}% compatível',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: ink,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: job.requirements.keys
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: blueSoft,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF33699A),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => c.selectJob(job),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: purple,
                                    side: const BorderSide(
                                      color: Color(0xFFD9CDF7),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: Text(
                                    selected
                                        ? 'Vaga-alvo atual'
                                        : 'Definir como meta',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => c.saveJob(job.storageKey),
                                icon: Icon(
                                  p.savedJobs.contains(job.storageKey)
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: purple,
                                ),
                              ),
                              FilledButton(
                                onPressed: job.id.isNotEmpty &&
                                        job.applicationUrl == null
                                    ? null
                                    : () async {
                                        if (job.id.isNotEmpty) {
                                          try {
                                            final opened = await launchUrl(
                                              Uri.parse(job.applicationUrl!),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                            if (!opened)
                                              throw StateError(
                                                'Link não abriu',
                                              );
                                            c.addEvent(
                                              'application_link_opened',
                                              {
                                                'jobId': job.id,
                                                'role': job.title,
                                              },
                                            );
                                            await c.persist();
                                          } catch (_) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Não foi possível abrir o link de candidatura.',
                                                ),
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        p.applications.add(
                                          '${job.title} • ${DateTime.now()}',
                                        );
                                        c.addEvent('application_demo', {
                                          'role': job.title,
                                        });
                                        await c.persist();
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Simulação de candidatura registrada.',
                                            ),
                                          ),
                                        );
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: Text(
                                  job.id.isEmpty ? 'Simular' : 'Ver vaga',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
    return widget.standalone
        ? Scaffold(
            backgroundColor: bg,
            body: AppSurface(child: content),
          )
        : Material(color: Colors.white, child: content);
  }
}
