import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../lib/main.dart';
import '../lib/core/constants/app_constants.dart';
import '../lib/core/utils/validation_utils.dart';
import '../lib/models/apartment.dart';
import '../lib/models/guest.dart';
import '../lib/models/user.dart';

void main() {
  group('Apartment Management App Tests', () {
    testWidgets('App should build without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: ApartmentManagementApp(),
        ),
      );

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('AppConstants should have correct values', () {
      expect(AppConstants.appName, 'Apartment Management');
      expect(AppConstants.appVersion, '1.0.0');
      expect(AppConstants.minPasswordLength, 8);
    });

    group('Validation Utils Tests', () {
      test('validateEmail should validate correctly', () {
        expect(ValidationUtils.validateEmail('test@example.com'), isNull);
        expect(ValidationUtils.validateEmail('invalid-email'), isNotNull);
        expect(ValidationUtils.validateEmail(''), isNotNull);
        expect(ValidationUtils.validateEmail(null), isNotNull);
      });

      test('validateName should validate correctly', () {
        expect(ValidationUtils.validateName('John Doe'), isNull);
        expect(ValidationUtils.validateName('J'), isNotNull);
        expect(ValidationUtils.validateName(''), isNotNull);
        expect(ValidationUtils.validateName(null), isNotNull);
      });

      test('validatePhone should validate correctly', () {
        expect(ValidationUtils.validatePhone('+1234567890'), isNull);
        expect(ValidationUtils.validatePhone('123'), isNotNull);
        expect(ValidationUtils.validatePhone(''), isNotNull);
        expect(ValidationUtils.validatePhone(null), isNotNull);
      });

      test('validateAmount should validate correctly', () {
        expect(ValidationUtils.validateAmount('100.50'), isNull);
        expect(ValidationUtils.validateAmount('0'), isNotNull);
        expect(ValidationUtils.validateAmount('-100'), isNotNull);
        expect(ValidationUtils.validateAmount('invalid'), isNotNull);
        expect(ValidationUtils.validateAmount(''), isNotNull);
        expect(ValidationUtils.validateAmount(null), isNotNull);
      });
    });

    group('Model Tests', () {
      test('User model should create correctly', () {
        final user = User(
          uid: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          role: 'admin',
          createdAt: Timestamp.now(),
          createdBy: 'test-uid',
        );

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, 'admin');
        expect(user.isAdmin, true);
        expect(user.isManager, false);
        expect(user.isViewer, false);
      });

      test('Apartment model should create correctly', () {
        final apartment = Apartment(
          id: 'test-id',
          name: 'Test Apartment',
          location: 'Test Location',
          totalRooms: 5,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          createdBy: 'test-uid',
        );

        expect(apartment.id, 'test-id');
        expect(apartment.name, 'Test Apartment');
        expect(apartment.location, 'Test Location');
        expect(apartment.totalRooms, 5);
        expect(apartment.isActive, true);
      });

      test('Guest model should create correctly', () {
        final guest = Guest(
          id: 'test-guest-id',
          name: 'Test Guest',
          phone: '+1234567890',
          email: 'guest@example.com',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          createdBy: 'test-uid',
        );

        expect(guest.id, 'test-guest-id');
        expect(guest.name, 'Test Guest');
        expect(guest.phone, '+1234567890');
        expect(guest.email, 'guest@example.com');
        expect(guest.hasEmail, true);
        expect(guest.isAssignedToRoom, false);
      });

      test('Guest equality should work correctly', () {
        final guest1 = Guest(
          id: 'same-id',
          name: 'Guest 1',
          phone: '123',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          createdBy: 'test-uid',
        );

        final guest2 = Guest(
          id: 'same-id',
          name: 'Guest 2',
          phone: '456',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          createdBy: 'test-uid',
        );

        expect(guest1 == guest2, true);
        expect(guest1.hashCode == guest2.hashCode, true);
      });
    });

    group('App Constants Tests', () {
      test('Transaction types should be correct', () {
        expect(TransactionType.income, 'income');
        expect(TransactionType.expense, 'expense');
      });

      test('Room statuses should be correct', () {
        expect(RoomStatus.vacant, 'vacant');
        expect(RoomStatus.occupied, 'occupied');
        expect(RoomStatus.maintenance, 'maintenance');
      });

      test('Contract statuses should be correct', () {
        expect(ContractStatus.active, 'active');
        expect(ContractStatus.expired, 'expired');
        expect(ContractStatus.terminated, 'terminated');
      });

      test('User roles should be correct', () {
        expect(UserRole.admin, 'admin');
        expect(UserRole.manager, 'manager');
        expect(UserRole.viewer, 'viewer');
      });
    });

    group('String Tests', () {
      test('App strings should not be empty', () {
        expect(AppStrings.appName.isNotEmpty, true);
        expect(AppStrings.login.isNotEmpty, true);
        expect(AppStrings.register.isNotEmpty, true);
        expect(AppStrings.dashboard.isNotEmpty, true);
        expect(AppStrings.apartments.isNotEmpty, true);
        expect(AppStrings.guests.isNotEmpty, true);
        expect(AppStrings.finance.isNotEmpty, true);
        expect(AppStrings.reports.isNotEmpty, true);
      });

      test('Error messages should be descriptive', () {
        expect(AppStrings.required.isNotEmpty, true);
        expect(AppStrings.invalidEmail.isNotEmpty, true);
        expect(AppStrings.passwordTooShort.isNotEmpty, true);
      });
    });
  });
}