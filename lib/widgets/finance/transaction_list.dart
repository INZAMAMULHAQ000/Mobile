import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/color_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/loading_widget.dart';

class TransactionList extends ConsumerWidget {
  final String filter;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionList({
    super.key,
    required this.filter,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(financeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 12.h),

        transactionsAsync.when(
          data: (transactions) {
            final filteredTransactions = _filterTransactions(transactions);

            if (filteredTransactions.isEmpty) {
              return _buildEmptyState(context);
            }

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () {
                        // TODO: Navigate to transaction details
                      },
                    );
                  },
                ),
                SizedBox(height: 16.h),
                if (filteredTransactions.length >= 10)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full transaction list
                    },
                    child: const Text('View All Transactions'),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Failed to load transactions: ${error.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Apply date filter if specified
    if (startDate != null && endDate != null) {
      filtered = filtered.where((transaction) {
        final transactionDate = transaction.transactionDate;
        return transactionDate.isAtSameMomentAs(startDate!) ||
            transactionDate.isAtSameMomentAs(endDate!) ||
            (transactionDate.isAfter(startDate!) && transactionDate.isBefore(endDate!));
      }).toList();
    }

    // Apply category/type filter
    if (filter != 'all') {
      filtered = filtered.where((transaction) {
        switch (filter) {
          case 'income':
            return transaction.isIncome;
          case 'expense':
            return transaction.isExpense;
          default:
            return transaction.category == filter;
        }
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first transaction to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Transaction Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: ColorUtils.getTransactionTypeColor(transaction.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  transaction.isIncome ? Icons.trending_up : Icons.trending_down,
                  color: ColorUtils.getTransactionTypeColor(transaction.type),
                  size: 20.w,
                ),
              ),

              SizedBox(width: 16.w),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          transaction.displayCategory,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (transaction.hasRelatedGuest) ...[
                          SizedBox(width: 8.w),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Guest Payment',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.w,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          FormatUtils.formatDate(transaction.transactionDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.payment_outlined,
                          size: 14.w,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          transaction.displayPaymentMethod,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.getTransactionTypeColor(transaction.type),
                    ),
                  ),
                  if (transaction.hasReceipt)
                    Icon(
                      Icons.receipt_outlined,
                      size: 16.w,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}