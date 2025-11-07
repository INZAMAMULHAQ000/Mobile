import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/guest.dart';
import '../models/contract.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/validation_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/apartment_provider.dart';

class GuestNotifier extends StateNotifier<AsyncValue<List<Guest>>> {
  final FirebaseService _firebaseService;
  final String _currentUserId;

  GuestNotifier(this._firebaseService, this._currentUserId)
      : super(const AsyncValue.loading()) {
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    state = const AsyncValue.loading();

    try {
      final query = _firebaseService.getCollection(
        'guests',
        query: FirebaseFirestore.instance
            .collection('guests')
            .where('createdBy', isEqualTo: _currentUserId)
            .orderBy('createdAt', descending: true),
      );

      final snapshot = await query;
      final guests = snapshot.docs.map((doc) => Guest.fromFirestore(doc)).toList();

      state = AsyncValue.data(guests);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadGuests();
  }

  Future<String> addGuest({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? idProofUrl,
    String? photoUrl,
    String? apartmentId,
    String? roomId,
  }) async {
    try {
      final guest = Guest(
        id: _firebaseService.generateId(),
        name: name,
        phone: phone,
        email: email,
        address: address,
        idProofUrl: idProofUrl,
        photoUrl: photoUrl,
        apartmentId: apartmentId,
        roomId: roomId,
        createdAt: _firebaseService.getCurrentTimestamp(),
        updatedAt: _firebaseService.getCurrentTimestamp(),
        createdBy: _currentUserId,
      );

      await _firebaseService.setDocument(
        'guests',
        guest.id,
        guest.toFirestore(),
      );

      // Refresh the list
      await _loadGuests();

      return guest.id;
    } catch (e) {
      throw Exception('Failed to add guest: ${e.toString()}');
    }
  }

  Future<void> updateGuest({
    required String guestId,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? idProofUrl,
    String? photoUrl,
    String? apartmentId,
    String? roomId,
  }) async {
    try {
      final updates = {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'idProofUrl': idProofUrl,
        'photoUrl': photoUrl,
        'apartmentId': apartmentId,
        'roomId': roomId,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
      };

      await _firebaseService.updateDocument(
        'guests',
        guestId,
        updates,
      );

      // Refresh the list
      await _loadGuests();
    } catch (e) {
      throw Exception('Failed to update guest: ${e.toString()}');
    }
  }

  Future<void> deleteGuest(String guestId) async {
    try {
      await _firebaseService.deleteDocument('guests', guestId);

      // Refresh the list
      await _loadGuests();
    } catch (e) {
      throw Exception('Failed to delete guest: ${e.toString()}');
    }
  }

  Future<List<Guest>> searchGuests(String query) async {
    try {
      final guestsSnapshot = await _firebaseService.getCollection(
        'guests',
        query: FirebaseFirestore.instance
            .collection('guests')
            .where('createdBy', isEqualTo: _currentUserId)
            .orderBy('createdAt', descending: true),
      );

      final guests = guestsSnapshot.docs.map((doc) => Guest.fromFirestore(doc)).toList();

      if (query.isEmpty) return guests;

      final lowerQuery = query.toLowerCase();
      return guests.where((guest) {
        return guest.name.toLowerCase().contains(lowerQuery) ||
            guest.phone.contains(query) ||
            (guest.email?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search guests: ${e.toString()}');
    }
  }

  String? validateGuestData({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    final nameError = ValidationUtils.validateName(name);
    if (nameError != null) return nameError;

    final phoneError = ValidationUtils.validatePhone(phone);
    if (phoneError != null) return phoneError;

    final emailError = email != null && email.isNotEmpty ? ValidationUtils.validateEmail(email) : null;
    if (emailError != null) return emailError;

    return null;
  }
}

class ContractNotifier extends StateNotifier<AsyncValue<List<Contract>>> {
  final FirebaseService _firebaseService;
  final String _currentUserId;

  ContractNotifier(this._firebaseService, this._currentUserId)
      : super(const AsyncValue.loading());

  Future<List<Contract>> getContractsForGuest(String guestId) async {
    try {
      final query = _firebaseService.getCollection(
        'contracts',
        query: FirebaseFirestore.instance
            .collection('contracts')
            .where('guestId', isEqualTo: guestId)
            .orderBy('createdAt', descending: true),
      );

      final snapshot = await query;
      return snapshot.docs.map((doc) => Contract.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load contracts: ${e.toString()}');
    }
  }

  Future<String> addContract({
    required String guestId,
    required String apartmentId,
    required String roomId,
    required DateTime startDate,
    required DateTime endDate,
    required double rentAmount,
    required double depositAmount,
    String? contractDocUrl,
    String status = 'active',
  }) async {
    try {
      final contract = Contract(
        id: _firebaseService.generateId(),
        guestId: guestId,
        apartmentId: apartmentId,
        roomId: roomId,
        startDate: _firebaseService.getTimestampFromDateTime(startDate),
        endDate: _firebaseService.getTimestampFromDateTime(endDate),
        rentAmount: rentAmount,
        depositAmount: depositAmount,
        contractDocUrl: contractDocUrl,
        status: status,
        lastUpdatedBy: _currentUserId,
        createdAt: _firebaseService.getCurrentTimestamp(),
        updatedAt: _firebaseService.getCurrentTimestamp(),
      );

      await _firebaseService.setDocument(
        'contracts',
        contract.id,
        contract.toFirestore(),
      );

      // Update room status to occupied
      await _firebaseService.updateDocument(
        'rooms',
        roomId,
        {
          'status': 'occupied',
          'currentGuestId': guestId,
          'updatedAt': _firebaseService.getCurrentTimestamp(),
        },
      );

      return contract.id;
    } catch (e) {
      throw Exception('Failed to add contract: ${e.toString()}');
    }
  }

  Future<void> updateContract({
    required String contractId,
    required DateTime startDate,
    required DateTime endDate,
    required double rentAmount,
    required double depositAmount,
    String? contractDocUrl,
    String? status,
  }) async {
    try {
      final updates = {
        'startDate': _firebaseService.getTimestampFromDateTime(startDate),
        'endDate': _firebaseService.getTimestampFromDateTime(endDate),
        'rentAmount': rentAmount,
        'depositAmount': depositAmount,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
        'lastUpdatedBy': _currentUserId,
      };

      if (contractDocUrl != null) {
        updates['contractDocUrl'] = contractDocUrl;
      }

      if (status != null) {
        updates['status'] = status;
      }

      await _firebaseService.updateDocument(
        'contracts',
        contractId,
        updates,
      );
    } catch (e) {
      throw Exception('Failed to update contract: ${e.toString()}');
    }
  }

  Future<void> terminateContract(String contractId) async {
    try {
      // Get contract details first
      final contractDoc = await _firebaseService.getDocument('contracts', contractId);
      final contract = Contract.fromFirestore(contractDoc);

      await _firebaseService.updateDocument(
        'contracts',
        contractId,
        {
          'status': 'terminated',
          'updatedAt': _firebaseService.getCurrentTimestamp(),
          'lastUpdatedBy': _currentUserId,
        },
      );

      // Update room status to vacant
      await _firebaseService.updateDocument(
        'rooms',
        contract.roomId,
        {
          'status': 'vacant',
          'currentGuestId': null,
          'updatedAt': _firebaseService.getCurrentTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Failed to terminate contract: ${e.toString()}');
    }
  }

  Future<List<Contract>> getExpiringContracts({int days = 15}) async {
    try {
      final now = Timestamp.now();
      final futureDate = Timestamp.fromDate(
        DateTime.now().add(Duration(days: days)),
      );

      final query = _firebaseService.getCollection(
        'contracts',
        query: FirebaseFirestore.instance
            .collection('contracts')
            .where('endDate', '<=', futureDate)
            .where('endDate', '>=', now)
            .where('status', '==', 'active')
            .orderBy('endDate'),
      );

      final snapshot = await query;
      return snapshot.docs.map((doc) => Contract.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get expiring contracts: ${e.toString()}');
    }
  }

  String? validateContractData({
    DateTime? startDate,
    DateTime? endDate,
    String? rentAmountStr,
    String? depositAmountStr,
  }) {
    final dateError = ValidationUtils.validateEndAfterStart(startDate, endDate);
    if (dateError != null) return dateError;

    final rentError = ValidationUtils.validateRentAmount(rentAmountStr);
    if (rentError != null) return rentError;

    final depositError = ValidationUtils.validateNumber(
      depositAmountStr,
      fieldName: 'Deposit amount',
      min: 0,
      allowZero: true,
    );
    if (depositError != null) return depositError;

    return null;
  }

  Stream<List<Contract>> watchContractsForGuest(String guestId) {
    final query = FirebaseFirestore.instance
        .collection('contracts')
        .where('guestId', isEqualTo: guestId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return query.map((snapshot) =>
        snapshot.docs.map((doc) => Contract.fromFirestore(doc)).toList());
  }
}

// Providers
final guestProvider = StateNotifierProvider<GuestNotifier, AsyncValue<List<Guest>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) throw Exception('User not authenticated');
  return GuestNotifier(firebaseService, currentUser.uid);
});

final contractProvider = StateNotifierProvider<ContractNotifier, AsyncValue<List<Contract>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) throw Exception('User not authenticated');
  return ContractNotifier(firebaseService, currentUser.uid);
});

// Guest details provider
final guestDetailsProvider = StreamProvider.family<Guest, String>((ref, guestId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.documentStream('guests', guestId).map((doc) {
    if (!doc.exists) throw Exception('Guest not found');
    return Guest.fromFirestore(doc);
  });
});

// Contracts for guest provider
final contractsForGuestProvider = StreamProvider.family<List<Contract>, String>((ref, guestId) {
  final contractNotifier = ref.watch(contractProvider.notifier);
  return contractNotifier.watchContractsForGuest(guestId);
});

// Active contracts provider
final activeContractsProvider = Provider<List<Contract>>((ref) {
  final contractsAsync = ref.watch(contractProvider);

  return contractsAsync.when(
    data: (contracts) {
      return contracts.where((contract) => contract.isActive).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Expiring contracts provider
final expiringContractsProvider = FutureProvider<List<Contract>>((ref) async {
  final contractNotifier = ref.watch(contractProvider.notifier);
  return await contractNotifier.getExpiringContracts();
});