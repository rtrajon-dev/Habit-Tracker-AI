import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final DateTime dob;
  final List<String> goals; // <- added field

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.dob,
    this.goals = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      goals: List<String>.from(data['goals'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'dob': dob,
      'goals': goals,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? gender,
    DateTime? dob,
    List<String>? goals,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      goals: goals ?? this.goals,
    );
  }
}
