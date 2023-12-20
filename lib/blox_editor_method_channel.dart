import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'blox_editor_platform_interface.dart';

/// An implementation of [BloxEditorPlatform] that uses method channels.
class MethodChannelBloxEditor extends BloxEditorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('blox_editor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
