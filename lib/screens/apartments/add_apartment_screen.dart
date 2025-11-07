import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/apartment.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/apartment_provider.dart';
import '../../widgets/common/loading_widget.dart';

class AddApartmentScreen extends ConsumerStatefulWidget {
  final Apartment? apartment;

  const AddApartmentScreen({
    super.key,
    this.apartment,
  });

  @override
  ConsumerState<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends ConsumerState<AddApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalRoomsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.apartment != null) {
      final apartment = widget.apartment!;
      _nameController.text = apartment.name;
      _locationController.text = apartment.location;
      _descriptionController.text = apartment.description ?? '';
      _totalRoomsController.text = apartment.totalRooms.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _totalRoomsController.dispose();
    super.dispose();
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();
      final totalRooms = int.parse(_totalRoomsController.text);

      if (widget.apartment == null) {
        // Add new apartment
        await ref.read(apartmentProvider.notifier).addApartment(
              name: name,
              location: location,
              description: description.isEmpty ? null : description,
              totalRooms: totalRooms,
            );
      } else {
        // Update existing apartment
        await ref.read(apartmentProvider.notifier).updateApartment(
              apartmentId: widget.apartment!.id,
              name: name,
              location: location,
              description: description.isEmpty ? null : description,
              totalRooms: totalRooms,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.apartment == null
                ? 'Apartment added successfully'
                : 'Apartment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.apartment == null ? 'add' : 'update'} apartment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.apartment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Apartment' : 'Add Apartment'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveApartment,
            child: _isLoading
                ? const LoadingWidget()
                : Text(isEditing ? 'Update' : 'Save'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Apartment Name
                Text(
                  'Apartment Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Apartment Name *',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  validator: ValidationUtils.validateName,
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: ValidationUtils.validateLocation,
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _totalRoomsController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Total Rooms *',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                  validator: (value) {
                    return ValidationUtils.validateNumber(
                      value,
                      fieldName: 'Total rooms',
                      min: 1,
                      allowZero: false,
                    );
                  },
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: ValidationUtils.validateDescription,
                  enabled: !_isLoading,
                  onFieldSubmitted: (_) => _saveApartment(),
                ),

                SizedBox(height: 32.h),

                // Additional Information
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Note',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'After creating an apartment, you can add individual rooms with specific details like room numbers, floor, and rent amounts.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApartment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: _isLoading
                        ? const LoadingWidget()
                        : Text(isEditing ? 'Update Apartment' : 'Add Apartment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}