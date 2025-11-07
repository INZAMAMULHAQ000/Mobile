import 'package:cloud_firestore/cloud_firestore.dart';

class Contract {
  final String id;
  final String guestId;
  final String apartmentId;
  final String roomId;
  final Timestamp startDate;
  final Timestamp endDate;
  final double rentAmount;
  final double depositAmount;
  final String? contractDocUrl;
  final String status;
  final String lastUpdatedBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Contract({
    required this.id,
    required this.guestId,
    required this.apartmentId,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.depositAmount,
    this.contractDocUrl,
    this.status = 'active',
    required this.lastUpdatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Contract copyWith({
    String? id,
    String? guestId,
    String? apartmentId,
    String? roomId,
    Timestamp? startDate,
    Timestamp? endDate,
    double? rentAmount,
    double? depositAmount,
    String? contractDocUrl,
    String? status,
    String? lastUpdatedBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Contract(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      apartmentId: apartmentId ?? this.apartmentId,
      roomId: roomId ?? this.roomId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rentAmount: rentAmount ?? this.rentAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      contractDocUrl: contractDocUrl ?? this.contractDocUrl,
      status: status ?? this.status,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Contract.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contract(
      id: doc.id,
      guestId: data['guestId'] ?? '',
      apartmentId: data['apartmentId'] ?? '',
      roomId: data['roomId'] ?? '',
      startDate: data['startDate'] ?? Timestamp.now(),
      endDate: data['endDate'] ?? Timestamp.now(),
      rentAmount: (data['rentAmount'] ?? 0).toDouble(),
      depositAmount: (data['depositAmount'] ?? 0).toDouble(),
      contractDocUrl: data['contractDocUrl'],
      status: data['status'] ?? 'active',
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'guestId': guestId,
      'apartmentId': apartmentId,
      'roomId': roomId,
      'startDate': startDate,
      'endDate': endDate,
      'rentAmount': rentAmount,
      'depositAmount': depositAmount,
      'contractDocUrl': contractDocUrl,
      'status': status,
      'lastUpdatedBy': lastUpdatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contract && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contract(id: $id, guestId: $guestId, status: $status, startDate: $startDate, endDate: $endDate)';
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isTerminated => status == 'terminated';
  bool get hasContractDocument => contractDocUrl != null && contractDocUrl!.isNotEmpty;

  DateTime get startDateTime => startDate.toDate();
  DateTime get endDateTime => endDate.toDate();

  bool get isExpiringSoon {
    final now = DateTime.now();
    final expiryDate = endDateTime;
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return isActive && daysUntilExpiry <= 15 && daysUntilExpiry >= 0;
  }

  bool get isOverdue {
    final now = DateTime.now();
    return isActive && now.isAfter(endDateTime);
  }

  int get totalDays {
    return endDateTime.difference(startDateTime).inDays;
  }

  int get daysRemaining {
    if (!isActive) return 0;
    final now = DateTime.now();
    if (now.isAfter(endDateTime)) return 0;
    return endDateTime.difference(now).inDays;
  }

  double get totalContractValue {
    return rentAmount * totalDays;
  }
}