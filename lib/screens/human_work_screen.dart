import 'package:flutter/material.dart';

import '../widgets/ui.dart';

class HumanWorkScreen extends StatelessWidget {
  const HumanWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      const _HumanModule(
        'Gestão emocional',
        'Ansiedade, medo de errar, frustração, comparação e autocontrole.',
        Icons.self_improvement_rounded,
        purple,
        purpleSoft,
        [
          'Reconhecer emoções sem agir por impulso',
          'Ansiedade em entrevistas e no primeiro dia',
          'Medo de errar e perfeccionismo',
          'Frustração e expectativas não atendidas',
          'Como receber feedback sem transformar crítica em identidade',
        ],
      ),
      const _HumanModule(
        'Crenças sobre o trabalho',
        'Questione ideias automáticas que aumentam cobrança e insegurança.',
        Icons.psychology_rounded,
        blue,
        blueSoft,
        [
          '“Preciso saber tudo antes de começar”',
          '“Se fui corrigido, estou indo mal”',
          '“Preciso agradar todo mundo”',
          '“Uma empresa boa nunca gera frustração”',
          '“Meu trabalho define meu valor como pessoa”',
        ],
      ),
      const _HumanModule(
        'Expectativas e idealizações',
        'Compare o trabalho imaginado com a experiência possível e real.',
        Icons.auto_awesome_rounded,
        orange,
        orangeSoft,
        [
          'O que espero de um chefe?',
          'O trabalho precisa me realizar o tempo inteiro?',
          'Reconhecimento: expectativa x realidade',
          'A equipe precisa ser uma “família”?',
          'Desconforto significa que escolhi a carreira errada?',
        ],
      ),
      const _HumanModule(
        'Valores e princípios',
        'Entenda o que é importante para você e o que considera inegociável.',
        Icons.diamond_outlined,
        green,
        greenSoft,
        [
          'Ética e responsabilidade',
          'Respeito e dignidade',
          'Autonomia e segurança',
          'Aprendizado e desenvolvimento',
          'Propósito, estabilidade e remuneração',
        ],
      ),
      const _HumanModule(
        'Relações humanas',
        'Comunicação, limites, confiança, diferenças e conflitos.',
        Icons.groups_2_rounded,
        pink,
        pinkSoft,
        [
          'Diferenças individuais',
          'Como verificar interpretações antes de presumir intenções',
          'Conflito não é necessariamente hostilidade',
          'Limites e disponibilidade',
          'Construção de confiança no trabalho',
        ],
      ),
      const _HumanModule(
        'Pessoa e organização',
        'Como indivíduo, equipe, cultura e organização influenciam uns aos outros.',
        Icons.hub_rounded,
        purple,
        purpleSoft,
        [
          'Cultura organizacional',
          'Clima e comportamento coletivo',
          'Compatibilidade entre valores pessoais e organizacionais',
          'Influência do ambiente interno sobre clientes e sociedade',
          'O que é adaptação saudável e o que não deve ser normalizado',
        ],
      ),
      const _HumanModule(
        'Estudos científicos',
        'Uma biblioteca introdutória de Psicologia e Comportamento Organizacional.',
        Icons.science_rounded,
        blue,
        blueSoft,
        [
          'Socialização organizacional e adaptação de novos trabalhadores',
          'Person–Organization Fit: compatibilidade pessoa-organização',
          'Contrato psicológico: expectativas não escritas',
          'Clareza de papel, autoeficácia e aceitação social',
          'Emoções, trabalho emocional e bem-estar ocupacional',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          color: Colors.white,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: ink),
                      ),
                      const Expanded(
                        child: Text(
                          'Ser Humano no Trabalho',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F269F), purple, Color(0xFF9E5BE8)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.psychology_alt_rounded,
                          color: Color(0xFFC6F1FF),
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Compreenda você dentro do trabalho',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'O trabalho envolve competências, mas também emoções, crenças, expectativas, valores, relações e percepção do ambiente.',
                          style: TextStyle(
                            color: Color(0xFFF0E8FF),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 22, 18, 10),
                  child: SectionTitle(
                    title: 'Orientação e descobertas',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: modules
                        .map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: _HumanModuleCard(module: m),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HumanModule {
  final String title, subtitle;
  final IconData icon;
  final Color color, background;
  final List<String> topics;
  const _HumanModule(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.background,
    this.topics,
  );
}

class _HumanModuleCard extends StatelessWidget {
  final _HumanModule module;
  const _HumanModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _HumanModuleDetail(module: module)),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          IconBadge(
            icon: module.icon,
            color: module.color,
            background: module.background,
            size: 50,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: muted),
        ],
      ),
    );
  }
}

class _HumanModuleDetail extends StatelessWidget {
  final _HumanModule module;
  const _HumanModuleDetail({required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          color: Colors.white,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Spacer(),
                  ],
                ),
                IconBadge(
                  icon: module.icon,
                  color: module.color,
                  background: module.background,
                  size: 58,
                ),
                const SizedBox(height: 16),
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  module.subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(
                  title: 'Conteúdos desta trilha',
                  icon: Icons.route_rounded,
                ),
                ...module.topics.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoftCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 29,
                                height: 29,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: module.background,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(
                                    color: module.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: muted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 14),
                SoftCard(
                  color: const Color(0xFFF4F1FF),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflexão guiada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: purple,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'O que neste tema descreve algo que você já viveu ou teme viver? Que evidências sustentam sua interpretação? Existe uma interpretação alternativa?',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ink,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (module.title == 'Estudos científicos') ...[
                  const SizedBox(height: 16),
                  const SoftCard(
                    color: blueSoft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Como usar esta biblioteca',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: ink,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Os conteúdos científicos devem apresentar referência, síntese em linguagem acessível, limites do estudo e ligação com uma situação prática. Eles servem para educação e reflexão, não para diagnóstico.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
