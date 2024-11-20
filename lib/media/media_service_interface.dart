import 'dart:io';

import 'package:ess_app/perm/permission_service.dart';
import 'package:flutter/cupertino.dart';

enum AppImageSource {
  camera,
  gallery,
}

abstract class MediaServiceInterface {
  PermissionService get permissionService;

  Future<File?> uploadImage(
      BuildContext context,
      AppImageSource appImageSource, {
        bool shouldCompress = true,
      });

  Future<File?> compressFile(File file, {int quality = 30});
}