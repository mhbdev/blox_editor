#ifndef FLUTTER_PLUGIN_BLOX_EDITOR_PLUGIN_H_
#define FLUTTER_PLUGIN_BLOX_EDITOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace blox_editor {

class BloxEditorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BloxEditorPlugin();

  virtual ~BloxEditorPlugin();

  // Disallow copy and assign.
  BloxEditorPlugin(const BloxEditorPlugin&) = delete;
  BloxEditorPlugin& operator=(const BloxEditorPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace blox_editor

#endif  // FLUTTER_PLUGIN_BLOX_EDITOR_PLUGIN_H_
