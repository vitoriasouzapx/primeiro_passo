import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/app_controller.dart';
import '../services/resume_data.dart';
import '../services/resume_pdf.dart';
import '../widgets/ui.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});
  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  AppController get c => context.read<AppController>();
  Future<void> edit(String title, Map<String, String> values,
      void Function(Map<String, String>) save) async {
    final controllers =
        values.map((k, v) => MapEntry(k, TextEditingController(text: v)));
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(title),
                content: SizedBox(
                    width: 520,
                    child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final e in controllers.entries)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TextField(
                                controller: e.value,
                                maxLines: e.key == 'Descrição' ||
                                        e.key == 'Mini Currículo'
                                    ? 4
                                    : 1,
                                maxLength: e.key == 'Descrição' ||
                                        e.key == 'Mini Currículo'
                                    ? 2000
                                    : 250,
                                decoration: InputDecoration(labelText: e.key))),
                    ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Desistir')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Salvar'))
                ]));
    if (accepted == true && mounted) {
      save(controllers.map((k, v) => MapEntry(k, v.text.trim())));
      try {
        await c.persist();
      } catch (_) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Não foi possível salvar. Tente novamente.')));
      }
    }
    // Dialog finishes its closing animation before disposing its fields.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Widget card(String title, Widget body, {VoidCallback? add}) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: purpleDark))),
          if (add != null)
            IconButton.filled(
                onPressed: add,
                tooltip: 'Adicionar $title',
                icon: const Icon(Icons.add))
        ]),
        const SizedBox(height: 12),
        body,
      ])));
  Widget entries(String title, String key,
      {List<String> automatic = const [], bool detailed = false}) {
    final list = ResumeData(c.profile).list(key);
    void change([int? index]) {
      final old = index == null ? '' : list[index];
      final labels = switch (key) {
        'education' => [
            'Curso / nível de formação',
            'Instituição',
            'Início e término previsto',
            'Situação'
          ],
        'courses' => [
            'Nome do curso',
            'Instituição',
            'Período',
            'Situação e carga horária'
          ],
        'experiences' => ['Cargo', 'Organização', 'Período', 'Descrição'],
        'certifications' || 'badges' => [
            'Título',
            'Instituição emissora',
            'Data de emissão',
            'Descrição'
          ],
        'languages' => ['Idioma', 'Nível'],
        _ => ['Descrição'],
      };
      final lines = old.split('\n');
      edit(index == null ? 'Adicionar $title' : 'Editar $title', {
        for (var j = 0; j < labels.length; j++)
          labels[j]: j < lines.length
              ? (j == labels.length - 1
                  ? lines.sublist(j).join('\n')
                  : lines[j])
              : ''
      }, (v) {
        final value = v.values.join('\n');
        if (value.trim().isEmpty) return;
        if (index == null) {
          list.add(value);
        } else {
          list[index] = value;
        }
        c.profile.resume[key] = list;
      });
    }

    return card(
        title,
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (automatic.isEmpty && list.isEmpty)
            const Text('Nenhuma informação cadastrada. Use + para incluir.',
                style: TextStyle(color: muted)),
          for (final item in automatic)
            ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item),
                subtitle: const Text('Atualizado pela jornada',
                    style: TextStyle(fontSize: 11, color: muted)),
                leading: const Icon(Icons.sync, color: purple)),
          for (var i = 0; i < list.length; i++)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(list[i]))),
              IconButton(
                  tooltip: 'Editar $title',
                  onPressed: () => change(i),
                  icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  tooltip: 'Excluir $title',
                  onPressed: () async {
                    final removed = list.removeAt(i);
                    c.profile.resume[key] = list;
                    await c.persist();
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Informação removida'),
                          action: SnackBarAction(
                              label: 'Desfazer',
                              onPressed: () {
                                list.add(removed);
                                c.profile.resume[key] = list;
                                c.persist();
                              })));
                  },
                  icon: const Icon(Icons.delete_outline))
            ]),
        ]),
        add: () => change());
  }

  Future<void> exportOptions() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ResumeExportScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppController>().profile;
    final data = ResumeData(p);
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
              title: const Text('Meu currículo'),
              leading: IconButton(
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
              actions: [
                IconButton(
                    tooltip: 'Visualizar e baixar PDF',
                    onPressed: exportOptions,
                    icon: const Icon(Icons.picture_as_pdf_outlined))
              ],
              bottom: const TabBar(isScrollable: true, tabs: [
                Tab(text: 'Sobre'),
                Tab(text: 'Competências'),
                Tab(text: 'Formação'),
                Tab(text: 'Experiências')
              ])),
          body: _ResumeSurface(
              child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: SoftCard(
                    color: purpleSoft,
                    child: Row(children: [
                      const CircleAvatar(child: Icon(Icons.person_outline)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            if (data.field('email').isNotEmpty)
                              Text(data.field('email')),
                            const Text('Atualizado com sua jornada',
                                style: TextStyle(fontSize: 12, color: muted))
                          ]))
                    ]))),
            Expanded(
                child: TabBarView(children: [
              ListView(padding: const EdgeInsets.all(16), children: [
                card(
                    'Dados Pessoais',
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                              'Nome: ${p.name}\nAtividade Atual: ${p.currentRole}\nProfissão: ${data.field('profession')}',
                              style: const TextStyle(height: 1.8)),
                          for (final e in ResumeData.contactLabels.entries)
                            if (data.field(e.key).isNotEmpty)
                              Text('${e.value}: ${data.field(e.key)}',
                                  style: const TextStyle(height: 1.8)),
                          OutlinedButton.icon(
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar dados pessoais'),
                              onPressed: () => edit('Dados Pessoais', {
                                    'Nome': p.name,
                                    'Atividade Atual': p.currentRole,
                                    'Profissão': data.field('profession'),
                                    for (final e
                                        in ResumeData.contactLabels.entries)
                                      e.value: data.field(e.key)
                                  }, (v) {
                                    p.name = v['Nome']!;
                                    p.currentRole = v['Atividade Atual']!;
                                    p.resume['profession'] = v['Profissão'];
                                    for (final e in ResumeData.contactLabels
                                        .entries) p.resume[e.key] = v[e.value];
                                  })),
                        ])),
                card(
                    'Mini Currículo',
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.professionalSummary.isEmpty
                              ? 'Conte um pouco sobre sua trajetória.'
                              : p.professionalSummary),
                          TextButton.icon(
                              onPressed: () => edit(
                                  'Mini Currículo',
                                  {'Mini Currículo': p.professionalSummary},
                                  (v) => p.professionalSummary =
                                      v['Mini Currículo']!),
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'))
                        ])),
                card('Objetivo profissional', Text(p.targetRole)),
                entries('Interesses', 'interests'),
              ]),
              ListView(padding: const EdgeInsets.all(16), children: [
                entries('Conhecimentos técnicos', 'technical',
                    automatic: data.sections['CONHECIMENTOS TÉCNICOS']!
                        .where((e) => !data.list('technical').contains(e))
                        .toList()),
                entries('Competências Comportamentais', 'behavioral',
                    automatic: data.sections['COMPETÊNCIAS COMPORTAMENTAIS']!
                        .where((e) => !data.list('behavioral').contains(e))
                        .toList()),
                entries('Idiomas', 'languages', automatic: p.languages)
              ]),
              ListView(padding: const EdgeInsets.all(16), children: [
                if (p.education.isNotEmpty)
                  card(
                      'Formação registrada',
                      Column(children: [
                        Text(p.education),
                        TextButton(
                            onPressed: () => edit(
                                'Formação',
                                {'Descrição': p.education},
                                (v) => p.education = v['Descrição']!),
                            child: const Text('Editar'))
                      ])),
                entries('Acadêmica', 'education'),
                entries('Certificações', 'certifications',
                    automatic: data.certificates
                        .where((e) => !data.list('certifications').contains(e))
                        .toList()),
                entries('Medalhas Digitais', 'badges'),
                entries('Outros Cursos', 'courses',
                    automatic: data.courses
                        .where((e) => !data.list('courses').contains(e))
                        .toList()),
              ]),
              ListView(padding: const EdgeInsets.all(16), children: [
                SwitchListTile(
                    title: const Text('Sem experiência profissional'),
                    subtitle: const Text(
                        'Marque se está em busca da primeira experiência.'),
                    value: p.resume['noExperience'] == true,
                    onChanged: (v) {
                      p.resume['noExperience'] = v;
                      c.persist();
                    }),
                if (p.resume['noExperience'] != true)
                  entries('Experiências', 'experiences',
                      automatic: p.experiences)
              ]),
            ])),
            SafeArea(
                top: false,
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.undo),
                              label: const Text('Voltar')),
                          FilledButton.icon(
                              onPressed: exportOptions,
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('Visualizar currículo'))
                        ]))),
          ])),
        ));
  }
}

