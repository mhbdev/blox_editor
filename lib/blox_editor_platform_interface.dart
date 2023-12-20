import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'blox_editor_method_channel.dart';

abstract class BloxEditorPlatform extends PlatformInterface {
  /// Constructs a BloxEditorPlatform.
  BloxEditorPlatform() : super(token: _token);

  static final Object _token = Object();

  static BloxEditorPlatform _instance = MethodChannelBloxEditor();

  /// The default instance of [BloxEditorPlatform] to use.
  ///
  /// Defaults to [MethodChannelBloxEditor].
  static BloxEditorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BloxEditorPlatform] when
  /// they register themselves.
  static set instance(BloxEditorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
