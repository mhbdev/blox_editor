import 'package:flutter_test/flutter_test.dart';
import 'package:blox_editor/blox_editor.dart';
import 'package:blox_editor/blox_editor_platform_interface.dart';
import 'package:blox_editor/blox_editor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBloxEditorPlatform
    with MockPlatformInterfaceMixin
    implements BloxEditorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BloxEditorPlatform initialPlatform = BloxEditorPlatform.instance;

  test('$MethodChannelBloxEditor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBloxEditor>());
  });

}
