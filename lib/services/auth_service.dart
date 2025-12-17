// Mock authentication service - accepts any 6-digit OTP
class AuthService {
  // Mock OTP sending
  Future<bool> sendOTP(String phone) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In real app, this would call backend API
    // For mock: always return success
    return phone.length == 10;
  }

  // Mock OTP verification - accepts any 6-digit code
  Future<bool> verifyOTP(String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Accept any 6-digit OTP
    return otp.length == 6;
  }

  // Mock backend would check if user exists
  Future<bool> isNewUser(String phone) async {
    // For mock: always treat as new user
    return true;
  }
}
