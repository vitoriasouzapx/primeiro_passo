import '../models/user_profile.dart';
import '../data/catalog.dart';

class Recommendation {
  final String title, reason, action;
  final int priority;
  Recommendation(this.title, this.reason, this.action, this.priority);
}

class RecommendationEngine {
  String stage(UserProfile u) {
    if (u.hired) return 'Entrada e adaptação';
    if (u.interviews.isNotEmpty) return 'Processo seletivo';
    if (u.applications.isNotEmpty) return 'Busca de vagas';
    if (skillGaps(u).isNotEmpty) return 'Capacitação';
    return 'Descoberta';
  }

  Map<String, double> requirements(UserProfile u) => u.targetJobId.isNotEmpty
      ? u.targetRequirements
      : jobs
          .firstWhere(
            (j) => j.title == u.targetRole,
            orElse: () => jobs.first,
          )
          .requirements;
  Map<String, double> skillGaps(UserProfile u) {
    final gaps = <String, double>{};
    requirements(u).forEach((k, req) {
      final have = u.skills[k] ?? 0;
      if (have < req) gaps[k] = req - have;
    });
    return gaps;
  }

  double compatibility(UserProfile u) {
    final req = requirements(u);
    if (req.isEmpty) return u.targetJobId.isEmpty ? 1 : 0;
    double score = 0;
    req.forEach((k, v) =>
        score += (v <= 0 ? 1.0 : ((u.skills[k] ?? 0) / v).clamp(0, 1)));
    return score / req.length;
  }

  List<Recommendation> recommend(UserProfile u) {
    final r = <Recommendation>[];
    if (skillGaps(u).isNotEmpty)
      r.add(
        Recommendation(
          'Capacitação recomendada',
          'Há competências abaixo do nível da vaga-alvo.',
          'Ver cursos compatíveis com suas lacunas.',
          95,
        ),
      );
    if (u.professionalSummary.isEmpty)
      r.add(
        Recommendation(
          'Atualizar currículo',
          'Seu currículo inteligente ainda está incompleto.',
          'Gerar currículo a partir do perfil e cursos.',
          90,
        ),
      );
    if (u.applications.isEmpty && compatibility(u) >= .8)
      r.add(
        Recommendation(
          'Começar candidaturas',
          'Seu perfil está próximo dos requisitos.',
          'Ver vagas compatíveis.',
          88,
        ),
      );
    if (u.interviews.isNotEmpty)
      r.add(
        Recommendation(
          'Preparar entrevista',
          'Você está em processo seletivo.',
          'Usar o assistente para simular entrevista.',
          100,
        ),
      );
    if (u.hired)
      r.add(
        Recommendation(
          'Acompanhar adaptação',
          'Contratação registrada.',
          'Priorizar integração, feedback e desenvolvimento.',
          100,
        ),
      );
    return r;
  }
}
