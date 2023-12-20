import 'package:blox_editor/src/models/block.dart';
import '../controllers/image_controller.dart';

class ImageBlock extends Block {
  final ImageController controller = ImageController();

  ImageBlock();

  factory ImageBlock.unique() {
    return ImageBlock();
  }

  void setImage(String url) {
    controller.uploadKey = url;
  }

  @override
  void dispose() {
    controller.dispose();
  }
}
