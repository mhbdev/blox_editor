import 'dart:html' as html;

import 'package:blox_editor/blox_editor.dart';
import 'package:blox_editor/src/models/video_block.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_permissions.dart';

class VideoEditor extends StatefulWidget {
  final VideoBlock block;
  final UploadHandler uploadHandler;
  final int? maxBytes;
  final ValueChanged<int>? maxBytesReached;

  const VideoEditor({
    super.key,
    required this.block,
    required this.uploadHandler,
    this.maxBytes,
    this.maxBytesReached,
  });

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final ValueNotifier<FilePickerStatus?> _filePickerStatus = ValueNotifier(null);

  @override
  void dispose() {
    _filePickerStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: ListenableBuilder(
              listenable: widget.block.controller,
              builder: (context, child) {
                final file = widget.block.controller.selectedFile;
                final uploadKey = widget.block.controller.uploadKey;

                if (file != null) {
                  return VideoPlayerWidget(
                    videoBytes: file.bytes!,
                  );
                } else if (uploadKey != null) {
                  return VideoPlayerWidgetFromUrl(videoUrl: uploadKey);
                } else if (file == null) {
                  return const Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.blue,
                    child: Center(
                      child: Icon(
                        FeatherIcons.uploadCloud,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return const Text('Could not handle image!');
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!kIsWeb) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0)),
                    onPressed: () async {},
                    icon: const Icon(Icons.camera_rounded),
                    label: const Text(
                      'استفاده از دوربین',
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  style:
                      OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0)),
                  onPressed: () async {
                    if (!kIsWeb) {
                      final images = await AppPermissions.requestImages();
                      final videos = await AppPermissions.requestVideos();
                      if (images != PermissionStatus.granted ||
                          videos != PermissionStatus.granted) {
                        // TODO : showToast
                        // 'برای انتخاب فایل از گالری لطفا دسترسی به حافظه را به مجوزهای برنامه اضافه کنید.'
                        Future.delayed(const Duration(seconds: 1)).then((value) {
                          openAppSettings();
                        });
                        return;
                      }
                    }

                    final pickedFiles = await FilePicker.platform.pickFiles(
                      withData: true,
                      allowMultiple: false,
                      type: FileType.video,
                      allowCompression: true,
                      onFileLoading: (status) {
                        _filePickerStatus.value = status;
                      },
                    );
                    if (pickedFiles != null) {
                      if (widget.maxBytes != null) {
                        final bytes =
                            pickedFiles.files.map<int>((e) => e.size).fold(0, (p, c) => p + c);
                        if (bytes > widget.maxBytes!) {
                          if (widget.maxBytesReached != null) {
                            widget.maxBytesReached!(bytes);
                          } else {
                            // TODO : showToast
                            // 'Maximum file size reached. file size must be less than ${formatBytes(widget.maxBytes!, 2)}'
                          }
                          return;
                        }
                      }

                      widget.block.controller.selectedFile = pickedFiles.files.single;
                      widget.block.controller.uploadKey =
                          await widget.uploadHandler(pickedFiles.files.single);
                    }
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text(
                    'انتخاب از گالری',
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidgetFromUrl extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidgetFromUrl({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidgetFromUrl> createState() => _VideoPlayerWidgetFromUrlState();
}

class _VideoPlayerWidgetFromUrlState extends State<VideoPlayerWidgetFromUrl> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _controller.initialize();
    await _controller.setLooping(true);
    _controller.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: VideoPlayer(_controller)),
      Positioned.fill(
        child: PlayPauseOverlay(
          controller: _controller,
        ),
      )
    ]);
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final Uint8List videoBytes;

  const VideoPlayerWidget({super.key, required this.videoBytes});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    // Convert the byte array to a blob and set it as the video source
    final blob = html.Blob([widget.videoBytes]);
    final url = html.Url.createObjectUrl(blob);

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller.initialize();
    await _controller.setLooping(true);
    _controller.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: VideoPlayer(_controller)),
      Positioned.fill(
        child: PlayPauseOverlay(
          controller: _controller,
        ),
      )
    ]);
  }
}

class PlayPauseOverlay extends StatefulWidget {
  const PlayPauseOverlay({Key? key, this.controller, this.onTap, this.showIconOnTopLeft = true})
      : super(key: key);

  final VideoPlayerController? controller;
  final VoidCallback? onTap;
  final bool showIconOnTopLeft;

  @override
  State<PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<PlayPauseOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller!.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller!.removeListener(_rebuild);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayPauseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller &&
        widget.controller!.value != oldWidget.controller!.value) {
      _rebuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller!.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 100.0,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'بازپخش',
                          style: TextStyle(fontSize: 20, color: Colors.white, shadows: [
                            BoxShadow(color: Colors.black, spreadRadius: 0.5, blurRadius: 0.5)
                          ]),
                        )
                      ],
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () async {
            widget.controller!.value.isPlaying
                ? widget.controller!.pause().then((value) => _rebuild())
                : widget.controller!.play().then((value) => _rebuild());
          },
        ),
      ],
    );
  }
}
