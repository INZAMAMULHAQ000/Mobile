import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';

class QuickActions extends StatelessWidget {
  final bool canManageApartments;
  final bool canManageGuests;
  final bool canManageFinance;

  const QuickActions({
    super.key,
    required this.canManageApartments,
    required this.canManageGuests,
    required this.canManageFinance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (canManageApartments) ...[
                _buildActionButton(
                  context,
                  'Add Apartment',
                  Icons.apartment,
                  Colors.blue,
                  () {
                    // TODO: Navigate to add apartment
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add apartment coming soon')),
                    );
                  },
                ),
                SizedBox(width: 12.w),
              ],
              if (canManageGuests) ...[
                _buildActionButton(
                  context,
                  'Add Guest',
                  Icons.person_add,
                  Colors.green,
                  () {
                    // TODO: Navigate to add guest
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add guest coming soon')),
                    );
                  },
                ),
                SizedBox(width: 12.w),
              ],
              if (canManageFinance) ...[
                _buildActionButton(
                  context,
                  'Add Transaction',
                  Icons.attach_money,
                  Colors.purple,
                  () {
                    // TODO: Navigate to add transaction
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add transaction coming soon')),
                    );
                  },
                ),
                SizedBox(width: 12.w),
              ],
              _buildActionButton(
                context,
                'View Reports',
                Icons.bar_chart,
                Colors.orange,
                () {
                  // TODO: Navigate to reports
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reports coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32.w,
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}