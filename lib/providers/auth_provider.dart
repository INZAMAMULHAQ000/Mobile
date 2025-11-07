import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../core/services/auth_service.dart';
import '../models/user.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = _authService.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.createUserWithEmailAndPassword(email, password, name);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      await _authService.updateProfile(name: name, photoUrl: photoUrl);
      // Refresh user data
      final updatedUser = _authService.currentUser;
      state = AsyncValue.data(updatedUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _authService.changePassword(currentPassword, newPassword);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value;
});

final isUserLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});

final isManagerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isManager ?? false;
});

final isViewerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isViewer ?? false;
});

final canManageApartmentsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canManageApartments ?? false;
});

final canManageGuestsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canManageGuests ?? false;
});

final canManageFinanceProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canManageFinance ?? false;
});

final canManageUsersProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canManageUsers ?? false;
});

final canViewReportsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.canViewReports ?? false;
});