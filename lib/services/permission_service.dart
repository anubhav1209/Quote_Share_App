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
      final status = await Permission.storage.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return status.isGranted;
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
