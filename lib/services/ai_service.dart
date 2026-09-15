import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import 'recommendation_engine.dart';

class AiService {
  final String? backendUrl;
  AiService({this.backendUrl});

  Future<String> ask(
    String message,
    UserProfile p,
    List<Recommendation> recs,
  ) async {
    if (backendUrl == null || backendUrl!.isEmpty)
      return _local(message, p, recs);
    try {
      final res = await http
          .post(
            Uri.parse('$backendUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message, 'profile': p.toMap()}),
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) return jsonDecode(res.body)['answer'];
    } catch (_) {}
    return _local(message, p, recs);
  }

  String _local(String m, UserProfile p, List<Recommendation> recs) {
    final t = m.toLowerCase();
    if (t.contains('entrevista') || t.contains('nervos'))
      return 'Sua fase atual é ${p.journeyStage}. Para entrevista, organize 3 exemplos reais de situações que mostrem suas competências, revise a vaga e faça uma preparação breve de regulação emocional. ${recs.isNotEmpty ? 'Prioridade atual: ${recs.first.title}.' : ''}';
    if (t.contains('curso') || t.contains('estudar'))
      return recs
          .where((r) => r.title.startsWith('Desenvolver'))
          .map((r) => r.action)
          .take(3)
          .join('\n');
    if (t.contains('medo') || t.contains('errar'))
      return 'Errar durante aprendizagem não significa incapacidade. Registre o que aconteceu, o impacto, o que você aprendeu e qual ação concreta reduz a chance de repetição. Se houver risco ou dúvida relevante, procure orientação do responsável.';
    return 'Com base no seu objetivo (${p.targetRole}) e na sua fase (${p.journeyStage}), sua próxima prioridade é: ${recs.isNotEmpty ? recs.first.action : 'continuar explorando sua jornada profissional'}.';
  }
}
