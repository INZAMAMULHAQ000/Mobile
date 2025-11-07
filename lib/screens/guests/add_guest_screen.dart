import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/guest.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/guest_provider.dart';
import '../../widgets/common/loading_widget.dart';

class AddGuestScreen extends ConsumerStatefulWidget {
  final Guest? guest;

  const AddGuestScreen({
    super.key,
    this.guest,
  });

  @override
  ConsumerState<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends ConsumerState<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String? _idProofUrl;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.guest != null) {
      final guest = widget.guest!;
      _nameController.text = guest.name;
      _phoneController.text = guest.phone;
      _emailController.text = guest.email ?? '';
      _addressController.text = guest.address ?? '';
      _idProofUrl = guest.idProofUrl;
      _photoUrl = guest.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final address = _addressController.text.trim();

      if (widget.guest == null) {
        // Add new guest
        await ref.read(guestProvider.notifier).addGuest(
              name: name,
              phone: phone,
              email: email.isEmpty ? null : email,
              address: address.isEmpty ? null : address,
              idProofUrl: _idProofUrl,
              photoUrl: _photoUrl,
            );
      } else {
        // Update existing guest
        await ref.read(guestProvider.notifier).updateGuest(
              guestId: widget.guest!.id,
              name: name,
              phone: phone,
              email: email.isEmpty ? null : email,
              address: address.isEmpty ? null : address,
              idProofUrl: _idProofUrl,
              photoUrl: _photoUrl,
              apartmentId: widget.guest!.apartmentId,
              roomId: widget.guest!.roomId,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.guest == null
                ? 'Guest added successfully'
                : 'Guest updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.guest == null ? 'add' : 'update'} guest: ${e.toString()}'),
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
    final isEditing = widget.guest != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Guest' : 'Add Guest'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGuest,
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
                // Photo Section
                _buildPhotoSection(context),

                SizedBox(height: 24.h),

                // Personal Information
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: ValidationUtils.validateName,
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: ValidationUtils.validatePhone,
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return ValidationUtils.validateEmail(value);
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _addressController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  enabled: !_isLoading,
                ),

                SizedBox(height: 24.h),

                // Documents Section
                Text(
                  'Documents',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                _buildDocumentSection(context, 'ID Proof', _idProofUrl, (url) {
                  setState(() {
                    _idProofUrl = url;
                  });
                }),

                SizedBox(height: 16.h),

                // Additional Information
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
                            'Next Steps',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'After adding the guest, you can create a rental contract and assign them to a specific apartment and room.',
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
                    onPressed: _isLoading ? null : _saveGuest,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: _isLoading
                        ? const LoadingWidget()
                        : Text(isEditing ? 'Update Guest' : 'Add Guest'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Implement photo upload
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo upload coming soon')),
              );
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _photoUrl == null
                      ? Icon(
                          Icons.camera_alt_outlined,
                          size: 40.w,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16.r,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.edit,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap to add photo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(
    BuildContext context,
    String title,
    String? documentUrl,
    Function(String?) onDocumentChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            documentUrl != null ? Icons.check_circle : Icons.cloud_upload_outlined,
            color: documentUrl != null ? Colors.green : Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  documentUrl != null ? 'Document uploaded' : 'Tap to upload document',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: documentUrl != null
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (documentUrl != null)
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                // TODO: Implement document viewer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document viewer coming soon')),
                );
              },
            ),
          TextButton(
            onPressed: () {
              // TODO: Implement document upload
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document upload coming soon')),
              );
            },
            child: Text(documentUrl != null ? 'Change' : 'Upload'),
          ),
        ],
      ),
    );
  }
}