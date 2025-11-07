import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/guest/guest_card.dart';
import 'add_guest_screen.dart';

class GuestListScreen extends ConsumerStatefulWidget {
  const GuestListScreen({super.key});

  @override
  ConsumerState<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends ConsumerState<GuestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Guest> _allGuests = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Guest> _filterGuests(List<Guest> guests) {
    if (_searchQuery.isEmpty) return guests;

    final lowerQuery = _searchQuery.toLowerCase();
    return guests.where((guest) {
      return guest.name.toLowerCase().contains(lowerQuery) ||
          guest.phone.contains(_searchQuery) ||
          (guest.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestProvider);
    final canManage = ref.watch(canManageGuestsProvider);

    // Update all guests when data loads
    ref.listen<AsyncValue<List<Guest>>>(guestProvider, (_, state) {
      if (state.hasData && _searchQuery.isEmpty) {
        _allGuests = state.data!;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.guests),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(guestProvider.notifier).refresh();
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
              hintText: 'Search guests by name, phone, or email...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
                _searchController.clear();
              },
            ),
          ),

          // Guests List
          Expanded(
            child: guestsAsync.when(
              data: (guests) {
                if (_searchQuery.isEmpty) {
                  _allGuests = guests;
                }

                final filteredGuests = _filterGuests(_allGuests);

                if (filteredGuests.isEmpty) {
                  return _buildEmptyState(_searchQuery.isNotEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(guestProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding.w),
                    itemCount: filteredGuests.length,
                    itemBuilder: (context, index) {
                      final guest = filteredGuests[index];
                      return GuestCard(
                        guest: guest,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/guests/${guest.id}',
                            arguments: guest,
                          );
                        },
                        onEdit: canManage
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddGuestScreen(
                                      guest: guest,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        onDelete: canManage
                            ? () => _showDeleteConfirmation(guest)
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () => const FullScreenLoading(message: 'Loading guests...'),
              error: (error, stackTrace) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () {
                  ref.read(guestProvider.notifier).refresh();
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
                    builder: (context) => const AddGuestScreen(),
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
            isSearchResult ? Icons.search_off : Icons.people_outline,
            size: 100.w,
            color: Colors.grey,
          ),
          SizedBox(height: 24.h),
          Text(
            isSearchResult ? 'No guests found' : 'No guests yet',
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
                : 'Add your first guest to get started',
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
                    builder: (context) => const AddGuestScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Guest'),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Guest guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: Text(
          'Are you sure you want to delete "${guest.name}"? This action cannot be undone and will also remove all associated contracts.',
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
                await ref.read(guestProvider.notifier).deleteGuest(guest.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guest deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete guest: ${e.toString()}'),
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