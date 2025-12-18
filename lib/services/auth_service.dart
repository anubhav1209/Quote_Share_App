import 'package:flutter/foundation.dart';

/// Mock Authentication Service
/// Accepts any 6-digit OTP for development/testing
/// User sessions are managed via Firestore
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  String? _currentPhone;

  /// Get current user ID (generated on sign-in)
  String? get currentUserId => _currentUserId;

  /// Get current user's phone number
  String? get currentPhone => _currentPhone;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Send OTP to phone number (Mock - always succeeds)
  Future<bool> sendOTP(String phone) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In real app, this would call SMS API
    // For mock: always return success
    return phone.length == 10;
  }

  /// Verify OTP code (Mock - accepts any 6-digit code)
  Future<bool> verifyOTP(String otp, String phone) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Accept any 6-digit OTP
    if (otp.length == 6) {
      // Generate a mock user ID based on phone number
      _currentUserId = 'user_${phone}_${DateTime.now().millisecondsSinceEpoch}';
      _currentPhone = phone;
      debugPrint(
        '✅ AuthService: Generated UID: $_currentUserId for phone: $phone',
      );
      return true;
    }
    return false;
  }

  /// Check if user is new (first time login)
  Future<bool> isNewUser(String phone) async {
    // For mock: always treat as new user on first OTP verification
    return _currentUserId == null;
  }

  /// Sign out current user
  Future<void> signOut() async {
    _currentUserId = null;
    _currentPhone = null;
  }

  /// Restore session (called on app startup)
  void restoreSession(String userId, String phone) {
    _currentUserId = userId;
    _currentPhone = phone;
  }
}
