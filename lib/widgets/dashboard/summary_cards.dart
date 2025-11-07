import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/format_utils.dart';
import '../../models/apartment.dart';
import '../../models/guest.dart';

class SummaryCards extends StatelessWidget {
  final AsyncValue<List<Apartment>> apartmentsAsync;
  final AsyncValue<List<Guest>> guestsAsync;
  final AsyncValue<Map<String, dynamic>> summaryAsync;
  final AsyncValue<List<Contract>> expiringContractsAsync;

  const SummaryCards({
    super.key,
    required this.apartmentsAsync,
    required this.guestsAsync,
    required this.summaryAsync,
    required this.expiringContractsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
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
          children: [
            _buildSummaryCard(
              context,
              'Total Apartments',
              apartmentsAsync.when(
                data: (apartments) => apartments.length.toString(),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              Icons.apartment,
              Colors.blue,
            ),
            _buildSummaryCard(
              context,
              'Total Guests',
              guestsAsync.when(
                data: (guests) => guests.length.toString(),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              Icons.people,
              Colors.green,
            ),
            _buildSummaryCard(
              context,
              'Monthly Income',
              summaryAsync.when(
                data: (summary) => FormatUtils.formatCurrency(summary['totalIncome'] as double? ?? 0.0),
                loading: () => '...',
                error: (_, __) => '\$0',
              ),
              Icons.trending_up,
              Colors.purple,
            ),
            _buildSummaryCard(
              context,
              'Expiring Contracts',
              expiringContractsAsync.when(
                data: (contracts) => contracts.length.toString(),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              Icons.event,
              Colors.orange,
            ),
          ],
        ),
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
            Icon(icon, color: color, size: 24.w),
            Spacer(),
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
}