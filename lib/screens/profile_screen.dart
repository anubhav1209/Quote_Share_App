import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'edit_screen.dart';
import 'welcome_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<File>> _loadSavedQuotes() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final quotesDir = Directory('${appDir.path}/saved_quotes');

      if (!await quotesDir.exists()) {
        return [];
      }

      final files = quotesDir
          .listSync()
          .where((item) => item is File && item.path.endsWith('.png'))
          .map((item) => item as File)
          .toList();

      // Sort by recent first
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      return files;
    } catch (e) {
      return [];
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              await userProvider.signOut();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        user.photoPath != null &&
                            File(user.photoPath!).existsSync()
                        ? FileImage(File(user.photoPath!))
                        : null,
                    child: user.photoPath == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF6A1B9A),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name.isEmpty ? 'Guest User' : user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.phone,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // Account type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.accountType == AccountType.personal
                              ? Icons.person
                              : Icons.business,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.accountType == AccountType.personal
                              ? 'Personal'
                              : 'Business',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('EDIT PROFILE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('LOGOUT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Downloaded quotes section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Downloaded Quotes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Secret verification button
                      GestureDetector(
                        onDoubleTap: () => _showVerificationDialog(context),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Load and display saved quotes
                  FutureBuilder<List<File>>(
                    future: _loadSavedQuotes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6A1B9A),
                          ),
                        );
                      }

                      final savedQuotes = snapshot.data ?? [];

                      if (savedQuotes.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No quotes downloaded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Download quotes from the main screen',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Display saved quotes in a grid
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: savedQuotes.length > 6
                            ? 6
                            : savedQuotes.length,
                        itemBuilder: (context, index) {
                          final file = savedQuotes[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(file, fit: BoxFit.cover),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const Text(
                    'Suvichar v1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.code, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Developed by ANUBHAV KUMAR',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '© 2025 All Rights Reserved',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Ownership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter secret code to verify official status:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Secret Code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text == '11508') {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Verified: ANUBHAV KUMAR (Owner)'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Access Denied: Incorrect Code'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
