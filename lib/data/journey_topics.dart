class JourneyTopic {
  final String id, title, subtitle, outcome, reflectionLabel, reflectionHint;
  final String planLabel, planHint;
  final List<(String, String)> sections;
  final List<String> activities;
  const JourneyTopic(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.outcome,
      required this.sections,
      required this.activities,
      required this.reflectionLabel,
      required this.reflectionHint,
      required this.planLabel,
      required this.planHint});
}

const discoveryTopic = JourneyTopic(
  id: 'discovery',
  title: 'Descoberta',
  subtitle: 'Conheça seus interesses e escolha uma direção profissional.',
  outcome:
      'Ao final: uma área para explorar e exemplos do que você já sabe fazer.',
  sections: [
    (
      'Interesses e rotina de trabalho',
      'Pense nas tarefas que despertam sua curiosidade: organizar informações, atender pessoas, resolver problemas ou produzir algo. Depois imagine a rotina: trabalho em equipe, contato com público, horários e deslocamento. Um cargo pode parecer interessante e ter uma rotina que não combina com você.'
    ),
    (
      'Reconheça suas experiências',
      'Use exemplos da escola, de projetos, de trabalho informal ou de atividades voluntárias. Para cada exemplo, escreva o que fez e qual foi o resultado. Organizar um evento pode demonstrar planejamento; explicar uma matéria a alguém pode demonstrar comunicação. Separe aquilo que já consegue fazer do que ainda precisa aprender.'
    ),
    (
      'Compare caminhos antes de escolher',
      'Compare duas áreas por atividades diárias, requisitos de entrada e possibilidades de aprendizagem. Leia descrições de vagas para entender o trabalho, não apenas o título. Converse com alguém da área e escolha uma hipótese para explorar. Sua primeira escolha pode ser revista.'
    ),
  ],
  activities: [
    'Listei atividades que me interessam',
    'Registrei exemplos das minhas competências',
    'Comparei duas possibilidades profissionais'
  ],
  reflectionLabel: 'Meu mapa de interesses',
  reflectionHint:
      'Quais tarefas me interessam? Que experiências mostram minhas competências? Como quero que seja minha rotina?',
  planLabel: 'Área que vou explorar',
  planHint:
      'Compare duas áreas. Escolha uma e escreva qual informação ainda precisa buscar antes de decidir.',
);

const searchTopic = JourneyTopic(
  id: 'search',
  title: 'Busca e seleção',
  subtitle:
      'Organize candidaturas e prepare-se para conversar com recrutadores.',
  outcome:
      'Ao final: uma rotina de busca e exemplos preparados para entrevistas.',
  sections: [
    (
      'Faça uma busca com critérios',
      'Parta do seu cargo-alvo e filtre oportunidades por localização, modalidade e requisitos essenciais. Leia as atividades e confira a origem do anúncio e o canal oficial de candidatura. Priorize oportunidades coerentes com seu momento; quantidade de envios não substitui uma candidatura bem preparada.'
    ),
    (
      'Acompanhe cada processo',
      'Anote empresa, cargo, endereço da vaga, data de envio e situação: preparando, enviada, entrevista ou encerrada. Ajuste o currículo com experiências verdadeiras relevantes para a oportunidade. Abrir o link de uma vaga não significa ter enviado uma candidatura: conclua o processo no canal indicado pela empresa.'
    ),
    (
      'Prepare exemplos para a entrevista',
      'Escolha três experiências e organize cada uma em situação, tarefa, ação e resultado. Explique sua contribuição com clareza e sem inventar resultados. Prepare perguntas sobre rotina, equipe e expectativas. Antes da conversa, confira horário, endereço ou link e os recursos necessários.'
    ),
  ],
  activities: [
    'Defini critérios e uma rotina de busca',
    'Organizei o acompanhamento das candidaturas',
    'Preparei três exemplos e perguntas para a entrevista'
  ],
  reflectionLabel: 'Minha organização da busca',
  reflectionHint:
      'Quais critérios vou usar? Em quais dias vou buscar? Quais processos e retornos preciso acompanhar?',
  planLabel: 'Meu roteiro de entrevista',
  planHint:
      'Descreva situação, tarefa, ação e resultado de uma experiência. Acrescente as perguntas que quer fazer à empresa.',
);

