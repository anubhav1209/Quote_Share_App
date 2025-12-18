import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../widgets/otp_input_field.dart';
import 'purpose_selection_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-send OTP
    _authService.sendOTP(widget.phoneNumber);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    setState(() => _isVerifying = true);

    try {
      await _authService.sendOTP(widget.phoneNumber);
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isVerifying = true);

    try {
      final success = await _authService.verifyOTP(otp, widget.phoneNumber);

      if (success && mounted) {
        // Update user provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signIn(widget.phoneNumber);

        // Navigate to purpose selection
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PurposeSelectionScreen()),
          );
        }
      } else if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // OTP Input
              OtpInputField(onCompleted: _verifyOtp),

              const SizedBox(height: 32),

              // Timer and Resend
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend OTP in $_secondsRemaining seconds',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      )
                    : TextButton(
                        onPressed: _isVerifying ? null : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Change Phone Number
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Change Phone Number',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),

              const Spacer(),

              // Loading indicator
              if (_isVerifying)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                      SizedBox(height: 16),
                      Text(
                        'Verifying...',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              // Helper text
              if (!_isVerifying)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'For demo: Enter any 6-digit code',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
