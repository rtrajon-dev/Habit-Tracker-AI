import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String title;
  final String category; // Health, Study, Fitness, Productivity, Mental Health, Others
  final String frequency; // Daily or Weekly
  final DateTime? startDate;
  final String? notes;
  final String? description;

  HabitModel({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    this.startDate,
    this.notes,
    this.description,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? 'Others',
      frequency: data['frequency'] ?? 'Daily',
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'frequency': frequency,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'notes': notes,
      'description': description,
    };
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    String? frequency,
    DateTime? startDate,
    String? notes,
    String? description,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      description: description ?? this.description,
    );
  }
}
