import 'package:flutter/material.dart';
import 'package:blox_editor/blox_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BloxController controller = BloxController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('fa'),
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: BloxEditor(
          controller: controller,
          uploadHandler: (file) async {
            return 'UPLOADED_FILE_KEY';
          },
        ),
      ),
    );
  }
}
