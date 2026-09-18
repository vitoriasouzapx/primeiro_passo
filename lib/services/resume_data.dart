import '../models/user_profile.dart';
import '../data/course_catalog.dart';

class ResumeData {
  final UserProfile profile;
  ResumeData(this.profile);
  String field(String key) => (profile.resume[key] ?? '').toString();
  List<String> list(String key) => List<String>.from(profile.resume[key] ?? []);
  bool hidden(String key) => (profile.resume.containsKey('hidden')
          ? list('hidden')
          : ['cpf', 'birth', 'sex'])
      .contains(key);
  static const contactLabels = {
    'email': 'E-mail Pessoal',
    'phone': 'Telefone',
    'location': 'Localidade',
    'lattes': 'Currículo Lattes',
    'linkedin': 'LinkedIn',
    'sex': 'Sexo',
    'cpf': 'CPF',
    'birth': 'Data de Nascimento'
  };
  Map<String, String> get contacts => {
        for (final e in contactLabels.entries)
          if (field(e.key).isNotEmpty && !hidden(e.key)) e.value: field(e.key)
      };
  List<String> get courses => [
        for (final course in courseCatalog
            .where((c) => profile.completedCourses.contains(c.id)))
          '${course.title}\n${course.provider}\nConcluído - Carga horária: ${course.workload}',
        ...list('courses'),
      ];
  List<String> get certificates => [
        ...profile.certificates.where((title) => !courseCatalog.any((c) =>
            profile.completedCourses.contains(c.id) && c.title == title)),
        ...list('certifications')
      ].toSet().toList();
  Map<String, List<String>> get sections => {
        'SOBRE': [
          if (profile.professionalSummary.isNotEmpty)
            profile.professionalSummary
        ],
        'OBJETIVO PROFISSIONAL': [
          if (profile.targetRole.isNotEmpty) profile.targetRole
        ],
        'FORMAÇÃO': [
          if (profile.education.isNotEmpty) profile.education,
          ...list('education')
        ],
        'EXPERIÊNCIAS': profile.resume['noExperience'] == true
            ? ['Em busca da primeira experiência profissional.']
            : [...profile.experiences, ...list('experiences')],
        'CONHECIMENTOS TÉCNICOS': {
          ...profile.skills.keys.where((s) => ![
                'Comunicação',
                'Organização',
                'Trabalho em equipe'
              ].contains(s)),
          ...list('technical')
        }.toList(),
        'COMPETÊNCIAS COMPORTAMENTAIS': {
          ...profile.skills.keys.where((s) =>
              ['Comunicação', 'Organização', 'Trabalho em equipe'].contains(s)),
          ...list('behavioral')
        }.toList(),
        'IDIOMAS': [...profile.languages, ...list('languages')],
        'CURSOS': courses,
        'CERTIFICAÇÕES': certificates,
        'MEDALHAS DIGITAIS': list('badges'),
        'INTERESSES': list('interests'),
        'PROJETOS': profile.projects,
      };
}
