import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String apartmentId;
  final String roomNumber;
  final String? floor;
  final double rentAmount;
  final String status;
  final String? currentGuestId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Room({
    required this.id,
    required this.apartmentId,
    required this.roomNumber,
    this.floor,
    required this.rentAmount,
    this.status = 'vacant',
    this.currentGuestId,
    required this.createdAt,
    required this.updatedAt,
  });

  Room copyWith({
    String? id,
    String? apartmentId,
    String? roomNumber,
    String? floor,
    double? rentAmount,
    String? status,
    String? currentGuestId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      apartmentId: apartmentId ?? this.apartmentId,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      rentAmount: rentAmount ?? this.rentAmount,
      status: status ?? this.status,
      currentGuestId: currentGuestId ?? this.currentGuestId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      apartmentId: data['apartmentId'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      floor: data['floor'],
      rentAmount: (data['rentAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'vacant',
      currentGuestId: data['currentGuestId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'apartmentId': apartmentId,
      'roomNumber': roomNumber,
      'floor': floor,
      'rentAmount': rentAmount,
      'status': status,
      'currentGuestId': currentGuestId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Room(id: $id, apartmentId: $apartmentId, roomNumber: $roomNumber, status: $status)';
  }

  bool get isVacant => status == 'vacant';
  bool get isOccupied => status == 'occupied';
  bool get isMaintenance => status == 'maintenance';
  bool get hasGuest => currentGuestId != null && currentGuestId!.isNotEmpty;
}