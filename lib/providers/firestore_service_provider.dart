// lib/providers/firestore_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});