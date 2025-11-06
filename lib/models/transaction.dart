import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String type;
  final String category;
  final String description;
  final double amount;
  final Timestamp date;
  final String? relatedGuestId;
  final String? relatedContractId;
  final String apartmentId;
  final String paymentMethod;
  final String? receiptUrl;
  final String createdBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.relatedGuestId,
    this.relatedContractId,
    required this.apartmentId,
    required this.paymentMethod,
    this.receiptUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? type,
    String? category,
    String? description,
    double? amount,
    Timestamp? date,
    String? relatedGuestId,
    String? relatedContractId,
    String? apartmentId,
    String? paymentMethod,
    String? receiptUrl,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      relatedGuestId: relatedGuestId ?? this.relatedGuestId,
      relatedContractId: relatedContractId ?? this.relatedContractId,
      apartmentId: apartmentId ?? this.apartmentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      type: data['type'] ?? 'expense',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date'] ?? Timestamp.now(),
      relatedGuestId: data['relatedGuestId'],
      relatedContractId: data['relatedContractId'],
      apartmentId: data['apartmentId'] ?? '',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      receiptUrl: data['receiptUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date,
      'relatedGuestId': relatedGuestId,
      'relatedContractId': relatedContractId,
      'apartmentId': apartmentId,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, category: $category, amount: $amount, date: $date)';
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isRentPayment => category == 'rent';
  bool get isDeposit => category == 'deposit';
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;
  bool get hasRelatedGuest => relatedGuestId != null && relatedGuestId!.isNotEmpty;
  bool get hasRelatedContract => relatedContractId != null && relatedContractId!.isNotEmpty;

  DateTime get transactionDate => date.toDate();

  String get formattedAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  String get displayCategory {
    switch (category) {
      case 'rent':
        return 'Rent Payment';
      case 'deposit':
        return 'Security Deposit';
      case 'utilities':
        return 'Utilities';
      case 'maintenance':
        return 'Maintenance';
      case 'repairs':
        return 'Repairs';
      case 'staff':
        return 'Staff Salary';
      case 'taxes':
        return 'Taxes';
      case 'insurance':
        return 'Insurance';
      case 'other_income':
        return 'Other Income';
      case 'other_expense':
        return 'Other Expense';
      default:
        return category;
    }
  }

  String get displayPaymentMethod {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'bank':
        return 'Bank Transfer';
      case 'online':
        return 'Online Payment';
      case 'check':
        return 'Check';
      default:
        return paymentMethod;
    }
  }
}