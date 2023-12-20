import 'package:blox_editor/src/models/block.dart';
import '../controllers/video_controller.dart';

class VideoBlock extends Block {
  final VideoBlockController controller = VideoBlockController();

  VideoBlock();

  factory VideoBlock.unique() {
    return VideoBlock();
  }

  void setVideo(String url) {
    controller.uploadKey = url;
  }

  @override
  void dispose() {
    controller.dispose();
  }
}
