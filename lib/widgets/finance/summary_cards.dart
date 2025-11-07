import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/format_utils.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> summary;

  const SummaryCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final totalIncome = (summary['totalIncome'] as double?) ?? 0.0;
    final totalExpense = (summary['totalExpense'] as double?) ?? 0.0;
    final profitLoss = (summary['profitLoss'] as double?) ?? 0.0;
    final transactionCount = (summary['transactionCount'] as int?) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),

        // Summary Cards Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.6,
          children: [
            // Income Card
            _buildSummaryCard(
              context,
              'Total Income',
              FormatUtils.formatCurrency(totalIncome),
              Icons.trending_up,
              Colors.green,
            ),

            // Expense Card
            _buildSummaryCard(
              context,
              'Total Expense',
              FormatUtils.formatCurrency(totalExpense),
              Icons.trending_down,
              Colors.red,
            ),

            // Profit/Loss Card
            _buildSummaryCard(
              context,
              'Profit/Loss',
              FormatUtils.formatCurrency(profitLoss),
              profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
              profitLoss >= 0 ? Colors.blue : Colors.red,
            ),

            // Transactions Card
            _buildSummaryCard(
              context,
              'Transactions',
              transactionCount.toString(),
              Icons.receipt_long,
              Theme.of(context).colorScheme.primary,
            ),
          ],
        ),

        // Profit/Loss Indicator
        SizedBox(height: 16.h),
        _buildProfitLossIndicator(context, profitLoss),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20.w,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    color == Colors.green
                        ? Icons.arrow_upward
                        : color == Colors.red
                            ? Icons.arrow_downward
                            : Icons.remove,
                    color: color,
                    size: 12.w,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitLossIndicator(BuildContext context, double profitLoss) {
    final isProfit = profitLoss >= 0;
    final percentage = profitLoss != 0 && (profitLoss / (summary['totalIncome'] as double? ?? 1.0)) * 100;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isProfit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (isProfit ? Colors.green : Colors.red).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isProfit ? Icons.check_circle : Icons.warning,
            color: isProfit ? Colors.green : Colors.red,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfit ? 'Net Profit' : 'Net Loss',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '${FormatUtils.formatCurrency(profitLoss.abs())} (${percentage.abs().toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isProfit ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCardsLoading extends StatelessWidget {
  const SummaryCardsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.6,
          children: List.generate(4, (index) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class SummaryCardsError extends StatelessWidget {
  final String error;

  const SummaryCardsError({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
              'Failed to load financial summary',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}