import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel _user = UserModel(name: '', phone: '');
  bool _isAuthenticated = false;

  UserModel get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _authService.currentUserId;

  // Initialize user data from Firestore or local storage
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userPhone = prefs.getString('user_phone');
    final isAuth = prefs.getBool('is_authenticated') ?? false;

    if (userId != null && userPhone != null && isAuth) {
      // Restore auth session
      _authService.restoreSession(userId, userPhone);
      _isAuthenticated = true;

      // Try to load from Firestore
      final userData = await _firestoreService.getUser(userId);
      if (userData != null) {
        _user = userData;
      } else {
        // Fallback to local storage
        final userJson = prefs.getString('user_data');
        if (userJson != null) {
          _user = UserModel.fromJson(json.decode(userJson));
        }
      }
    } else {
      // No session - load from local storage only
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _user = UserModel.fromJson(json.decode(userJson));
      }
      _isAuthenticated = isAuth;
    }

    notifyListeners();
  }

  // Save user data to Firestore and local storage
  Future<void> saveUserData() async {
    final uid = _authService.currentUserId;

    debugPrint('💾 saveUserData called');
    debugPrint('🆔 User ID: $uid');
    debugPrint('👤 User data: ${_user.toJson()}');

    if (uid != null) {
      debugPrint('🔥 Saving to Firestore with UID: $uid');
      // Save to Firestore
      await _firestoreService.saveUser(uid, _user);
    } else {
      debugPrint('⚠️ UID is null! Skipping Firestore save');
    }

    // Also save locally for offline support
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(_user.toJson()));
    await prefs.setBool('is_authenticated', _isAuthenticated);

    // Save session info
    if (uid != null) {
      await prefs.setString('user_id', uid);
    }
    if (_authService.currentPhone != null) {
      await prefs.setString('user_phone', _authService.currentPhone!);
    }

    debugPrint('💿 Saved to local storage');
  }

  // Update user profile
  void updateUser(UserModel newUser) {
    _user = newUser;
    saveUserData();
    notifyListeners();
  }

  // Update specific fields
  void updateName(String name) {
    _user = _user.copyWith(name: name);
    saveUserData();
    notifyListeners();
  }

  void updatePhone(String phone) {
    _user = _user.copyWith(phone: phone);
    saveUserData();
    notifyListeners();
  }

  void updatePhoto(String photoPath) {
    _user = _user.copyWith(photoPath: photoPath);
    saveUserData();
    notifyListeners();
  }

  void toggleShowDate(bool value) {
    _user = _user.copyWith(showDate: value);
    saveUserData();
    notifyListeners();
  }

  // Authentication
  Future<bool> signIn(String phone) async {
    _user = _user.copyWith(phone: phone);
    _isAuthenticated = true;
    await saveUserData();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _user = UserModel(name: '', phone: '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // Onboarding
  void setAccountType(AccountType type) {
    _user = _user.copyWith(accountType: type);
    saveUserData();
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    String? photoPath,
    required AccountType accountType,
  }) async {
    debugPrint('📱 Completing onboarding for: $name');
    _user = _user.copyWith(
      name: name,
      photoPath: photoPath,
      accountType: accountType,
      isOnboardingComplete: true,
    );
    debugPrint('💾 Calling saveUserData...');
    await saveUserData();
    debugPrint('✅ Onboarding complete!');
    notifyListeners();
  }

  void skipOnboarding() {
    _user = _user.copyWith(isOnboardingComplete: true);
    saveUserData();
    notifyListeners();
  }
}
