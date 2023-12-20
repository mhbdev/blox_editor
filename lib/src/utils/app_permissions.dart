import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static Future<PermissionStatus?> requestImages() async {
    if (!isAndroid) {
      return null;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      /// use [Permissions.storage.status]
      return ((await Permission.storage.status) == PermissionStatus.granted)
          ? PermissionStatus.granted
          : await Permission.storage.request();
    } else {
      /// use [Permissions.photos.status]
      return ((await Permission.photos.status) == PermissionStatus.granted)
          ? PermissionStatus.granted
          : await Permission.photos.request();
    }
  }

  static Future<PermissionStatus?> requestVideos() async {
    if (!isAndroid) {
      return null;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      /// use [Permissions.storage.status]
      return ((await Permission.storage.status) == PermissionStatus.granted)
          ? PermissionStatus.granted
          : await Permission.storage.request();
    } else {
      /// use [Permissions.photos.status]
      return ((await Permission.videos.status) == PermissionStatus.granted)
          ? PermissionStatus.granted
          : await Permission.videos.request();
    }
  }
}
