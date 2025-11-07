import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/apartment.dart';
import '../../models/room.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/color_utils.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/apartment/room_list_section.dart';
import '../../widgets/apartment/apartment_info_section.dart';

class ApartmentDetailScreen extends ConsumerWidget {
  final String apartmentId;

  const ApartmentDetailScreen({
    super.key,
    required this.apartmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apartmentAsync = ref.watch(apartmentDetailsProvider(apartmentId));
    final canManage = ref.watch(canManageApartmentsProvider);

    return Scaffold(
      body: apartmentAsync.when(
        data: (apartment) => _buildContent(context, ref, apartment, canManage),
        loading: () => const FullScreenLoading(message: 'Loading apartment details...'),
        error: (error, stackTrace) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.refresh(apartmentDetailsProvider(apartmentId));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Apartment apartment, bool canManage) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200.h,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              apartment.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -50.w,
                    bottom: -50.h,
                    child: Icon(
                      Icons.apartment,
                      size: 200.w,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    left: 20.w,
                    bottom: 20.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white.withOpacity(0.9),
                              size: 16.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              apartment.location,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${apartment.totalRooms} rooms',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (canManage) ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/apartments/edit',
                    arguments: apartment,
                  );
                },
              ),
            ],
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Apartment Info Section
              ApartmentInfoSection(apartment: apartment),

              // Rooms Section
              RoomListSection(apartmentId: apartment.id, canManage: canManage),

              // Bottom padding
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}