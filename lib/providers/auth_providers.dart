import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit/models/user_model.dart';
import 'package:habit/services/auth_service.dart';
import 'package:habit/services/firestore_service.dart';

import 'firestore_service_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>(
      (ref) => ref.watch(authServiceProvider).authStateChanges,
);

// lib/providers/auth_providers.dart
// ... (authStateProvider, firestoreServiceProvider) ...

class UserDataNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final FirestoreService _firestoreService;

  UserDataNotifier(this._firestoreService) : super(const AsyncValue.loading()); // Start as loading

  Future<void> loadUserProfile(String userId) async {
    // To prevent multiple loading states if called rapidly for the same user,
    // you could check if already loading for this userId, but for now, this is typical:
    state = const AsyncValue.loading();
    try {
      final userProfile = await _firestoreService.getUserProfile(userId);
      state = AsyncValue.data(userProfile); // userProfile can be null if not found
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null); // Explicitly set to data(null) on logout
  }

  void setUserData(UserModel userModel) { // For ProfileScreen save
    state = AsyncValue.data(userModel);
  }
}

final userProvider = StateNotifierProvider<UserDataNotifier, AsyncValue<UserModel?>>((ref) {
  // Assuming firestoreServiceProvider is defined correctly elsewhere or in this file
  return UserDataNotifier(ref.read(firestoreServiceProvider));
});
