import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/apartment.dart';
import '../models/room.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/validation_utils.dart';
import '../providers/auth_provider.dart';

class ApartmentNotifier extends StateNotifier<AsyncValue<List<Apartment>>> {
  final FirebaseService _firebaseService;
  final String _currentUserId;

  ApartmentNotifier(this._firebaseService, this._currentUserId)
      : super(const AsyncValue.loading()) {
    _loadApartments();
  }

  Future<void> _loadApartments() async {
    state = const AsyncValue.loading();

    try {
      final query = _firebaseService.getCollection(
        'apartments',
        query: FirebaseFirestore.instance
            .collection('apartments')
            .where('isActive', isEqualTo: true)
            .where('createdBy', isEqualTo: _currentUserId)
            .orderBy('createdAt', descending: true),
      );

      final snapshot = await query;
      final apartments = snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();

      state = AsyncValue.data(apartments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadApartments();
  }

  Future<String> addApartment({
    required String name,
    required String location,
    String? description,
    required int totalRooms,
  }) async {
    try {
      final apartment = Apartment(
        id: _firebaseService.generateId(),
        name: name,
        location: location,
        description: description,
        totalRooms: totalRooms,
        createdAt: _firebaseService.getCurrentTimestamp(),
        updatedAt: _firebaseService.getCurrentTimestamp(),
        createdBy: _currentUserId,
        isActive: true,
      );

      await _firebaseService.setDocument(
        'apartments',
        apartment.id,
        apartment.toFirestore(),
      );

      // Refresh the list
      await _loadApartments();

      return apartment.id;
    } catch (e) {
      throw Exception('Failed to add apartment: ${e.toString()}');
    }
  }

  Future<void> updateApartment({
    required String apartmentId,
    required String name,
    required String location,
    String? description,
    required int totalRooms,
  }) async {
    try {
      final updates = {
        'name': name,
        'location': location,
        'description': description,
        'totalRooms': totalRooms,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
      };

      await _firebaseService.updateDocument(
        'apartments',
        apartmentId,
        updates,
      );

      // Refresh the list
      await _loadApartments();
    } catch (e) {
      throw Exception('Failed to update apartment: ${e.toString()}');
    }
  }

  Future<void> deleteApartment(String apartmentId) async {
    try {
      // Soft delete by marking as inactive
      await _firebaseService.updateDocument(
        'apartments',
        apartmentId,
        {
          'isActive': false,
          'updatedAt': _firebaseService.getCurrentTimestamp(),
        },
      );

      // Refresh the list
      await _loadApartments();
    } catch (e) {
      throw Exception('Failed to delete apartment: ${e.toString()}');
    }
  }

  String? validateApartmentData({
    String? name,
    String? location,
    String? description,
    String? totalRoomsStr,
  }) {
    final nameError = ValidationUtils.validateName(name);
    if (nameError != null) return nameError;

    final locationError = ValidationUtils.validateLocation(location);
    if (locationError != null) return locationError;

    final descriptionError = ValidationUtils.validateDescription(description);
    if (descriptionError != null) return descriptionError;

    final totalRoomsError = ValidationUtils.validateNumber(
      totalRoomsStr,
      fieldName: 'Total rooms',
      min: 1,
      allowZero: false,
    );
    if (totalRoomsError != null) return totalRoomsError;

    return null;
  }
}

class RoomNotifier extends StateNotifier<AsyncValue<List<Room>>> {
  final FirebaseService _firebaseService;
  final String _currentUserId;

  RoomNotifier(this._firebaseService, this._currentUserId)
      : super(const AsyncValue.loading());

  Future<List<Room>> getRoomsForApartment(String apartmentId) async {
    try {
      final query = _firebaseService.getCollection(
        'rooms',
        query: FirebaseFirestore.instance
            .collection('rooms')
            .where('apartmentId', isEqualTo: apartmentId)
            .orderBy('roomNumber'),
      );

      final snapshot = await query;
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load rooms: ${e.toString()}');
    }
  }

  Future<String> addRoom({
    required String apartmentId,
    required String roomNumber,
    String? floor,
    required double rentAmount,
    String status = 'vacant',
  }) async {
    try {
      final room = Room(
        id: _firebaseService.generateId(),
        apartmentId: apartmentId,
        roomNumber: roomNumber,
        floor: floor,
        rentAmount: rentAmount,
        status: status,
        currentGuestId: null,
        createdAt: _firebaseService.getCurrentTimestamp(),
        updatedAt: _firebaseService.getCurrentTimestamp(),
      );

      await _firebaseService.setDocument(
        'rooms',
        room.id,
        room.toFirestore(),
      );

      return room.id;
    } catch (e) {
      throw Exception('Failed to add room: ${e.toString()}');
    }
  }

  Future<void> updateRoom({
    required String roomId,
    required String apartmentId,
    required String roomNumber,
    String? floor,
    required double rentAmount,
    required String status,
    String? currentGuestId,
  }) async {
    try {
      final updates = {
        'roomNumber': roomNumber,
        'floor': floor,
        'rentAmount': rentAmount,
        'status': status,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
      };

      if (currentGuestId != null) {
        updates['currentGuestId'] = currentGuestId;
      }

      await _firebaseService.updateDocument(
        'rooms',
        roomId,
        updates,
      );
    } catch (e) {
      throw Exception('Failed to update room: ${e.toString()}');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _firebaseService.deleteDocument('rooms', roomId);
    } catch (e) {
      throw Exception('Failed to delete room: ${e.toString()}');
    }
  }

  Future<void> updateRoomStatus(String roomId, String status, {String? guestId}) async {
    try {
      final updates = {
        'status': status,
        'updatedAt': _firebaseService.getCurrentTimestamp(),
      };

      if (guestId != null) {
        updates['currentGuestId'] = guestId;
      } else {
        updates['currentGuestId'] = null;
      }

      await _firebaseService.updateDocument(
        'rooms',
        roomId,
        updates,
      );
    } catch (e) {
      throw Exception('Failed to update room status: ${e.toString()}');
    }
  }

  String? validateRoomData({
    String? roomNumber,
    String? floor,
    String? rentAmountStr,
  }) {
    final roomNumberError = ValidationUtils.validateRoomNumber(roomNumber);
    if (roomNumberError != null) return roomNumberError;

    final rentAmountError = ValidationUtils.validateRentAmount(rentAmountStr);
    if (rentAmountError != null) return rentAmountError;

    return null;
  }

  Stream<List<Room>> watchRoomsForApartment(String apartmentId) {
    final query = FirebaseFirestore.instance
        .collection('rooms')
        .where('apartmentId', isEqualTo: apartmentId)
        .orderBy('roomNumber')
        .snapshots();

    return query.map((snapshot) =>
        snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }
}

// Providers
final apartmentProvider = StateNotifierProvider<ApartmentNotifier, AsyncValue<List<Apartment>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) throw Exception('User not authenticated');
  return ApartmentNotifier(firebaseService, currentUser.uid);
});

