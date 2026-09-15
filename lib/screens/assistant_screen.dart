import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';
import '../services/ai_service.dart';
import '../widgets/ui.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ctrl = TextEditingController();
  final List<_Message> messages = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();
    messages.add(
      const _Message(
        false,
        'Oi! Eu sou o Assistente Primeiro Passo. Posso ajudar com sua vaga-alvo, capacitação, entrevista, adaptação e questões emocionais no trabalho.',
      ),
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Future<void> send(AppController c) async {
    final q = ctrl.text.trim();
    if (q.isEmpty || busy) return;
    setState(() {
      messages.add(_Message(true, q));
      busy = true;
      ctrl.clear();
    });
    final ans = await AiService(
      backendUrl: const String.fromEnvironment('AI_BACKEND_URL'),
    ).ask(q, c.profile, c.engine.recommend(c.profile));
    if (!mounted) return;
    setState(() {
      messages.add(_Message(false, ans));
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const ScreenHeader(
            title: 'Assistente',
            subtitle: 'Converse sobre sua jornada profissional.',
            trailing: IconBadge(
              icon: Icons.auto_awesome_rounded,
              color: purple,
              background: purpleSoft,
              size: 43,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purple, Color(0xFF8A5BF1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_alt_rounded,
                    color: Color(0xFFD7F4FF),
                    size: 34,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estou usando seu perfil atual e suas prioridades para contextualizar a conversa.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.95),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                return Align(
                  alignment:
                      m.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: m.user ? purple : const Color(0xFFF5F7FC),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(m.user ? 18 : 4),
                        bottomRight: Radius.circular(m.user ? 4 : 18),
                      ),
                      border: m.user ? null : Border.all(color: line),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.user ? Colors.white : ink,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: purple,
                backgroundColor: purpleSoft,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => send(c),
                    decoration: const InputDecoration(
                      hintText: 'Conte o que está acontecendo...',
                      prefixIcon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: muted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [purple, Color(0xFF8A5BF1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: busy ? null : () => send(c),
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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

class _Message {
  final bool user;
  final String text;
  const _Message(this.user, this.text);
}
