import 'package:blox_editor/src/components/text_editor.dart';
import 'package:blox_editor/src/components/video_editor.dart';
import 'package:blox_editor/src/controllers/blox_controller.dart';
import 'package:blox_editor/src/models/image_block.dart';
import 'package:blox_editor/src/models/text_block.dart';
import 'package:blox_editor/src/models/video_block.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'components/image_editor.dart';

typedef UploadHandler = Future<String> Function(PlatformFile file);

class BloxEditor extends StatefulWidget {
  final BloxController? controller;
  final UploadHandler uploadHandler;
  final String? initialAddButtonText;

  const BloxEditor({
    super.key,
    this.controller,
    required this.uploadHandler,
    this.initialAddButtonText,
  });

  @override
  State<BloxEditor> createState() => _BloxEditorState();
}

class _BloxEditorState extends State<BloxEditor> {
  late final BloxController _controller;
  final ValueNotifier<int?> _hoveredIndex = ValueNotifier<int?>(null);

  @override
  void initState() {
    _controller = widget.controller ?? BloxController();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _hoveredIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) => _controller.hasBlocks
          ? ValueListenableBuilder(
              valueListenable: _hoveredIndex,
              builder: (context, hoveredIndex, child) => ListView.separated(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => MouseRegion(
                  onEnter: (e) {
                    _hoveredIndex.value = index;
                  },
                  onExit: (e) {
                    _hoveredIndex.value = null;
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildBlock(index),
                      ),
                      if (hoveredIndex == index)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (index > 0)
                                  Card(
                                    elevation: 8,
                                    child: IconButton(
                                      onPressed: () {
                                        // Move up
                                        _controller.move(index, index - 1);
                                      },
                                      icon: const Icon(Icons.arrow_upward),
                                    ),
                                  ),
                                _actionsCard(index),
                                if (index < _controller.blocksCount - 1)
                                  Card(
                                    elevation: 8,
                                    child: IconButton(
                                      onPressed: () {
                                        // Move down
                                        _controller.move(index, index + 1);
                                      },
                                      icon: const Icon(Icons.arrow_downward),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                itemCount: _controller.blocksCount,
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.initialAddButtonText ?? 'اضافه کردن بلوک جدید',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _actionsCard(-1, showDeleteButton: false),
                ],
              ),
            ),
    );
  }

  Widget _buildBlock(int index) {
    final block = _controller.blocks[index];

    if (block is TextBlock) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextEditor(
            key: ValueKey('text-editor-${block.id}'),
            controller: block.controller,
          ),
        ),
      );
    } else if (block is ImageBlock) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ImageEditor(
            key: ValueKey('image-editor-${block.id}'),
            uploadHandler: widget.uploadHandler,
            block: block,
            allowCompression: true,
            allowMultiple: false,
          ),
        ),
      );
    } else if (block is VideoBlock) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: VideoEditor(
            key: ValueKey('video-editor-${block.id}'),
            uploadHandler: widget.uploadHandler,
            block: block,
          ),
        ),
      );
    }

    return const Text('Unsupported Block');
  }

  Widget _actionsCard(int index, {bool showDeleteButton = true}) {
    return Card(
      elevation: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              _controller.addBlock(TextBlock.unique(), index: index + 1);
            },
            tooltip: 'بلوک متنی',
            icon: const Icon(Icons.drive_file_rename_outline_rounded),
          ),
          const SizedBox(
            height: 16,
            child: VerticalDivider(),
          ),
          IconButton(
            onPressed: () {
              FilePicker.platform
                  .pickFiles(
                type: FileType.image,
                allowMultiple: false,
              )
                  .then((pickedFiles) {
                if (pickedFiles != null) {
                  widget.uploadHandler(pickedFiles.files.single).then((uploadKey) {
                    ImageBlock image = ImageBlock.unique();
                    image.controller.selectedFile = pickedFiles.files.single;
                    image.controller.uploadKey = uploadKey;
                    _controller.addBlock(image, index: index + 1);
                  });
                }
              });
            },
            tooltip: 'بلوک تصویری',
            icon: const Icon(Icons.image_outlined),
          ),
          const SizedBox(
            height: 16,
            child: VerticalDivider(),
          ),
          IconButton(
            onPressed: () {
              FilePicker.platform
                  .pickFiles(
                type: FileType.video,
                allowMultiple: false,
              )
                  .then((pickedFiles) {
                if (pickedFiles != null) {
                  widget.uploadHandler(pickedFiles.files.single).then((uploadKey) {
                    VideoBlock video = VideoBlock.unique();
                    video.controller.selectedFile = pickedFiles.files.single;
                    video.controller.uploadKey = uploadKey;
                    _controller.addBlock(video, index: index + 1);
                  });
                }
              });
            },
            tooltip: 'بلوک ویدیویی',
            icon: const Icon(Icons.video_library_outlined),
          ),
          if (showDeleteButton) ...[
            const SizedBox(
              height: 16,
              child: VerticalDivider(),
            ),
            IconButton(
              onPressed: () {
                _controller.removeBlock(_controller.blocks[index]);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            )
          ],
        ],
      ),
    );
  }
}
