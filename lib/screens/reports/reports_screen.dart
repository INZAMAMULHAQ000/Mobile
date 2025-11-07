import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../providers/finance_provider.dart';
import '../../providers/guest_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/reports/report_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(canViewReportsProvider);
    final currentMonthSummary = ref.watch(currentMonthSummaryProvider);
    final apartmentsAsync = ref.watch(apartmentProvider);
    final activeContractsAsync = ref.watch(activeContractsProvider);

    if (!canView) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.reports),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Access Restricted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You don\'t have permission to view reports',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {
              // TODO: Date range selector for reports
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(financeProvider.notifier).refresh();
          await ref.read(apartmentProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.h),

              currentMonthSummary.when(
                data: (summary) => _buildOverviewCards(context, summary),
                loading: () => _buildOverviewLoading(context),
                error: (error, stackTrace) => _buildOverviewError(context),
              ),

              SizedBox(height: 24.h),

              // Quick Reports
              Text(
                'Quick Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.h),

              // Report Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.3,
                children: [
                  ReportCard(
                    title: 'Active Guests',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => _generateGuestReport(context, ref),
                  ),
                  ReportCard(
                    title: 'Financial Summary',
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                    onTap: () => _generateFinancialReport(context, ref),
                  ),
                  ReportCard(
                    title: 'Contract Expiry',
                    icon: Icons.event,
                    color: Colors.orange,
                    onTap: () => _generateContractReport(context, ref),
                  ),
                  ReportCard(
                    title: 'Property Status',
                    icon: Icons.apartment,
                    color: Colors.purple,
                    onTap: () => _generatePropertyReport(context, ref),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Detailed Reports
              Text(
                'Detailed Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16.h),

              Column(
                children: [
                  _buildDetailedReportItem(
                    context,
                    'Monthly Financial Report',
                    'Income, expenses, and profit/loss analysis',
                    Icons.description,
                    Colors.blue,
                    () => _generateDetailedFinancialReport(context, ref),
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailedReportItem(
                    context,
                    'Guest Directory',
                    'Complete list of all active guests',
                    Icons.people_alt,
                    Colors.green,
                    () => _generateGuestDirectory(context, ref),
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailedReportItem(
                    context,
                    'Occupancy Report',
                    'Room occupancy and vacancy analysis',
                    Icons.meeting_room,
                    Colors.orange,
                    () => _generateOccupancyReport(context, ref),
                  ),
                  SizedBox(height: 12.h),
                  _buildDetailedReportItem(
                    context,
                    'Year-End Summary',
                    'Annual financial and operational summary',
                    Icons.summarize,
                    Colors.purple,
                    () => _generateYearEndReport(context, ref),
                  ),
                ],
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, Map<String, dynamic> summary) {
    final totalIncome = (summary['totalIncome'] as double?) ?? 0.0;
    final totalExpense = (summary['totalExpense'] as double?) ?? 0.0;
    final profitLoss = (summary['profitLoss'] as double?) ?? 0.0;
    final transactionCount = (summary['transactionCount'] as int?) ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.6,
      children: [
        _buildOverviewCard(
          context,
          'Total Income',
          FormatUtils.formatCurrency(totalIncome),
          Icons.trending_up,
          Colors.green,
        ),
        _buildOverviewCard(
          context,
          'Total Expense',
          FormatUtils.formatCurrency(totalExpense),
          Icons.trending_down,
          Colors.red,
        ),
        _buildOverviewCard(
          context,
          'Net Profit/Loss',
          FormatUtils.formatCurrency(profitLoss),
          profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
          profitLoss >= 0 ? Colors.blue : Colors.red,
        ),
        _buildOverviewCard(
          context,
          'Transactions',
          transactionCount.toString(),
          Icons.receipt_long,
          Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewLoading(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOverviewError(BuildContext context) {
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
              'Failed to load overview data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedReportItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.w,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateGuestReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guest report generation coming soon')),
    );
  }

  void _generateFinancialReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Financial report generation coming soon')),
    );
  }

  void _generateContractReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contract report generation coming soon')),
    );
  }

  void _generatePropertyReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Property report generation coming soon')),
    );
  }

  void _generateDetailedFinancialReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detailed financial report coming soon')),
    );
  }

  void _generateGuestDirectory(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guest directory coming soon')),
    );
  }

  void _generateOccupancyReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Occupancy report coming soon')),
    );
  }

  void _generateYearEndReport(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Year-end report coming soon')),
    );
  }
}