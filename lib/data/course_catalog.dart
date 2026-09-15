class CourseItem {
  final String id;
  final String title;
  final String provider;
  final String skill;
  final String workload;
  final String url;
  final String description;
  const CourseItem({
    required this.id,
    required this.title,
    required this.provider,
    required this.skill,
    required this.workload,
    required this.url,
    required this.description,
  });
}

// Catálogo inicial demonstrativo. Em produção, substitua/complete por feeds ou APIs autorizadas.
const courseCatalog = <CourseItem>[
  CourseItem(
    id: 'evg-sei',
    title: 'SEI! USAR 4.0',
    provider: 'Escola Virtual.Gov',
    skill: 'Organização',
    workload: '25h',
    url: 'https://www.escolavirtual.gov.br/catalogo',
    description: 'Processos, documentos, blocos e busca no SEI.',
  ),
  CourseItem(
    id: 'evg-dados',
    title: 'Análise de dados como suporte à tomada de decisão',
    provider: 'Escola Virtual.Gov',
    skill: 'Excel',
    workload: '30h',
    url: 'https://www.escolavirtual.gov.br/catalogo',
    description: 'Fundamentos de dados, análise descritiva e painéis.',
  ),
  CourseItem(
    id: 'evg-etica',
    title: 'Ética e Serviço Público',
    provider: 'Escola Virtual.Gov',
    skill: 'Comunicação',
    workload: '20h',
    url: 'https://www.escolavirtual.gov.br/catalogo',
    description: 'Ética, integridade e atuação profissional responsável.',
  ),
  CourseItem(
    id: 'fb-produtividade',
    title: 'Cursos de Produtividade',
    provider: 'Fundação Bradesco • Escola Virtual',
    skill: 'Excel',
    workload: 'varia',
    url: 'https://www.ev.org.br/cursos',
    description:
        'Catálogo gratuito e on-line com opções de produtividade e ferramentas digitais.',
  ),
  CourseItem(
    id: 'fb-desenvolvimento',
    title: 'Desenvolvimento Pessoal e Profissional',
    provider: 'Fundação Bradesco • Escola Virtual',
    skill: 'Comunicação',
    workload: 'varia',
    url: 'https://www.ev.org.br/cursos',
    description:
        'Cursos para competências profissionais e desenvolvimento pessoal.',
  ),
  CourseItem(
    id: 'senai-online',
    title: 'Cursos on-line SENAI',
    provider: 'SENAI',
    skill: 'Organização',
    workload: 'varia',
    url: 'https://www.senai.br/cursos',
    description:
        'Portal institucional para localizar capacitações e formações profissionais.',
  ),
  CourseItem(
    id: 'senac-online',
    title: 'Cursos SENAC',
    provider: 'SENAC',
    skill: 'Atendimento',
    workload: 'varia',
    url: 'https://www.senac.br/',
    description:
        'Portal institucional para localizar cursos de comércio, serviços e outras áreas.',
  ),
];
