import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_service.dart';
import '../../data/mock_data.dart';

/// Centralized Firestore service managing collections for VertexHand HRM.
class FirestoreService {
  FirestoreService();

  FirebaseFirestore? get _db => FirebaseService.firestore;
  bool get isAvailable => FirebaseService.isInitialized && _db != null;

  // Collection references
  CollectionReference<Map<String, dynamic>>? get _users =>
      _db?.collection('users');
  CollectionReference<Map<String, dynamic>>? get _attendance =>
      _db?.collection('attendance');
  CollectionReference<Map<String, dynamic>>? get _outwork =>
      _db?.collection('outwork_requests');
  CollectionReference<Map<String, dynamic>>? get _leaves =>
      _db?.collection('leave_requests');
  CollectionReference<Map<String, dynamic>>? get _expenses =>
      _db?.collection('expenses');
  CollectionReference<Map<String, dynamic>>? get _tasks =>
      _db?.collection('tasks');
  CollectionReference<Map<String, dynamic>>? get _notifications =>
      _db?.collection('notifications');

  // =========================================================================
  // User Profile
  // =========================================================================

  /// Stream of user document from `users/{userId}`.
  Stream<DocumentSnapshot<Map<String, dynamic>>?> streamUser(String userId) {
    if (!isAvailable || _users == null) {
      return Stream.value(null);
    }
    return _users!.doc(userId).snapshots();
  }

