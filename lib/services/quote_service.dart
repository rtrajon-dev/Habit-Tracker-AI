import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<void> addFavorite(Map<String, String> quote) async {
    if (userId == null) return;
    final docRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc("quotes")
        .collection("list")
        .doc(quote["q"]);
    await docRef.set({
      "q": quote["q"],
      "a": quote["a"],
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String quoteText) async {
    if (userId == null) return;
    final docRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc("quotes")
        .collection("list")
        .doc(quoteText);
    await docRef.delete();
  }

  Future<bool> isFavorite(String quoteText) async {
    if (userId == null) return false;
    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc("quotes")
        .collection("list")
        .doc(quoteText)
        .get();
    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> getFavoritesStream() {
    if (userId == null) return const Stream.empty();
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc("quotes")
        .collection("list")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