const entryTopic = JourneyTopic(
  id: 'entry',
  title: 'Entrada e adaptação',
  subtitle: 'Prepare os primeiros dias e alinhe sua atuação na nova equipe.',
  outcome:
      'Ao final: um plano para os primeiros 30 dias e uma lista de alinhamentos.',
  sections: [
    (
      'Antes do primeiro dia',
      'Confirme horário, local ou acesso remoto, pessoa de contato e orientações recebidas. Prepare seu deslocamento e os itens solicitados. Se ainda não começou a trabalhar, use esta etapa para se preparar e deixe as atividades de integração para quando houver uma contratação.'
    ),
    (
      'Primeira semana: entenda o trabalho',
      'Descubra quem orienta suas tarefas, quais são as prioridades e onde estão os procedimentos. Peça exemplos de uma entrega bem feita. Anote dúvidas e confirme prazos, canais de comunicação e permissões de acesso. Conheça as orientações de segurança da organização antes de executar atividades novas.'
    ),
    (
      'Primeiros 30 dias: alinhe expectativas',
      'Combine pequenas entregas com a liderança e registre o que aprendeu. Reserve uma conversa para perguntar o que está funcionando e o que precisa ajustar. Transforme o retorno em uma ação específica e combine quando revisar. Não presuma autonomia para uma tarefa que ainda não foi orientada.'
    ),
  ],
  activities: [
    'Confirmei as orientações para o primeiro dia',
    'Identifiquei meu apoio e as prioridades da primeira semana',
    'Combinei entregas e uma conversa de acompanhamento'
  ],
  reflectionLabel: 'Pessoas e combinados importantes',
  reflectionHint:
      'Quem pode me orientar? Quais são os canais, procedimentos e prioridades? Quais dúvidas vou esclarecer?',
  planLabel: 'Meu plano dos primeiros 30 dias',
  planHint:
      'Liste uma entrega inicial, o prazo combinado, o apoio necessário e quando pretende pedir feedback.',
);

const developmentTopic = JourneyTopic(
  id: 'development',
  title: 'Desenvolvimento',
  subtitle: 'Transforme sua experiência em evolução profissional contínua.',
  outcome:
      'Ao final: um objetivo de desenvolvimento e uma experiência prática para realizá-lo.',
  sections: [
    (
      'Observe sua atuação atual',
      'Reúna entregas, dificuldades recorrentes e retornos recebidos. Procure padrões: o que já faz com consistência e o que limita seus resultados? Escolha uma prioridade concreta ligada ao trabalho que realiza ou ao caminho profissional que pretende seguir.'
    ),
    (
      'Monte um plano de 90 dias',
      'Defina uma competência e uma situação em que irá praticá-la. Escolha uma evidência observável de avanço, um prazo e alguém que possa oferecer retorno. Exemplo: preparar um relatório semanal, revisar os erros com uma pessoa experiente e comparar a qualidade das próximas entregas.'
    ),
    (
      'Construa evidências e revise a direção',
      'Registre projetos, sua contribuição e aprendizados sem incluir informações confidenciais da empresa. Busque feedback durante a execução, não só ao final. Ao revisar o plano, decida se deve aprofundar a competência, ampliar responsabilidades ou explorar outra função. Cursos podem apoiar o plano, mas a prática e os resultados também fazem parte dele.'
    ),
  ],
  activities: [
    'Escolhi uma competência a partir da minha experiência',
    'Defini uma prática, uma evidência e um prazo',
    'Combinei como vou revisar meu plano e receber feedback'
  ],
  reflectionLabel: 'Minha prioridade de desenvolvimento',
  reflectionHint:
      'Que retorno recebi? Qual competência quero desenvolver e por que ela importa para meu trabalho?',
  planLabel: 'Meu plano de 90 dias',
  planHint:
      'Objetivo, projeto ou prática, evidência de avanço, pessoa de apoio e data de revisão.',
);
