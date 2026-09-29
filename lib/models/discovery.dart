const discoveryLabels = {
  'interests': 'Interesses',
  'experiences': 'Experiências',
  'preferences': 'Preferências e disponibilidade',
  'focusSkills': 'Quero aprender',
  'targetRole': 'Objetivo de exploração',
};

class ProfileSuggestion {
  final String field, value, reason;
  const ProfileSuggestion(this.field, this.value, this.reason);
  factory ProfileSuggestion.fromMap(Map<String, dynamic> m) {
    final field = m['field'] as String;
    final value = (m['value'] as String).trim();
    if (!discoveryLabels.containsKey(field) ||
        value.isEmpty ||
        value.length > 200) {
      throw const FormatException('Sugestão inválida');
    }
    return ProfileSuggestion(field, value, m['reason'] as String);
  }
  Map<String, dynamic> toMap() =>
      {'field': field, 'value': value, 'reason': reason};
}

class ChatMessage {
  final String role, content;
  final List<ProfileSuggestion> suggestions;
  const ChatMessage(this.role, this.content, [this.suggestions = const []]);
  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
      m['role'] as String,
      m['content'] as String,
      (m['suggestions'] as List? ?? [])
          .map((x) => ProfileSuggestion.fromMap(Map<String, dynamic>.from(x)))
          .toList());
  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'suggestions': suggestions.map((s) => s.toMap()).toList()
      };
}
