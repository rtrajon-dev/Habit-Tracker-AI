import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'package:habit/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> register({
    required String email,
    required String password,
    required String name,
    required String gender,
    required DateTime dob,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      final profile = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        gender: gender,
        dob: dob,
      );
      await _firestore.saveUserProfile(profile);
    }
    return user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
