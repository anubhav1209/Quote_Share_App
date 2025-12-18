import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../widgets/purpose_card.dart';
import 'profile_setup_screen.dart';

class PurposeSelectionScreen extends StatefulWidget {
  const PurposeSelectionScreen({super.key});

  @override
  State<PurposeSelectionScreen> createState() => _PurposeSelectionScreenState();
}

class _PurposeSelectionScreenState extends State<PurposeSelectionScreen> {
  AccountType? _selectedType;

  void _handleContinue() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an account type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save selection
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setAccountType(_selectedType!);

    // Navigate to profile setup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(accountType: _selectedType!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose Your Purpose',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Select how you\'ll use Suvichar',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Purpose Cards
              PurposeCard(
                icon: Icons.person,
                title: 'PERSONAL',
                description: 'Share quotes with friends and family',
                isSelected: _selectedType == AccountType.personal,
                onTap: () => setState(
                  () => _selectedType = AccountType.personal,
                ),
              ),
              const SizedBox(height: 20),
              PurposeCard(
                icon: Icons.business,
                title: 'BUSINESS',
                description: 'Promote your brand with custom quotes',
                isSelected: _selectedType == AccountType.business,
                onTap: () => setState(
                  () => _selectedType = AccountType.business,
                ),
              ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
               const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
