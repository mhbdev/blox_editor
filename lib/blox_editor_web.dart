// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'blox_editor_platform_interface.dart';

/// A web implementation of the BloxEditorPlatform of the BloxEditor plugin.
class BloxEditorWeb extends BloxEditorPlatform {
  /// Constructs a BloxEditorWeb
  BloxEditorWeb();

  static void registerWith(Registrar registrar) {
    BloxEditorPlatform.instance = BloxEditorWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
