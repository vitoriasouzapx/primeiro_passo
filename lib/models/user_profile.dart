import 'discovery.dart';

class UserProfile {
  Map<String, List<String>> discovery;
  List<ChatMessage> conversation;
  bool discoveryGoalConfirmed;

  Map<String, dynamic> resume;
  Map<String, String> journeyNotes;
  List<String> journeyActivities;
  String name;
  String targetRole;
  String targetJobId;
  Map<String, double> targetRequirements;
  String journeyStage;
  Map<String, double> skills;
  Map<String, double> emotionalSignals;
  List<String> values;
  List<String> completedCourses;
  List<String> applications;
  List<String> interviews;
  bool hired;
  List<Map<String, dynamic>> events;
  List<String> savedJobs;
  List<String> viewedJobs;
  List<String> certificates;
  List<String> experiences;
  List<String> projects;
  List<String> languages;
  String education;
  String professionalSummary;
  String currentRole;

  UserProfile({
    Map<String, List<String>>? discovery,
    List<ChatMessage>? conversation,
    this.discoveryGoalConfirmed = false,
    Map<String, dynamic>? resume,
    Map<String, String>? journeyNotes,
    List<String>? journeyActivities,
    this.targetJobId = '',
    this.targetRequirements = const {},
    this.name = 'Pessoa usuária',
    this.targetRole = 'Assistente Administrativo',
    this.journeyStage = 'Descoberta',
    Map<String, double>? skills,
    Map<String, double>? emotionalSignals,
    List<String>? values,
    List<String>? completedCourses,
    List<String>? applications,
    List<String>? interviews,
    this.hired = false,
    List<Map<String, dynamic>>? events,
    List<String>? savedJobs,
    List<String>? viewedJobs,
    List<String>? certificates,
    List<String>? experiences,
    List<String>? projects,
    List<String>? languages,
    this.education = '',
    this.professionalSummary = '',
    this.currentRole = '',
  })  : discovery = discovery ?? {},
        conversation = conversation ?? [],
        resume = resume ?? {},
        journeyNotes = journeyNotes ?? {},
        journeyActivities = journeyActivities ?? [],
        skills = skills ??
            {
              'Excel': .30,
              'Comunicação': .70,
              'Organização': .80,
              'Atendimento': .40,
            },
        emotionalSignals = emotionalSignals ??
            {
              'Ansiedade em entrevista': .65,
              'Medo de errar': .55,
              'Insegurança': .50,
            },
        values = values ?? ['Respeito', 'Aprendizado', 'Estabilidade'],
        completedCourses = completedCourses ?? [],
        applications = applications ?? [],
        interviews = interviews ?? [],
        events = events ?? [],
        savedJobs = savedJobs ?? [],
        viewedJobs = viewedJobs ?? [],
        certificates = certificates ?? [],
        experiences = experiences ?? [],
        projects = projects ?? [],
        languages = languages ?? [];

  Map<String, dynamic> toMap() => {
        'discovery': discovery,
        'discoveryGoalConfirmed': discoveryGoalConfirmed,
        'conversation': conversation.map((m) => m.toMap()).toList(),
        'resume': resume,
        'journeyNotes': journeyNotes,
        'journeyActivities': journeyActivities,
        'name': name,
        'targetRole': targetRole,
        'targetJobId': targetJobId,
        'targetRequirements': targetRequirements,
        'journeyStage': journeyStage,
        'skills': skills,
        'emotionalSignals': emotionalSignals,
        'values': values,
        'completedCourses': completedCourses,
        'applications': applications,
        'interviews': interviews,
        'hired': hired,
        'events': events,
        'savedJobs': savedJobs,
        'viewedJobs': viewedJobs,
        'certificates': certificates,
        'experiences': experiences,
        'projects': projects,
        'languages': languages,
        'education': education,
        'professionalSummary': professionalSummary,
        'currentRole': currentRole,
      };
  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        discovery: (m['discovery'] as Map? ?? {})
            .map((k, v) => MapEntry(k as String, List<String>.from(v))),
        discoveryGoalConfirmed: m['discoveryGoalConfirmed'] == true,
        conversation: (m['conversation'] as List? ?? [])
            .map((x) => ChatMessage.fromMap(Map<String, dynamic>.from(x)))
            .toList(),
        resume: Map<String, dynamic>.from(m['resume'] ?? {}),
        journeyNotes: Map<String, String>.from(m['journeyNotes'] ?? {}),
        journeyActivities: List<String>.from(m['journeyActivities'] ?? []),
        targetJobId: m['targetJobId'] as String? ?? '',
        targetRequirements: (m['targetRequirements'] as Map? ?? {}).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
        name: m['name'] ?? 'Pessoa usuária',
        targetRole: m['targetRole'] ?? 'Assistente Administrativo',
        journeyStage: m['journeyStage'] ?? 'Descoberta',
        skills: Map<String, double>.from(
          (m['skills'] ?? {}).map((k, v) => MapEntry(k, (v as num).toDouble())),
        ),
        emotionalSignals: Map<String, double>.from(
          (m['emotionalSignals'] ?? {}).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ),
        ),
        values: List<String>.from(m['values'] ?? []),
        completedCourses: List<String>.from(m['completedCourses'] ?? []),
        applications: List<String>.from(m['applications'] ?? []),
        interviews: List<String>.from(m['interviews'] ?? []),
        hired: m['hired'] ?? false,
        events: List<Map<String, dynamic>>.from(
          (m['events'] ?? []).map((e) => Map<String, dynamic>.from(e)),
        ),
        savedJobs: List<String>.from(m['savedJobs'] ?? []),
        viewedJobs: List<String>.from(m['viewedJobs'] ?? []),
        certificates: List<String>.from(m['certificates'] ?? []),
        experiences: List<String>.from(m['experiences'] ?? []),
        projects: List<String>.from(m['projects'] ?? []),
        languages: List<String>.from(m['languages'] ?? []),
        education: m['education'] ?? '',
        professionalSummary: m['professionalSummary'] ?? '',
        currentRole: m['currentRole'] ?? '',
      );
}
