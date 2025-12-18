import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PermissionService {
  final ImagePicker _picker = ImagePicker();

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check if already granted
      if (await Permission.storage.isGranted || await Permission.photos.isGranted) {
        return true;
      }

      // Request both permissions (covers Android < 13 and 13+)
      final statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();

      if (statuses[Permission.storage]!.isGranted || statuses[Permission.photos]!.isGranted) {
        return true;
      }

      // Handle permanently denied
      if (statuses[Permission.storage]!.isPermanentlyDenied || statuses[Permission.photos]!.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true; // iOS handles automatically
  }

  // Pick image from camera
  Future<File?> pickFromCamera() async {
    if (!await requestCameraPermission()) {
      return null;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    return image != null ? File(image.path) : null;
  }

  // Pick image from gallery
  Future<File?> pickFromGallery() async {
    if (!await requestStoragePermission()) {
      return null;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    return image != null ? File(image.path) : null;
  }

  // Show image source selection dialog
  Future<File?> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await pickFromCamera();
    } else {
      return await pickFromGallery();
    }
  }
}
