import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/common/loading_widget.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedType = TransactionType.income;
  String _selectedCategory = TransactionCategory.rent;
  String _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  String? _receiptUrl;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {});

    try {
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text);

      // For demo purposes, using a dummy apartment ID
      // In real app, this would be selected from user's apartments
      final dummyApartmentId = 'dummy_apartment_id';

      await ref.read(financeProvider.notifier).addTransaction(
            type: _selectedType,
            category: _selectedCategory,
            description: description,
            amount: amount,
            date: _selectedDate,
            apartmentId: dummyApartmentId,
            paymentMethod: _selectedPaymentMethod,
            receiptUrl: _receiptUrl,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: LoadingOverlay(
        isLoading: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type
                Text(
                  'Transaction Type',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Income'),
                        value: TransactionType.income,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            _selectedCategory = TransactionCategory.rent;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Expense'),
                        value: TransactionType.expense,
                        groupValue: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            _selectedCategory = TransactionCategory.utilities;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Amount and Date
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: ValidationUtils.validateAmount,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            FormatUtils.formatDate(_selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    return ValidationUtils.validateRequired(value, 'Description');
                  },
                ),

                SizedBox(height: 16.h),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: (_selectedType == TransactionType.income
                          ? TransactionCategory.incomeCategories
                          : TransactionCategory.expenseCategories)
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),

                SizedBox(height: 16.h),

                // Payment Method
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method *',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items: TransactionCategory.paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(_getPaymentMethodDisplayName(method)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),

                SizedBox(height: 24.h),

                // Receipt Upload
                Text(
                  'Receipt',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Upload Receipt',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Optional: Add a receipt image or document',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement receipt upload
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receipt upload coming soon')),
                          );
                        },
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Choose File'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('Add Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case TransactionCategory.rent:
        return 'Rent Payment';
      case TransactionCategory.deposit:
        return 'Security Deposit';
      case TransactionCategory.otherIncome:
        return 'Other Income';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.maintenance:
        return 'Maintenance';
      case TransactionCategory.repairs:
        return 'Repairs';
      case TransactionCategory.staff:
        return 'Staff Salary';
      case TransactionCategory.taxes:
        return 'Taxes';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.otherExpense:
        return 'Other Expense';
      default:
        return category;
    }
  }

  String _getPaymentMethodDisplayName(String method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bank:
        return 'Bank Transfer';
      case PaymentMethod.online:
        return 'Online Payment';
      case PaymentMethod.check:
        return 'Check';
      default:
        return method;
    }
  }
}