final roomProvider = StateNotifierProvider<RoomNotifier, AsyncValue<List<Room>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) throw Exception('User not authenticated');
  return RoomNotifier(firebaseService, currentUser.uid);
});

// Apartment details provider
final apartmentDetailsProvider = StreamProvider.family<Apartment, String>((ref, apartmentId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.documentStream('apartments', apartmentId).map((doc) {
    if (!doc.exists) throw Exception('Apartment not found');
    return Apartment.fromFirestore(doc);
  });
});

// Rooms for apartment provider
final roomsForApartmentProvider = StreamProvider.family<List<Room>, String>((ref, apartmentId) {
  final roomNotifier = ref.watch(roomProvider.notifier);
  return roomNotifier.watchRoomsForApartment(apartmentId);
});

// Apartment statistics provider
final apartmentStatsProvider = Provider.family<Map<String, int>, String>((ref, apartmentId) {
  final roomsAsync = ref.watch(roomsForApartmentProvider(apartmentId));

  return roomsAsync.when(
    data: (rooms) {
      final stats = <String, int>{
        'total': rooms.length,
        'vacant': 0,
        'occupied': 0,
        'maintenance': 0,
      };

      for (final room in rooms) {
        stats[room.status] = (stats[room.status] ?? 0) + 1;
      }

      return stats;
    },
    loading: () => {'total': 0, 'vacant': 0, 'occupied': 0, 'maintenance': 0},
    error: (_, __) => {'total': 0, 'vacant': 0, 'occupied': 0, 'maintenance': 0},
  );
});