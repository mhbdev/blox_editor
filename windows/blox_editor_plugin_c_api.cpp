#include "include/blox_editor/blox_editor_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "blox_editor_plugin.h"

void BloxEditorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  blox_editor::BloxEditorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
