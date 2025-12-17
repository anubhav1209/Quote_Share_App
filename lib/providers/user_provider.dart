import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel(name: '', phone: '');
  bool _isAuthenticated = false;

  UserModel get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize user data from local storage
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    final isAuth = prefs.getBool('is_authenticated') ?? false;

    if (userJson != null) {
      _user = UserModel.fromJson(json.decode(userJson));
    }
    _isAuthenticated = isAuth;
    notifyListeners();
  }

  // Save user data to local storage
  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(_user.toJson()));
    await prefs.setBool('is_authenticated', _isAuthenticated);
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
    _user = _user.copyWith(
      name: name,
      photoPath: photoPath,
      accountType: accountType,
      isOnboardingComplete: true,
    );
    await saveUserData();
    notifyListeners();
  }

  void skipOnboarding() {
    _user = _user.copyWith(isOnboardingComplete: true);
    saveUserData();
    notifyListeners();
  }
}
