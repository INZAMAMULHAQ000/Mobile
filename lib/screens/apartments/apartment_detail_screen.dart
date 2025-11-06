import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ApartmentDetailScreen extends StatelessWidget {
  final String apartmentId;

  const ApartmentDetailScreen({
    super.key,
    required this.apartmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartment Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.apartment,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Apartment ID: $apartmentId',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apartment details coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}