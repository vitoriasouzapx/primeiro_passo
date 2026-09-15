import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class LocalMemoryService {
  static const _key = 'primeiro_passo_profile_v02';
  Future<UserProfile> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    return raw == null ? UserProfile() : UserProfile.fromMap(jsonDecode(raw));
  }

  Future<void> save(UserProfile profile) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(profile.toMap()));
  }
}
