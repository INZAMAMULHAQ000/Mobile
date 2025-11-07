import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/color_utils.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/apartment/apartment_card.dart';
import 'add_apartment_screen.dart';

class ApartmentListScreen extends ConsumerStatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  ConsumerState<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends ConsumerState<ApartmentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Apartment> _filterApartments(List<Apartment> apartments) {
    if (_searchQuery.isEmpty) return apartments;

    return apartments.where((apartment) {
      final name = apartment.name.toLowerCase();
      final location = apartment.location.toLowerCase();
      final description = apartment.description?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          location.contains(query) ||
          description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final apartmentsAsync = ref.watch(apartmentProvider);
    final canManage = ref.watch(canManageApartmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.apartments),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(apartmentProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppConstants.defaultPadding.w),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search apartments...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Apartments List
          Expanded(
            child: apartmentsAsync.when(
              data: (apartments) {
                final filteredApartments = _filterApartments(apartments);

                if (filteredApartments.isEmpty) {
                  return _buildEmptyState(_searchQuery.isNotEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(apartmentProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding.w),
                    itemCount: filteredApartments.length,
                    itemBuilder: (context, index) {
                      final apartment = filteredApartments[index];
                      return ApartmentCard(
                        apartment: apartment,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/apartments/${apartment.id}',
                            arguments: apartment,
                          );
                        },
                        onEdit: canManage
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddApartmentScreen(
                                      apartment: apartment,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        onDelete: canManage
                            ? () => _showDeleteConfirmation(apartment)
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () => const FullScreenLoading(message: 'Loading apartments...'),
              error: (error, stackTrace) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.read(apartmentProvider.notifier).refresh();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddApartmentScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.apartment_outlined,
            size: 100.w,
            color: Colors.grey,
          ),
          SizedBox(height: 24.h),
          Text(
            isSearchResult ? 'No apartments found' : 'No apartments yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearchResult
                ? 'Try adjusting your search criteria'
                : 'Add your first apartment to get started',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isSearchResult) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddApartmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Apartment'),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Apartment apartment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Apartment'),
        content: Text(
          'Are you sure you want to delete "${apartment.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(apartmentProvider.notifier).deleteApartment(apartment.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apartment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete apartment: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}