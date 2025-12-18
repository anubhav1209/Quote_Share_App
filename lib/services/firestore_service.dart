import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Firestore Database Service
/// Handles all database operations for users and quotes
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _db.collection('users');

  /// Save or update user profile
  Future<void> saveUser(String uid, UserModel user) async {
    try {
      debugPrint('🔥 Firestore: Attempting to save user $uid');
      debugPrint('📝 Data: ${user.toJson()}');
      await _usersCollection.doc(uid).set(user.toJson());
      debugPrint('✅ Firestore: User saved successfully!');
    } catch (e) {
      debugPrint('❌ Firestore Error: $e');
      rethrow;
    }
  }

  /// Get user profile by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Update specific user fields
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _usersCollection.doc(uid).update(updates);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  /// Stream user profile changes
  Stream<UserModel?> userStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking user existence: $e');
      return false;
    }
  }
}
