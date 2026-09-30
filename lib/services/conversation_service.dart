import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discovery.dart';

class ConversationReply {
  final String answer;
  final List<ProfileSuggestion> suggestions;
  const ConversationReply(this.answer, this.suggestions);
}

class ConversationService {
  final String baseUrl;
  final http.Client? client;
  const ConversationService(
      {this.baseUrl = const String.fromEnvironment('AI_BACKEND_URL'),
      this.client});
  bool get configured => baseUrl.isNotEmpty;
  Future<ConversationReply> send(String message, List<ChatMessage> history,
      Map<String, dynamic> discovery, String? token) async {
    if (!configured)
      throw StateError(
          'A conversa com IA ainda não foi ativada. Você pode organizar seu mapa abaixo.');
    if (token == null)
      throw StateError('Entre na sua conta para conversar com a IA.');
    final uri = Uri.parse(baseUrl);
    if (uri.scheme != 'https' &&
        !(uri.scheme == 'http' &&
            ['localhost', '127.0.0.1'].contains(uri.host))) {
      throw StateError('O assistente precisa de uma conexão segura.');
    }
    final recent = <Map<String, String>>[];
    var length = jsonEncode(discovery).length + message.length;
    for (final m in history.reversed.take(24)) {
      if (length + m.content.length > 28000) break;
      recent.insert(0, {'role': m.role, 'content': m.content});
      length += m.content.length;
    }
    final transport = client ?? http.Client();
    try {
      final response = await transport
          .post(Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'
              },
              body: jsonEncode({
                'message': message,
                'history': recent,
                'discovery': discovery
              }))
          .timeout(const Duration(seconds: 55));
      if (response.statusCode != 200) {
        throw StateError(switch (response.statusCode) {
          401 => 'Sua sessão expirou. Entre novamente.',
          429 => 'Limite de conversas atingido. Tente mais tarde.',
          503 => 'O assistente ainda não foi ativado.',
          _ =>
            'Não foi possível responder agora. Sua mensagem continua disponível para tentar novamente.',
        });
      }
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final answer = data['answer'] as String;
      if (answer.trim().isEmpty || answer.length > 6000)
        throw const FormatException();
      return ConversationReply(
          answer,
          (data['suggestions'] as List)
              .take(5)
              .map((x) =>
                  ProfileSuggestion.fromMap(Map<String, dynamic>.from(x)))
              .toList());
    } finally {
      if (client == null) transport.close();
    }
  }
}
