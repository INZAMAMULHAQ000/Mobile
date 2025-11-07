import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges().asyncMap(_firebaseUserToUser);

  User? get currentUser => _firebaseAuth.currentUser != null
      ? User.fromFirebaseUser(_firebaseAuth.currentUser!)
      : null;

  Future<User?> _firebaseUserToUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      // Create user document if it doesn't exist
      await _createUserDocument(firebaseUser);
      final updatedDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return User.fromFirestore(updatedDoc);
    }

    // Update last login time
    await _firestore.collection('users').doc(firebaseUser.uid).update({
      'lastLoginAt': Timestamp.now(),
    });

    return User.fromFirestore(userDoc);
  }

  Future<void> _createUserDocument(firebase_auth.User firebaseUser) async {
    final user = User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'User',
      role: 'admin', // Default role for first users
      createdAt: Timestamp.now(),
      lastLoginAt: Timestamp.now(),
      photoUrl: firebaseUser.photoURL,
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set(user.toFirestore());
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _firebaseUserToUser(credential.user);
      if (user == null) {
        throw Exception('Failed to retrieve user data');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = await _firebaseUserToUser(userCredential.user);

      if (user == null) {
        throw Exception('Failed to retrieve user data');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<User> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document with manager role (can be changed by admin later)
      final user = User(
        uid: credential.user!.uid,
        email: email,
        name: name,
        role: 'manager', // Default role for new users
        createdAt: Timestamp.now(),
        lastLoginAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toFirestore());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      if (name != null) {
        await user.updateDisplayName(name);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      final updates = <String, dynamic>{'updatedAt': Timestamp.now()};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Reauthenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for this email.');
      case 'wrong-password':
        return Exception('Incorrect password provided.');
      case 'email-already-in-use':
        return Exception('An account already exists for this email.');
      case 'weak-password':
        return Exception('Password should be at least 8 characters long.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later.');
      case 'operation-not-allowed':
        return Exception('Signing in with Email and Password is not enabled.');
      case 'account-exists-with-different-credential':
        return Exception('An account already exists with the same email address but different sign-in credentials.');
      case 'invalid-credential':
        return Exception('The credential is malformed or has expired.');
      case 'network-request-failed':
        return Exception('A network error occurred. Please check your internet connection.');
      default:
        return Exception('An authentication error occurred: ${e.message}');
    }
  }
}

extension UserExtension on User {
  static User fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'User',
      role: 'viewer', // This will be loaded from Firestore
      createdAt: Timestamp.now(), // This will be loaded from Firestore
      photoUrl: firebaseUser.photoURL,
    );
  }
}

// Provider for dependency injection
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for current user stream
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for current user value
final currentUserValueProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});