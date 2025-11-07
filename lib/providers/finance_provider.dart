import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/validation_utils.dart';
import '../providers/auth_provider.dart';

class FinanceNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final FirebaseService _firebaseService;
  final String _currentUserId;

  FinanceNotifier(this._firebaseService, this._currentUserId)
      : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    state = const AsyncValue.loading();

    try {
      final query = _firebaseService.getCollection(
        'transactions',
        query: FirebaseFirestore.instance
            .collection('transactions')
            .where('createdBy', isEqualTo: _currentUserId)
            .orderBy('date', descending: true),
      );

      final snapshot = await query;
      final transactions = snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();

      state = AsyncValue.data(transactions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadTransactions();
  }

  Future<String> addTransaction({
    required String type,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? relatedGuestId,
    String? relatedContractId,
    required String apartmentId,
    required String paymentMethod,
    String? receiptUrl,
  }) async {
    try {
      final transaction = Transaction(
        id: _firebaseService.generateId(),
        type: type,
        category: category,
        description: description,
        amount: amount,
        date: _firebaseService.getTimestampFromDateTime(date),
        relatedGuestId: relatedGuestId,
        relatedContractId: relatedContractId,
        apartmentId: apartmentId,
        paymentMethod: paymentMethod,
        receiptUrl: receiptUrl,
        createdBy: _currentUserId,
        createdAt: _firebaseService.getCurrentTimestamp(),
        updatedAt: _firebaseService.getCurrentTimestamp(),
      );

      await _firebaseService.setDocument(
        'transactions',
        transaction.id,
        transaction.toFirestore(),
      );

      // Refresh the list
      await _loadTransactions();

      return transaction.id;
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  Future<void> updateTransaction({
    required String transactionId,
    required String type,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? relatedGuestId,
    String? relatedContractId,
    required String apartmentId,
    required String paymentMethod,
    String? receiptUrl,
  }) async {
    try {
      final updates = {
        'type': type,
        'category': category,
        'description': description,
        'amount': amount,
        'date': _firebaseService.getTimestampFromDateTime(date),
        'relatedGuestId': relatedGuestId,
        'relatedContractId': relatedContractId,
        'apartmentId': apartmentId,
        'paymentMethod': paymentMethod,
        'receiptUrl': receiptUrl,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
      };

      await _firebaseService.updateDocument(
        'transactions',
        transactionId,
        updates,
      );

      // Refresh the list
      await _loadTransactions();
    } catch (e) {
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firebaseService.deleteDocument('transactions', transactionId);

      // Refresh the list
      await _loadTransactions();
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getTransactionsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? apartmentId,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('transactions')
          .where('createdBy', isEqualTo: _currentUserId)
          .where('date', '>=', Timestamp.fromDate(startDate))
          .where('date', '<=', Timestamp.fromDate(endDate))
          .orderBy('date', descending: true);

      if (apartmentId != null) {
        query = query.where('apartmentId', isEqualTo: apartmentId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getFinancialSummary(
    DateTime startDate,
    DateTime endDate, {
    String? apartmentId,
  }) async {
    try {
      final transactions = await getTransactionsForDateRange(startDate, endDate, apartmentId: apartmentId);

      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String, double> incomeByCategory = {};
      final Map<String, double> expenseByCategory = {};

      for (final transaction in transactions) {
        final amount = transaction.amount;
        final category = transaction.category;

        if (transaction.isIncome) {
          totalIncome += amount;
          incomeByCategory[category] = (incomeByCategory[category] ?? 0) + amount;
        } else {
          totalExpense += amount;
          expenseByCategory[category] = (expenseByCategory[category] ?? 0) + amount;
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'profitLoss': totalIncome - totalExpense,
        'transactionCount': transactions.length,
        'incomeByCategory': incomeByCategory,
        'expenseByCategory': expenseByCategory,
        'transactions': transactions,
      };
    } catch (e) {
      throw Exception('Failed to get financial summary: ${e.toString()}');
    }
  }

  String? validateTransactionData({
    String? amount,
    String? description,
  }) {
    final amountError = ValidationUtils.validateAmount(amount);
    if (amountError != null) return amountError;

    final descriptionError = ValidationUtils.validateRequired(description, 'Description');
    if (descriptionError != null) return descriptionError;

    return null;
  }
}

// Provider
final financeProvider = StateNotifierProvider<FinanceNotifier, AsyncValue<List<Transaction>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) throw Exception('User not authenticated');
  return FinanceNotifier(firebaseService, currentUser.uid);
});

// Financial summary provider for date range
final financialSummaryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final financeNotifier = ref.watch(financeProvider.notifier);
  final startDate = params['startDate'] as DateTime;
  final endDate = params['endDate'] as DateTime;
  final apartmentId = params['apartmentId'] as String?;

  return await financeNotifier.getFinancialSummary(startDate, endDate, apartmentId: apartmentId);
});

// Current month summary provider
final currentMonthSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final summaryAsync = ref.watch(financialSummaryProvider({
    'startDate': startDate,
    'endDate': endDate,
    'apartmentId': null,
  }));

  return summaryAsync.when(
    data: (data) => data,
    loading: () => {
      'totalIncome': 0.0,
      'totalExpense': 0.0,
      'profitLoss': 0.0,
      'transactionCount': 0,
      'incomeByCategory': <String, double>{},
      'expenseByCategory': <String, double>{},
      'transactions': <Transaction>[],
    },
    error: (_, __) => {
      'totalIncome': 0.0,
      'totalExpense': 0.0,
      'profitLoss': 0.0,
      'transactionCount': 0,
      'incomeByCategory': <String, double>{},
      'expenseByCategory': <String, double>{},
      'transactions': <Transaction>[],
    },
  );
});

// Transaction categories
final incomeCategories = [
  TransactionCategory.rent,
  TransactionCategory.deposit,
  TransactionCategory.otherIncome,
];

final expenseCategories = [
  TransactionCategory.utilities,
  TransactionCategory.maintenance,
  TransactionCategory.repairs,
  TransactionCategory.staff,
  TransactionCategory.taxes,
  TransactionCategory.insurance,
  TransactionCategory.otherExpense,
];

final paymentMethods = [
  PaymentMethod.cash,
  PaymentMethod.bank,
  PaymentMethod.online,
  PaymentMethod.check,
];