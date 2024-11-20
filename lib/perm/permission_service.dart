import 'package:flutter/material.dart';

abstract class PermissionService{
  Future requestPhotosPermission();

  Future<bool> handlePhotoPermission(BuildContext context);

  Future requestCameraPermission();

  Future<bool> handleCameraPermission(BuildContext context);
}