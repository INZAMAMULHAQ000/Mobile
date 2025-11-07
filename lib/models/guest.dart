import 'package:cloud_firestore/cloud_firestore.dart';

class Guest {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? idProofUrl;
  final String? photoUrl;
  final String? apartmentId;
  final String? roomId;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String createdBy;

  const Guest({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.idProofUrl,
    this.photoUrl,
    this.apartmentId,
    this.roomId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Guest copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? idProofUrl,
    String? photoUrl,
    String? apartmentId,
    String? roomId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? createdBy,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      apartmentId: apartmentId ?? this.apartmentId,
      roomId: roomId ?? this.roomId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory Guest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Guest(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      address: data['address'],
      idProofUrl: data['idProofUrl'],
      photoUrl: data['photoUrl'],
      apartmentId: data['apartmentId'],
      roomId: data['roomId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'idProofUrl': idProofUrl,
      'photoUrl': photoUrl,
      'apartmentId': apartmentId,
      'roomId': roomId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Guest(id: $id, name: $name, phone: $phone, apartmentId: $apartmentId, roomId: $roomId)';
  }

  bool get hasApartment => apartmentId != null && apartmentId!.isNotEmpty;
  bool get hasRoom => roomId != null && roomId!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasIdProof => idProofUrl != null && idProofUrl!.isNotEmpty;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get isAssignedToRoom => hasApartment && hasRoom;
}