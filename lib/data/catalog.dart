class JobItem {
  final String title;
  final Map<String, double> requirements;
  final String id, company, location, modality, description;
  final String? applicationUrl;
  const JobItem(
    this.title,
    this.requirements, {
    this.id = '',
    this.company = 'Demonstração',
    this.location = '',
    this.modality = '',
    this.description = '',
    this.applicationUrl,
  });
  String get storageKey => id.isEmpty ? title : 'api:$id';
  factory JobItem.fromMap(Map<String, dynamic> m) {
    String requiredText(String key) {
      final value = m[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Campo inválido: $key');
      }
      return value.trim();
    }

    final requirements = <String, double>{};
    final raw = m['requirements'] ?? <String, dynamic>{};
    if (raw is! Map) throw const FormatException('Requisitos inválidos.');
    for (final entry in raw.entries) {
      final value = entry.value;
      if (entry.key is! String ||
          value is! num ||
          !value.isFinite ||
          value < 0 ||
          value > 1) {
        throw const FormatException('Competência fora do intervalo 0 a 1.');
      }
      requirements[entry.key as String] = value.toDouble();
    }
    final url = m['application_url'] as String?;
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty) {
        throw const FormatException('Link de candidatura inválido.');
      }
    }
    return JobItem(
      requiredText('title'),
      requirements,
      id: requiredText('id'),
      company: requiredText('company'),
      location: m['location'] as String? ?? '',
      modality: m['modality'] as String? ?? '',
      description: m['description'] as String? ?? '',
      applicationUrl: url,
    );
  }
}

const jobs = [
  JobItem('Assistente Administrativo', {
    'Excel': .65,
    'Comunicação': .65,
    'Organização': .75,
    'Atendimento': .55,
  }),
  JobItem('Auxiliar de RH', {
    'Excel': .55,
    'Comunicação': .75,
    'Organização': .70,
    'Atendimento': .60,
  }),
  JobItem('Atendente', {
    'Comunicação': .80,
    'Atendimento': .80,
    'Organização': .55,
  }),
];

const courseForSkill = {
  'Excel': 'Excel Essencial',
  'Comunicação': 'Comunicação Profissional',
  'Organização': 'Organização e Gestão do Tempo',
  'Atendimento': 'Atendimento ao Cliente',
};
