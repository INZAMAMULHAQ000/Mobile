import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String role;
  final Timestamp createdAt;
  final Timestamp? lastLoginAt;
  final bool isActive;
  final String? photoUrl;

  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.photoUrl,
  });

  User copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    Timestamp? createdAt,
    Timestamp? lastLoginAt,
    bool? isActive,
    String? photoUrl,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'viewer',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastLoginAt: data['lastLoginAt'],
      isActive: data['isActive'] ?? true,
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'isActive': isActive,
      'photoUrl': photoUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, name: $name, role: $role)';
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isViewer => role == 'viewer';

  bool get canManageApartments => isAdmin || isManager;
  bool get canManageGuests => isAdmin || isManager;
  bool get canManageFinance => isAdmin || isManager;
  bool get canManageUsers => isAdmin;
  bool get canViewReports => isAdmin || isManager || isViewer;
}