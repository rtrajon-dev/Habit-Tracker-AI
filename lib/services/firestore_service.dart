import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit/models/user_model.dart';
import 'package:habit/models/habit_model.dart';
import 'package:uuid/uuid.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }


  // Add a habit
  Future<void> addHabit(String userId, HabitModel habit) async {
    try {
      final habitId = habit.id.isEmpty ? const Uuid().v4() : habit.id;
      await _db.collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .set(habit.copyWith(id: habitId).toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update a habit
  Future<void> updateHabit(String userId, HabitModel habit) async {
    try {
      await _db.collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id)
          .update(habit.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      await _db.collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all habits stream
  Stream<List<HabitModel>> getHabits(String userId) {
    return _db.collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList());
  }

  Future<void> saveUserGoals(String uid, List<String> goals) async {
    await _db.collection("users").doc(uid).update({
      "goals": goals,
    });
  }


}