class ResumeExportScreen extends StatefulWidget {
  const ResumeExportScreen({super.key});
  @override
  State<ResumeExportScreen> createState() => _ResumeExportScreenState();
}

class _ResumeExportScreenState extends State<ResumeExportScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final data = ResumeData(c.profile);
    return Scaffold(
        appBar: AppBar(title: const Text('Preparar currículo')),
        body: _ResumeSurface(
            child: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Escolha o que aparece no PDF',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'As opções também se aplicam à prévia. Campos vazios não aparecem no documento.'),
          for (final e in ResumeData.contactLabels.entries)
            SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(e.value),
                subtitle: Text(data.field(e.key).isEmpty
                    ? 'Não informado'
                    : data.field(e.key)),
                secondary: const Icon(Icons.visibility_off_outlined),
                value: data.hidden(e.key),
                onChanged: (v) {
                  final hidden =
                      ResumeData.contactLabels.keys.where(data.hidden).toSet();
                  v ? hidden.add(e.key) : hidden.remove(e.key);
                  c.profile.resume['hidden'] = hidden.toList();
                  c.persist();
                }),
          const Text('Ative uma opção para ocultar esse dado no PDF.',
              style: TextStyle(color: muted)),
          const SizedBox(height: 20),
          FilledButton.icon(
              onPressed: () async {
                await c.persist();
                if (!context.mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ResumePreviewScreen(data: ResumeData(c.profile))));
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Visualizar antes de baixar')),
          OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.undo),
              label: const Text('Voltar')),
        ])));
  }
}

