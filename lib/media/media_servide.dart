import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'media_service_interface.dart';
import 'package:ess_app/perm/permission_service.dart';
import 'package:ess_app/perm/service_locator.dart';

class MediaService implements MediaServiceInterface {
  @override
  PermissionService get permissionService => getIt<PermissionService>();

  Future<bool> _handleImageUploadPermissions(BuildContext context, AppImageSource? _imageSource) async {
    if (_imageSource == null) {
      return false;
    }
    if (_imageSource == AppImageSource.camera) {
      return await permissionService.handleCameraPermission(context);
    } else if (_imageSource == AppImageSource.gallery) {
      return await permissionService.handlePhotoPermission(context);
    } else {
      return false;
    }
  }

  @override
  Future<File?> uploadImage(
      BuildContext context,
      AppImageSource appImageSource, {
        bool shouldCompress = true,
      }) async {
    // Handle permissions according to image source,
    bool canProceed = await _handleImageUploadPermissions(context, appImageSource);

    if (canProceed) {
      File? processedPickedImageFile;

      // Convert our own AppImageSource into a format readable by the used package
      // In this case it's an ImageSource enum
      ImageSource? _imageSource = ImageSource.values.byName(appImageSource.name);

      final imagePicker = ImagePicker();
      final rawPickedImageFile = await imagePicker.pickImage(source: _imageSource, imageQuality: 50);

      if (rawPickedImageFile != null) {
        //to convert from XFile type provided by the package to dart:io's File type
        processedPickedImageFile = File(rawPickedImageFile.path);
        if (shouldCompress) {
          processedPickedImageFile = await compressFile(processedPickedImageFile);
        }
      }
      return processedPickedImageFile;
    }
    return null; // Added to handle the case when permissions are not granted
  }

  @override
  Future<File?> compressFile(File file, {int quality = 30}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = '${dir.absolute.path}/${Random().nextInt(1000)}-temp.jpg';

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    if (compressedFile != null) {
      return File(compressedFile.path);
    }

    return null;
  }
}
