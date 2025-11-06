import 'package:cloud_firestore/cloud_firestore.dart';

class Apartment {
  final String id;
  final String name;
  final String location;
  final String? description;
  final int totalRooms;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String createdBy;
  final bool isActive;

  const Apartment({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.totalRooms,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
  });

  Apartment copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    int? totalRooms,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? createdBy,
    bool? isActive,
  }) {
    return Apartment(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      totalRooms: totalRooms ?? this.totalRooms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Apartment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Apartment(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'],
      totalRooms: data['totalRooms'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      createdBy: data['createdBy'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'totalRooms': totalRooms,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Apartment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Apartment(id: $id, name: $name, location: $location, totalRooms: $totalRooms)';
  }
}