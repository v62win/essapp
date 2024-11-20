import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ess_app/common/dialogbox.dart';
import 'permission_service.dart';

class PermissionHandlerPermissionService implements PermissionService {

  @override
  Future<bool> handleCameraPermission(BuildContext context) async {
    PermissionStatus cameraPermissionStatus = await requestCameraPermission();
    if (cameraPermissionStatus != PermissionStatus.granted) {  // Check for 'granted' instead
      print('camera permission denied');
      await showDialog(
        context: context,
        builder: (_context) => AppAlertDialog(
          onConfirm: () => openAppSettings(),
          title: 'Camera Permission',
          subtitle: 'Camera permission should be granted to use this feature, would you like to go to app settings to give camera permission?',
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Future<bool> handlePhotoPermission(BuildContext context) async {
    PermissionStatus photoPermissionStatus = await requestPhotosPermission();
    if (photoPermissionStatus != PermissionStatus.denied) {  // Check for 'granted' instead
      print('photo permission denied');
      await showDialog(
        context: context,
        builder: (_context) => AppAlertDialog(
          onConfirm: () => openAppSettings(),
          title: 'Photo Permission',
          subtitle: 'Photo permission should be granted to use this feature, would you like to go to app settings to give photo permission?',
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Future requestCameraPermission() async {
    return await Permission.camera.request();
  }

  @override
  Future requestPhotosPermission() async {
    return await Permission.photos.request();
  }
}
