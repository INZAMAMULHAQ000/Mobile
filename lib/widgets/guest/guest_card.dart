import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/guest.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/color_utils.dart';

class GuestCard extends StatelessWidget {
  final Guest guest;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GuestCard({
    super.key,
    required this.guest,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Guest Photo
              CircleAvatar(
                radius: 32.r,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: guest.hasPhoto
                    ? CachedNetworkImageProvider(guest.photoUrl!)
                    : null,
                child: !guest.hasPhoto
                    ? Icon(
                        Icons.person,
                        size: 32.w,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),

              SizedBox(width: 16.w),

              // Guest Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            guest.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (guest.isAssignedToRoom)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Active',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Contact Information
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16.w,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            FormatUtils.formatPhoneNumber(guest.phone),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (guest.hasEmail) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16.w,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              guest.email!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Assignment Status
                    if (guest.isAssignedToRoom) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 16.w,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Assigned to room',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Document Status
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildDocumentIndicator(
                          context,
                          'ID Proof',
                          guest.hasIdProof,
                          Icons.badge_outlined,
                        ),
                        SizedBox(width: 16.w),
                        _buildDocumentIndicator(
                          context,
                          'Photo',
                          guest.hasPhoto,
                          Icons.camera_alt_outlined,
                        ),
                        const Spacer(),
                        Text(
                          'Added ${FormatUtils.formatDate(guest.createdAt.toDate())}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentIndicator(
    BuildContext context,
    String label,
    bool hasDocument,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          hasDocument ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16.w,
          color: hasDocument ? Colors.green : Colors.grey,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: hasDocument
                ? Colors.green
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}