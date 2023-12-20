import 'package:blox_editor/blox_editor.dart';
import 'package:blox_editor/src/models/image_block.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_permissions.dart';

class ImageEditor extends StatefulWidget {
  final ImageBlock block;
  final UploadHandler uploadHandler;
  final FileType? fileType;
  final bool allowCompression;
  final bool allowMultiple;

  /// Could be something like one these [pdf, svg, jpg]
  final List<String>? allowedExtensions;
  final String? pickerDialogTitle;

  final ValueChanged<List<String>>? onExtensionsNotSupported;
  final ValueChanged<int>? maxBytesReached;
  final int? maxBytes;
  final ValueChanged<int>? maxFilesCountReached;
  final int? maxFilesCount;

  const ImageEditor({
    super.key,
    required this.block,
    required this.uploadHandler,
    this.fileType,
    required this.allowCompression,
    required this.allowMultiple,
    this.allowedExtensions,
    this.onExtensionsNotSupported,
    this.maxBytesReached,
    this.maxBytes,
    this.maxFilesCountReached,
    this.maxFilesCount,
    this.pickerDialogTitle,
  });

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
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
                  return Image.memory(
                    file.bytes!,
                    fit: BoxFit.contain,
                  );
                } else if (uploadKey != null) {
                  return Image.network(
                    uploadKey,
                    fit: BoxFit.contain,
                  );
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
                      allowMultiple: widget.allowMultiple,
                      type: widget.fileType ??
                          (widget.allowedExtensions != null ? FileType.custom : FileType.any),
                      allowCompression: widget.allowCompression,
                      allowedExtensions: widget.allowedExtensions,
                      dialogTitle: widget.pickerDialogTitle,
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

                      if (widget.maxFilesCount != null) {
                        final filesCount = pickedFiles.files.length;
                        if (filesCount > widget.maxFilesCount!) {
                          if (widget.maxFilesCountReached != null) {
                            widget.maxFilesCountReached!(filesCount);
                          } else {
                            // TODO: show toast
                            // 'You are only able to upload up to ${widget.maxFilesCount} files'
                          }
                          return;
                        }
                      }

                      if (widget.allowedExtensions != null &&
                          pickedFiles.files
                              .map((e) => e.extension)
                              .any((e) => !widget.allowedExtensions!.contains(e))) {
                        if (widget.onExtensionsNotSupported != null) {
                          widget.onExtensionsNotSupported!(widget.allowedExtensions!);
                        }
                        return;
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
