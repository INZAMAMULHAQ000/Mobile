import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;
  final Logger _logger;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _logger = logger ?? Logger();

  // Firestore operations
  Future<DocumentSnapshot> getDocument(String collectionPath, String documentId) async {
    try {
      return await _firestore.collection(collectionPath).doc(documentId).get();
    } catch (e) {
      _logger.e('Error getting document: $e');
      rethrow;
    }
  }

  Future<QuerySnapshot> getCollection(
    String collectionPath, {
    Query? query,
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query queryRef = _firestore.collection(collectionPath);

      if (query != null) {
        queryRef = query;
      }

      if (orderBy != null) {
        queryRef = queryRef.orderBy(orderBy, descending: descending);
      }

      if (startAfter != null) {
        queryRef = queryRef.startAfterDocument(startAfter);
      }

      if (limit != null) {
        queryRef = queryRef.limit(limit);
      }

      return await queryRef.get();
    } catch (e) {
      _logger.e('Error getting collection: $e');
      rethrow;
    }
  }

  Future<DocumentReference> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      final docRef = _firestore.collection(collectionPath).doc(documentId);
      await docRef.set(data, SetOptions(merge: merge));
      return docRef;
    } catch (e) {
      _logger.e('Error setting document: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e) {
      _logger.e('Error updating document: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String collectionPath, String documentId) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(
              _firestore.collection(operation.collectionPath).doc(operation.documentId),
              operation.data!,
              SetOptions(merge: operation.merge ?? true),
            );
            break;
          case BatchOperationType.update:
            batch.update(
              _firestore.collection(operation.collectionPath).doc(operation.documentId),
              operation.data!,
            );
            break;
          case BatchOperationType.delete:
            batch.delete(_firestore.collection(operation.collectionPath).doc(operation.documentId));
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      _logger.e('Error in batch write: $e');
      rethrow;
    }
  }

  // Real-time listeners
  Stream<DocumentSnapshot> documentStream(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(
    String collectionPath, {
    Query? query,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    Query queryRef = _firestore.collection(collectionPath);

    if (query != null) {
      queryRef = query;
    }

    if (orderBy != null) {
      queryRef = queryRef.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      queryRef = queryRef.limit(limit);
    }

    return queryRef.snapshots();
  }

  // Storage operations
  Future<String> uploadFile(
    String filePath,
    String fileName,
    List<int> bytes, {
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child('$filePath/$fileName');
      final uploadTask = await ref.putData(
        bytes,
        metadata != null
            ? SettableMetadata(
                contentType: metadata['contentType'],
                customMetadata: metadata,
              )
            : null,
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      _logger.e('Error uploading file: $e');
      rethrow;
    }
  }

  Future<String> uploadFileFromData(
    String filePath,
    String fileName,
    dynamic data, {
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child('$filePath/$fileName');
      final uploadTask = await ref.putData(
        data,
        metadata != null
            ? SettableMetadata(
                contentType: metadata['contentType'],
                customMetadata: metadata,
              )
            : null,
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      _logger.e('Error uploading file from data: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      _logger.e('Error deleting file: $e');
      rethrow;
    }
  }

  Future<ListResult> listFiles(String filePath) async {
    try {
      return await _storage.ref().child(filePath).listAll();
    } catch (e) {
      _logger.e('Error listing files: $e');
      rethrow;
    }
  }

  // Cloud Functions
  Future<T> callFunction<T>(String functionName, {
    Map<String, dynamic>? parameters,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final httpsCallable = _functions.httpsCallable(functionName);
      final result = await httpsCallable.call(parameters);

      if (decoder != null) {
        return decoder(result.data);
      }

      return result.data as T;
    } on FirebaseFunctionsException catch (e) {
      _logger.e('Cloud function error: ${e.code} - ${e.message}');
      throw Exception('Cloud function error: ${e.message}');
    } catch (e) {
      _logger.e('Error calling cloud function: $e');
      rethrow;
    }
  }

  // Utility methods
  String generateId() {
    return _firestore.collection('temp').doc().id;
  }

  Timestamp getCurrentTimestamp() {
    return Timestamp.now();
  }

  DateTime getDateTimeFromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  Timestamp getTimestampFromDateTime(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  Future<void> testConnection() async {
    try {
      await _firestore.collection('test').doc('connection').get();
      _logger.i('Firestore connection successful');
    } catch (e) {
      _logger.e('Firestore connection failed: $e');
      rethrow;
    }
  }
}

class BatchOperation {
  final BatchOperationType type;
  final String collectionPath;
  final String documentId;
  final Map<String, dynamic>? data;
  final bool? merge;

  BatchOperation({
    required this.type,
    required this.collectionPath,
    required this.documentId,
    this.data,
    this.merge,
  });
}

enum BatchOperationType {
  set,
  update,
  delete,
}

// Provider for dependency injection
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});