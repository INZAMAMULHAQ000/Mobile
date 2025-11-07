import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../models/apartment.dart';
import '../../models/guest.dart';

class RecentActivity extends StatelessWidget {
  final AsyncValue<List<Apartment>> apartmentsAsync;
  final AsyncValue<List<Guest>> guestsAsync;

  const RecentActivity({
    super.key,
    required this.apartmentsAsync,
    required this.guestsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),

        // Recent Apartments
        _buildRecentSection(
          context,
          'Recent Apartments',
          apartmentsAsync,
          (apartments) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: apartments.length > 3 ? 3 : apartments.length,
            itemBuilder: (context, index) {
              final apartment = apartments[index];
              return _buildApartmentItem(context, apartment);
            },
          ),
          Icons.apartment,
          Colors.blue,
        ),

        SizedBox(height: 16.h),

        // Recent Guests
        _buildRecentSection(
          context,
          'Recent Guests',
          guestsAsync,
          (guests) => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guests.length > 3 ? 3 : guests.length,
            itemBuilder: (context, index) {
              final guest = guests[index];
              return _buildGuestItem(context, guest);
            },
          ),
          Icons.people,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildRecentSection<T>(
    BuildContext context,
    String title,
    AsyncValue<List<T>> asyncData,
    Widget Function(List<T>) builder,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20.w),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'View all',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Content
          asyncData.when(
            data: (data) {
              if (data.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48.w,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No items yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return builder(data);
            },
            loading: () => Padding(
              padding: EdgeInsets.all(32.w),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  'Failed to load data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApartmentItem(BuildContext context, Apartment apartment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.apartment,
          color: Theme.of(context).colorScheme.primary,
          size: 20.w,
        ),
      ),
      title: Text(
        apartment.name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        '${apartment.totalRooms} rooms • ${apartment.location}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Text(
        FormatUtils.formatDate(apartment.createdAt.toDate()),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildGuestItem(BuildContext context, Guest guest) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.secondary,
          size: 20.w,
        ),
      ),
      title: Text(
        guest.name,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        guest.phone,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Text(
        FormatUtils.formatDate(guest.createdAt.toDate()),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}