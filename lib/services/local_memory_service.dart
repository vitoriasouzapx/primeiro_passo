import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class LocalMemoryService {
  static const _key = 'primeiro_passo_profile_v02';
  String? userId;
  String get key => userId == null ? _key : '${_key}_$userId';
  Future<UserProfile> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(key);
    return raw == null ? UserProfile() : UserProfile.fromMap(jsonDecode(raw));
  }

  Future<void> save(UserProfile profile) async {
    final p = await SharedPreferences.getInstance();
    if (!await p.setString(key, jsonEncode(profile.toMap()))) throw StateError('Falha ao salvar');
  }
}
