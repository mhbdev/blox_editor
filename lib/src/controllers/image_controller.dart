import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class ImageController extends ChangeNotifier {
  String? _uploadKey;

  String? get uploadKey => _uploadKey;

  set uploadKey(String? value) {
    _uploadKey = value;
    notifyListeners();
  }

  PlatformFile? _selectedFile;

  PlatformFile? get selectedFile => _selectedFile;

  set selectedFile(PlatformFile? value) {
    _selectedFile = value;
    notifyListeners();
  }
}
