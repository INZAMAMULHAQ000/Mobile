import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/guest_provider.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/dashboard/summary_cards.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/dashboard/recent_activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final apartmentsAsync = ref.watch(apartmentProvider);
    final guestsAsync = ref.watch(guestProvider);
    final currentMonthSummary = ref.watch(currentMonthSummaryProvider);
    final expiringContractsAsync = ref.watch(expiringContractsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser?.name ?? 'User'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // TODO: Navigate to profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(apartmentProvider.notifier).refresh(),
            ref.read(guestProvider.notifier).refresh(),
            ref.read(financeProvider.notifier).refresh(),
          ]);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              SummaryCards(
                apartmentsAsync: apartmentsAsync,
                guestsAsync: guestsAsync,
                summaryAsync: currentMonthSummary,
                expiringContractsAsync: expiringContractsAsync,
              ),

              SizedBox(height: 24.h),

              // Quick Actions
              QuickActions(
                canManageApartments: ref.watch(canManageApartmentsProvider),
                canManageGuests: ref.watch(canManageGuestsProvider),
                canManageFinance: ref.watch(canManageFinanceProvider),
              ),

              SizedBox(height: 24.h),

              // Recent Activity
              RecentActivity(
                apartmentsAsync: apartmentsAsync,
                guestsAsync: guestsAsync,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}