import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/user_provider.dart';
import '../services/permission_service.dart';
import 'upgrade_screen.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _permissionService = PermissionService();

  bool _showDate = true;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load current user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.user.name;
    _showDate = userProvider.user.showDate;
    _photoPath = userProvider.user.photoPath;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _permissionService.pickImage(source);
    if (file != null) {
      // Save to permanent storage
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await file.copy('${appDir.path}/$fileName');
        
        setState(() {
          _photoPath = savedImage.path;
        });
      } catch (e) {
        debugPrint('Error saving profile photo: $e');
        setState(() {
          _photoPath = file.path;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpgradeModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
    );
  }

  void _saveChanges() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    userProvider.updateUser(
      userProvider.user.copyWith(
        name: _nameController.text,
        photoPath: _photoPath,
        showDate: _showDate,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildLockedField(String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: _showUpgradeModal,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({required bool isBusiness}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo upload
          Center(
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _photoPath != null && File(_photoPath!).existsSync()
                        ? FileImage(File(_photoPath!))
                        : null,
                    child: _photoPath == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6A1B9A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Name input (always editable)
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Show date toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 16),
                    Text('Show Date on Quote', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Switch(
                  value: _showDate,
                  onChanged: (value) {
                    setState(() {
                      _showDate = value;
                    });
                  },
                  activeTrackColor: const Color(0xFF6A1B9A),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Locked fields section
          const Text(
            'Premium Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildLockedField(
            'About Yourself',
            'Add a personal tagline',
            Icons.info_outline,
          ),

          _buildLockedField(
            'Contact Details',
            'Add phone, email, website',
            Icons.contact_phone,
          ),

          if (isBusiness) ...[
            _buildLockedField(
              'Organization Details',
              'Add company name, address',
              Icons.business,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'PERSONAL'),
            Tab(text: 'BUSINESS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(isBusiness: false),
          _buildTabContent(isBusiness: true),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SAVE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
