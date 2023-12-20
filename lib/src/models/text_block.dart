import 'package:blox_editor/src/models/block.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class TextBlock extends Block {
  final quill.QuillController controller = quill.QuillController.basic();

  TextBlock();

  factory TextBlock.unique() {
    return TextBlock();
  }

  void setDelta(quill.Delta delta) {
    controller.document = quill.Document.fromDelta(delta);
  }

  void setJsonDelta(List<dynamic> json) {
    controller.document = quill.Document.fromJson(json);
  }

  @override
  void dispose() {
    controller.dispose();
  }
}