  /// Get user document data once.
  Future<Map<String, dynamic>?> getUser(String userId) async {
    if (!isAvailable || _users == null) return null;
    try {
      final doc = await _users!.doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] getUser error: $e');
      return null;
    }
  }

  /// Update user profile fields (including avatar URL from Cloudinary).
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    if (!isAvailable || _users == null) {
      debugPrint('ℹ️ [FirestoreService] Mock updated profile: $data');
      return;
    }
    try {
      await _users!.doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] updateUserProfile error: $e');
      rethrow;
    }
  }

  /// Save new Cloudinary avatar URL for user.
  Future<void> updateAvatarUrl(String userId, String avatarUrl) async {
    return updateUserProfile(userId, {
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================================
  // Attendance & Outwork
  // =========================================================================

  /// Record a clock-in punch in Firestore.
  Future<String?> recordClockIn({
    required String userId,
    required bool isOutwork,
    required String location,
    String clientName = '',
  }) async {
    if (!isAvailable || _attendance == null) {
      debugPrint('ℹ️ [FirestoreService] Mock Clock In recorded ($location, isOutwork: $isOutwork)');
      return 'mock_att_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final doc = await _attendance!.add({
        'userId': userId,
        'clockInTime': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'isOutwork': isOutwork,
        'location': location,
        'clientName': clientName,
        'status': 'clocked_in',
        'seconds': 0,
      });
      return doc.id;
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] recordClockIn error: $e');
      return null;
    }
  }

  /// Record a clock-out punch.
  Future<void> recordClockOut({
    required String attendanceId,
    required int totalSeconds,
  }) async {
    if (!isAvailable || _attendance == null) return;
    try {
      await _attendance!.doc(attendanceId).update({
        'clockOutTime': FieldValue.serverTimestamp(),
        'status': 'completed',
        'seconds': totalSeconds,
      });
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] recordClockOut error: $e');
    }
  }

  /// Create an Outwork / Field Duty formal request.
  Future<String?> createOutworkRequest({
    required String userId,
    required String userName,
    required String category,
    required String clientName,
    required String location,
    required String schedule,
    required String reason,
    String? proofImageUrl, // Cloudinary photo URL
  }) async {
    if (!isAvailable || _outwork == null) {
      debugPrint('ℹ️ [FirestoreService] Mock Outwork Request: $category at $clientName');
      return 'mock_outwork_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final doc = await _outwork!.add({
        'userId': userId,
        'userName': userName,
        'category': category,
        'clientName': clientName,
        'location': location,
        'schedule': schedule,
        'reason': reason,
        'status': 'Pending',
        'proofImageUrl': proofImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] createOutworkRequest error: $e');
      return null;
    }
  }

  /// Stream of pending outwork requests for manager approvals.
  Stream<QuerySnapshot<Map<String, dynamic>>?> streamOutworkRequests() {
    if (!isAvailable || _outwork == null) return Stream.value(null);
    return _outwork!.orderBy('createdAt', descending: true).snapshots();
  }

  // =========================================================================
  // Leave Requests
  // =========================================================================

  /// Submit a leave application.
  Future<String?> createLeaveRequest({
    required String userId,
    required String userName,
    required String leaveType,
    required String dates,
    required String length,
    required String reason,
  }) async {
    if (!isAvailable || _leaves == null) {
      debugPrint('ℹ️ [FirestoreService] Mock Leave Request: $leaveType for $dates');
      return 'mock_leave_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final doc = await _leaves!.add({
        'userId': userId,
        'userName': userName,
        'leaveType': leaveType,
        'dates': dates,
        'length': length,
        'reason': reason,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] createLeaveRequest error: $e');
      return null;
    }
  }

  // =========================================================================
  // Expenses & Receipts (Cloudinary Integration)
  // =========================================================================

  /// Submit an expense claim with optional Cloudinary receipt image URL.
  Future<String?> createExpenseClaim({
    required String userId,
    required String title,
    required String category,
    required int amount,
    required String date,
    String? receiptImageUrl, // Cloudinary secure URL
  }) async {
    if (!isAvailable || _expenses == null) {
      debugPrint('ℹ️ [FirestoreService] Mock Expense Claim: $title (৳$amount)');
      return 'mock_exp_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final doc = await _expenses!.add({
        'userId': userId,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date,
        'status': 'Pending',
        'receiptImageUrl': receiptImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] createExpenseClaim error: $e');
      return null;
    }
  }

  /// Stream employee expense claims.
  Stream<QuerySnapshot<Map<String, dynamic>>?> streamExpenses(String userId) {
    if (!isAvailable || _expenses == null) return Stream.value(null);
    return _expenses!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =========================================================================
  // Tasks
  // =========================================================================

  /// Stream tasks for a user.
  Stream<QuerySnapshot<Map<String, dynamic>>?> streamTasks(String userId) {
    if (!isAvailable || _tasks == null) return Stream.value(null);
    return _tasks!.where('userId', isEqualTo: userId).snapshots();
  }

  /// Toggle task completion.
  Future<void> toggleTask(String taskId, bool isDone) async {
    if (!isAvailable || _tasks == null) return;
    try {
      await _tasks!.doc(taskId).update({'done': isDone});
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] toggleTask error: $e');
    }
  }

  // =========================================================================
  // Notifications
  // =========================================================================

  /// Stream notifications for a user.
  Stream<QuerySnapshot<Map<String, dynamic>>?> streamNotifications(String userId) {
    if (!isAvailable || _notifications == null) return Stream.value(null);
    return _notifications!
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =========================================================================
  // Initial Seeding Helper
  // =========================================================================

  /// Automatically seeds Firestore with realistic VertexHand starter data
  /// on first launch so the database isn't empty.
  Future<void> seedInitialData(String userId, String name, String email) async {
    if (!isAvailable || _users == null) return;

    try {
      final userDoc = await _users!.doc(userId).get();
      if (!userDoc.exists) {
        await _users!.doc(userId).set({
          'id': userId,
          'name': name.isNotEmpty ? name : Mock.meName,
          'initials': Mock.meInitials,
          'email': email.isNotEmpty ? email : 'rahim@acme.com.bd',
          'role': 'Senior product designer',
          'dept': 'Design',
          'presence': 'inOffice',
          'status': 'You',
          'companyCode': 'ACME-DHK',
          'phone': '+880 1712 345678',
          'employeeId': 'ACME-0142',
          'avatarUrl': null, // Can be uploaded via Cloudinary
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ [FirestoreService] Seeded user profile for $userId');
      }
    } catch (e) {
      debugPrint('⚠️ [FirestoreService] seedInitialData error: $e');
    }
  }
}
