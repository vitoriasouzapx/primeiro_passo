import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discovery.dart';
import '../services/app_controller.dart';
import '../services/conversation_service.dart';
import '../widgets/ui.dart';
import '../data/journey_topics.dart';
import 'journey_topic_screen.dart';
import 'login_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  final ConversationService service;
  const DiscoveryScreen(
      {super.key, this.service = const ConversationService()});
  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || busy) return;
    final c = context.read<AppController>();
    final owner = c.local.userId;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final reply = await widget.service.send(text, c.profile.conversation,
          c.discoveryContext, await c.cloud?.token());
      if (owner != c.local.userId) {
        throw StateError('A conta mudou. Envie sua mensagem novamente.');
      }
      await c.saveConversation([
        ...c.profile.conversation,
        ChatMessage('user', text),
        ChatMessage('assistant', reply.answer, reply.suggestions)
      ]);
      if (mounted) input.clear();
    } catch (e) {
      if (mounted)
        setState(() => error = e is StateError
            ? e.message.toString()
            : 'Não foi possível concluir. Tente novamente.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> editMemory(String field, {String? old}) async {
    final text = TextEditingController(text: old ?? '');
    final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(discoveryLabels[field]!),
                content: TextField(
                    controller: text,
                    autofocus: true,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Escreva com suas palavras')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () {
                        if (text.text.trim().isNotEmpty)
                          Navigator.pop(ctx, text.text.trim());
                      },
                      child: const Text('Salvar'))
                ]));
    Future<void>.delayed(const Duration(seconds: 1), text.dispose);
    if (result == null || !mounted) return;
    final c = context.read<AppController>();
    await mutate(() async {
      await c.confirmSuggestion(
          ProfileSuggestion(field, result, 'Informado por você'),
          replacing: old);
    });
  }

  Future<void> mutate(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted)
        setState(() => error =
            'Não foi possível salvar. Confira o limite de 20 itens por categoria e tente novamente.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> clearHistory() async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Apagar histórico da conversa?'),
                content: const Text(
                    'As mensagens e sugestões pendentes serão removidas. Seu mapa confirmado permanece; você pode editar ou remover cada item abaixo.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Apagar'))
                ]));
    if (yes == true && mounted)
      await mutate(() => context.read<AppController>().saveConversation([]));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Descoberta'), actions: [
          IconButton(
              tooltip: 'Apagar histórico',
              onPressed: busy ? null : clearHistory,
              icon: const Icon(Icons.delete_outline))
        ]),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text('Seu próximo passo começa com uma conversa.',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                          'Conte o que você quiser: ideias, experiências ou dúvidas. Você pode mudar de direção a qualquer momento.'),
                      const SizedBox(height: 16),
                      if (!widget.service.configured)
                        const SoftCard(
                            color: blueSoft,
                            child: Text(
                                'A IA ainda não está conectada. Seu mapa já pode ser preenchido e usado nas trilhas. Nenhuma resposta simulada será apresentada como conversa real.')),
                      if (widget.service.configured &&
                          c.cloud?.signedIn != true)
                        OutlinedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen())),
                            child: const Text('Entrar para conversar')),
                      if (c.syncError != null)
                        Text(c.syncError!,
                            style: const TextStyle(color: Colors.deepOrange)),
                      const SizedBox(height: 12),
                      if (c.cloud?.signedIn == true)
                        TextButton(
                            onPressed:
                                busy ? null : () => mutate(c.leaveAccount),
                            child: const Text('Sair da conta')),
                      for (final m in c.profile.conversation) ...[
                        Align(
                            alignment: m.role == 'user'
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                constraints:
                                    const BoxConstraints(maxWidth: 650),
                                decoration: BoxDecoration(
                                    color: m.role == 'user'
                                        ? purpleSoft
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          m.role == 'user'
                                              ? 'Você'
                                              : 'Assistente de IA',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      SelectableText(m.content),
                                    ]))),
                        for (final s in m.suggestions)
                          SoftCard(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Sugestão • ${discoveryLabels[s.field]}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(s.value),
                                Text(s.reason,
                                    style: const TextStyle(color: muted)),
                                Wrap(spacing: 8, children: [
                                  TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => mutate(
                                              () => c.confirmSuggestion(s)),
                                      child:
                                          const Text('Confirmar no meu mapa')),
                                  TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => mutate(() async {
                                                c.dismissSuggestion(s);
                                                await c.persist();
                                              }),
                                      child: const Text('Descartar')),
                                ])
                              ])),
                      ],
                      if (busy) const LinearProgressIndicator(),
                      if (error != null)
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(error!,
                                style:
                                    const TextStyle(color: Colors.deepOrange))),
                      TextField(
                          controller: input,
                          enabled: !busy,
                          minLines: 2,
                          maxLines: 8,
                          maxLength: 4000,
                          decoration: const InputDecoration(
                              hintText:
                                  'Escreva como se estivesse conversando...')),
                      Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                              onPressed: busy || !widget.service.configured
                                  ? null
                                  : send,
                              icon: const Icon(Icons.send_outlined),
                              label: Text(busy ? 'Conversando…' : 'Enviar'))),
                      const SizedBox(height: 10),
                      const Text(
                          'Ao enviar, sua mensagem, o contexto recente e o mapa profissional são processados pela OpenAI. Não envie documentos ou dados íntimos. A conversa é salva na sua conta quando conectada. Você pode apagar o histórico.',
                          style: TextStyle(fontSize: 12, color: muted)),
                      const SizedBox(height: 24),
                      const Text('O que o Primeiro Passo sabe sobre mim',
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold)),
                      const Text(
                          'Apenas itens confirmados orientam as trilhas. Interesses não são notas de competência. O histórico é limitado; este mapa preserva o que importa.'),
                      for (final field in discoveryLabels.keys) ...[
                        const SizedBox(height: 12),
                        SoftCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(discoveryLabels[field]!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              for (final value in field == 'targetRole'
                                  ? (c.profile.discoveryGoalConfirmed
                                      ? [c.profile.targetRole]
                                      : <String>[])
                                  : (c.profile.discovery[field] ?? <String>[]))
                                Row(children: [
                                  Expanded(child: Text(value)),
                                  IconButton(
                                      tooltip: 'Editar',
                                      onPressed: busy
                                          ? null
                                          : () => editMemory(field, old: value),
                                      icon: const Icon(Icons.edit_outlined)),
                                  IconButton(
                                      tooltip: 'Remover',
                                      onPressed: busy
                                          ? null
                                          : () => mutate(() =>
                                              c.removeMemory(field, value)),
                                      icon: const Icon(Icons.close))
                                ]),
                              TextButton.icon(
                                  onPressed:
                                      busy ? null : () => editMemory(field),
                                  icon: const Icon(Icons.add),
                                  label: Text(field == 'targetRole'
                                      ? 'Escolher objetivo'
                                      : 'Adicionar')),
                            ])),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const JourneyTopicScreen(
                                      topic: discoveryTopic))),
                          child:
                              const Text('Explorar atividades de Descoberta')),
                    ]))));
  }
}
