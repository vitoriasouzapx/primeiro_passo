import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class CloudService {
  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<UserCredential> register(String email, String password) =>
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> login(String email, String password) =>
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<void> save(UserProfile p) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(p.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> load() async {
    if (uid == null) return null;
    final d =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return d.exists ? UserProfile.fromMap(d.data()!) : null;
  }
}
