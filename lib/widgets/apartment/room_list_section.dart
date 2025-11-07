import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/room.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/color_utils.dart';
import '../../core/utils/format_utils.dart';
import '../../providers/apartment_provider.dart';

class RoomListSection extends ConsumerWidget {
  final String apartmentId;
  final bool canManage;

  const RoomListSection({
    super.key,
    required this.apartmentId,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsForApartmentProvider(apartmentId));

    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Rooms',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              if (canManage)
                TextButton.icon(
                  onPressed: () {
                    _showAddRoomDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Room'),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Rooms List
          roomsAsync.when(
            data: (rooms) {
              if (rooms.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: [
                  // Filter chips
                  _buildFilterChips(context, rooms),

                  SizedBox(height: 16.h),

                  // Room cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return RoomCard(
                        room: room,
                        onEdit: canManage
                            ? () => _showEditRoomDialog(context, ref, room)
                            : null,
                        onStatusChange: canManage
                            ? (newStatus) => _updateRoomStatus(ref, room, newStatus)
                            : null,
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Container(
              padding: EdgeInsets.all(32.w),
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
                      'Failed to load rooms: ${error.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No rooms added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            canManage
                ? 'Add your first room to get started'
                : 'No rooms available for this apartment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (canManage) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                _showAddRoomDialog(context, ref.read(ref));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Room'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, List<Room> rooms) {
    final statuses = ['all', 'vacant', 'occupied', 'maintenance'];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: statuses.map((status) {
        final count = status == 'all'
            ? rooms.length
            : rooms.where((room) => room.status == status).length;

        return FilterChip(
          label: Text('$status ($count)'),
          selected: false,
          onSelected: (_) {},
        );
      }).toList(),
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => RoomDialog(
        apartmentId: apartmentId,
        onSave: (roomData) async {
          try {
            await ref.read(roomProvider.notifier).addRoom(
                  apartmentId: apartmentId,
                  roomNumber: roomData['roomNumber'],
                  floor: roomData['floor'],
                  rentAmount: roomData['rentAmount'],
                  status: roomData['status'],
                );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to add room: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditRoomDialog(BuildContext context, WidgetRef ref, Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomDialog(
        apartmentId: apartmentId,
        room: room,
        onSave: (roomData) async {
          try {
            await ref.read(roomProvider.notifier).updateRoom(
                  roomId: room.id,
                  apartmentId: apartmentId,
                  roomNumber: roomData['roomNumber'],
                  floor: roomData['floor'],
                  rentAmount: roomData['rentAmount'],
                  status: roomData['status'],
                  currentGuestId: room.currentGuestId,
                );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update room: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _updateRoomStatus(WidgetRef ref, Room room, String newStatus) async {
    try {
      await ref.read(roomProvider.notifier).updateRoomStatus(
            roomId: room.id,
            status: newStatus,
            guestId: newStatus == 'vacant' ? null : room.currentGuestId,
          );
    } catch (e) {
      // Handle error silently or show a message
    }
  }
}

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onEdit;
  final Function(String)? onStatusChange;

  const RoomCard({
    super.key,
    required this.room,
    this.onEdit,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: ColorUtils.getStatusColor(room.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          room.status.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorUtils.getStatusColor(room.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Room ${room.roomNumber}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Details
            Row(
              children: [
                if (room.floor != null) ...[
                  Icon(
                    Icons.layers_outlined,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Floor ${room.floor}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
                Icon(
                  Icons.attach_money_outlined,
                  size: 16.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  FormatUtils.formatCurrency(room.rentAmount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Guest info if occupied
            if (room.hasGuest) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Occupied by guest',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],

            // Status change buttons
            if (onStatusChange != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  if (room.status != 'vacant')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusChange!('vacant'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                        child: const Text('Mark Vacant'),
                      ),
                    ),
                  if (room.status != 'occupied') ...[
                    if (room.status != 'vacant') SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusChange!('occupied'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                        child: const Text('Mark Occupied'),
                      ),
                    ),
                  ],
                  if (room.status != 'maintenance') ...[
                    if (room.status != 'vacant' && room.status != 'occupied') SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onStatusChange!('maintenance'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                        child: const Text('Mark Maintenance'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RoomDialog extends StatefulWidget {
  final String apartmentId;
  final Room? room;
  final Function(Map<String, dynamic>) onSave;

  const RoomDialog({
    super.key,
    required this.apartmentId,
    this.room,
    required this.onSave,
  });

  @override
  State<RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<RoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _rentAmountController = TextEditingController();
  String _selectedStatus = 'vacant';

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      final room = widget.room!;
      _roomNumberController.text = room.roomNumber;
      _floorController.text = room.floor ?? '';
      _rentAmountController.text = room.rentAmount.toString();
      _selectedStatus = room.status;
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _rentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Room' : 'Add Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _roomNumberController,
              decoration: const InputDecoration(
                labelText: 'Room Number *',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Room number is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(
                labelText: 'Floor',
                prefixIcon: Icon(Icons.layers_outlined),
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _rentAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rent Amount *',
                prefixIcon: Icon(Icons.attach_money_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Rent amount is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'vacant', child: Text('Vacant')),
                DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'roomNumber': _roomNumberController.text.trim(),
                'floor': _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
                'rentAmount': double.parse(_rentAmountController.text),
                'status': _selectedStatus,
              });
            }
          },
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}