class ResumePreviewScreen extends StatefulWidget {
  final ResumeData data;
  const ResumePreviewScreen({super.key, required this.data});
  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  late final document = buildResumePdf(widget.data);
  bool busy = false;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Prévia do currículo')),
      body: Column(children: [
        Expanded(
            child: PdfPreview(
                build: (_) => document,
                initialPageFormat: PdfPageFormat.a4,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                useActions: false,
                maxPageWidth: 800,
                onError: (_, error) => const Center(
                    child: Text(
                        'Não foi possível abrir a prévia. Volte e tente novamente.')))),
        SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(spacing: 12, runSpacing: 8, children: [
                  OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.undo),
                      label: const Text('Voltar')),
                  FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () async {
                              setState(() => busy = true);
                              try {
                                await Printing.sharePdf(
                                    bytes: await document,
                                    filename: 'meu_curriculo.pdf');
                              } catch (_) {
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Não foi possível baixar o PDF. Tente novamente.')));
                              } finally {
                                if (mounted) setState(() => busy = false);
                              }
                            },
                      icon: const Icon(Icons.download),
                      label:
                          Text(busy ? 'Preparando...' : 'Baixar arquivo PDF'))
                ])))
      ]));
}

class _ResumeSurface extends StatelessWidget { final Widget child; const _ResumeSurface({required this.child}); @override Widget build(BuildContext context) => AppSurface(child: Material(color: Colors.white, child: child)); }
