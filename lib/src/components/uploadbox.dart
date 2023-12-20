import 'dart:io' as io;
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_permissions.dart';

typedef UpdateImages = void Function(List<Uint8List?> newImages);
typedef FilePicked = void Function(List<PlatformFile> pickedFiles, UpdateImages updateImages);

class UploadBox extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback chooseFile,
      void Function(List<XFile> newFiles) updateFiles)? placeholder;
  final FileType? fileType;
  final bool allowCompression;
  final bool allowMultiple;

  /// Could be something like one these [pdf, svg, jpg]
  final List<String>? allowedExtensions;
  final String? pickerDialogTitle;
  final String? placeholderText;
  final Color? placeholderColor;
  final IconData? placeholderIcon;
  final FilePicked? onFilePicked;
  final Future<List<String?>?> Function(
          List<PlatformFile> files, void Function(double progress) progress, VoidCallback onDone)?
      onUpload;
  final void Function(Map<PlatformFile, String?> uploadedFiles)? onFileUploaded;
  final bool showBackgroundCard;
  final Color borderColor;
  final Radius borderRadius;
  final bool uploadImmediately;
  final VoidCallback? onFilesRemoved;
  final bool isMini;
  final EdgeInsets? innerPadding;
  final ValueChanged<List<String>>? onExtensionsNotSupported;
  final ValueChanged<int>? maxBytesReached;
  final int? maxBytes;
  final ValueChanged<int>? maxFilesCountReached;
  final int? maxFilesCount;
  final bool showPlaceholderText;
  final bool onlyPick;
  final MouseCursor mouseCursor;
  final List<PlatformFile>? initiallySelected;

  const UploadBox({
    Key? key,
    this.placeholder,
    this.fileType,
    this.allowCompression = false,
    this.allowedExtensions,
    this.pickerDialogTitle,
    this.allowMultiple = false,
    this.placeholderText,
    this.onFilePicked,
    this.showBackgroundCard = true,
    this.borderColor = Colors.blue,
    this.borderRadius = const Radius.circular(8),
    this.placeholderIcon,
    this.placeholderColor,
    this.uploadImmediately = false,
    this.onUpload,
    this.onFileUploaded,
    this.onFilesRemoved,
    this.isMini = false,
    this.innerPadding,
    this.onExtensionsNotSupported,
    this.maxBytes,
    this.maxBytesReached,
    this.maxFilesCountReached,
    this.maxFilesCount,
    this.showPlaceholderText = true,
    this.onlyPick = false,
    this.mouseCursor = SystemMouseCursors.click, this.initiallySelected,
  }) : super(key: key);

  @override
  State<UploadBox> createState() => _UploadBoxState();
}

class _UploadBoxState extends State<UploadBox> with AutomaticKeepAliveClientMixin {
  final ValueNotifier<FilePickerStatus?> _filePickerStatus = ValueNotifier(null);
  final ValueNotifier<List<PlatformFile>> _selectedFiles = ValueNotifier([]);
  final ValueNotifier<double> _uploadProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    _selectedFiles.value = widget.initiallySelected ?? [];
    super.initState();
  }

  @override
  void dispose() {
    _filePickerStatus.dispose();
    _selectedFiles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final child = Padding(
      padding: const EdgeInsets.all(4),
      child: IntrinsicHeight(
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(8),
          child: ValueListenableBuilder(
            valueListenable: _selectedFiles,
            builder: (_, value, __) {
              final child = value.isNotEmpty ? _preview(value) : _placeholder();
              return child;
            },
          ),
        ),
      ),
    );

    return MouseRegion(
      cursor: widget.mouseCursor,
      child: widget.showBackgroundCard
          ? Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(widget.borderRadius)),
              child: child,
            )
          : child,
    );
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Widget _preview(List<PlatformFile> files) {
    final previewWidget = GestureDetector(
      onTap: () {
        // TODO : improvements needed (show image previews)
        showDialog(
          context: context,
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('تصاویر انتخاب شده'),
            ),
            body: PageView(
              children: files
                  .map(
                    (e) => e.bytes != null
                        ? Center(
                            child: Image.memory(
                              e.bytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Image.file(
                              File(e.path!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  )
                  .toList(),
            ),
          ),
        );
      },
      child: SizedBox(
        height: 100,
        width: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...files.take(3).map(
                  (e) => PositionedDirectional(
                    end: widget.uploadImmediately ? 0 : -18 * (files.indexOf(e) / files.length),
                    bottom: widget.uploadImmediately ? 0 : -10 * (files.indexOf(e) / files.length),
                    width: 100,
                    height: 100,
                    child: Container(
                      width: 100 - 8 * (files.indexOf(e) / files.length),
                      height: 100 - 8 * (files.indexOf(e) / files.length),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildPreviewWidget(
                          e,
                          10 * (files.indexOf(e) / files.length),
                        ),
                      ),
                    ),
                  ),
                ),
            if (widget.uploadImmediately)
              ValueListenableBuilder(
                valueListenable: _uploadProgress,
                builder: (_, value, __) => ClipRRect(
                  borderRadius: BorderRadius.all(widget.borderRadius),
                  child: Container(
                    color: Colors.white60,
                    alignment: Alignment.center,
                    child: value == -1
                        ? TextButton(
                            onPressed: () async {
                              if (widget.onUpload != null) {
                                _uploadProgress.value = 0;
                                final uploadedFiles = await widget.onUpload!(files, (progress) {
                                  _uploadProgress.value = progress;
                                }, () {
                                  _uploadProgress.value = -2;
                                });
                                if (widget.onFileUploaded != null) {
                                  if (uploadedFiles != null) {
                                    widget.onFileUploaded!(Map.fromIterables(files, uploadedFiles));
                                  } else {
                                    _uploadProgress.value = -1;
                                  }
                                }
                              }
                            },
                            child: const Text('تلاش مجدد'),
                          )
                        : (value == -2
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              )
                            : Text(
                                '${((value - min(value, 0.1)) * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                  ),
                ),
              )
          ],
        ),
      ),
    );
    return widget.isMini
        ? Stack(
            children: [
              Center(
                child: previewWidget,
              ),
              PositionedDirectional(
                  end: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: _deleteFiles,
                    icon: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          FeatherIcons.trash,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ))
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              previewWidget,
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      files.map((e) => e.name).join(', '),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    Text(
                      formatBytes(files.map<int>((e) => e.size).fold(0, (p, c) => p + c), 3),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _chooseFiles,
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                elevation: MaterialStateProperty.all(0),
                              ),
                          child: const Icon(
                            FeatherIcons.edit2,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: _deleteFiles,
                          style: ElevatedButtonTheme.of(context).style?.copyWith(
                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                padding: MaterialStateProperty.all(EdgeInsets.zero),
                                elevation: MaterialStateProperty.all(0),
                              ),
                          child: const Icon(
                            FeatherIcons.trash2,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _placeholder() {
    return GestureDetector(
      onTap: widget.placeholder != null ? null : _chooseFiles,
      child: widget.placeholder != null
          ? widget.placeholder!(context, _chooseFiles, (images) async {
              _selectedFiles.value = [];
              for (final e in images) {
                final bytes = await e.readAsBytes();
                _selectedFiles.value = _selectedFiles.value
                  ..add(PlatformFile(
                    name: e.name,
                    size: bytes.lengthInBytes,
                    bytes: bytes,
                    path: e.path,
                  ));
              }
              setState(() {});
              _manageUpload(_selectedFiles.value);
            })
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: widget.placeholderColor ?? Colors.blue,
                    child: Center(
                      child: Icon(
                        widget.placeholderIcon ?? FeatherIcons.uploadCloud,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (widget.showPlaceholderText)
                  Expanded(
                    child: Center(
                      child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(text: widget.placeholderText ?? 'انتخاب فایل', children: [
                            const TextSpan(text: '\r\n'),
                            TextSpan(text: widget.allowedExtensions?.map((e) => e).join(' ,')),
                          ])),
                    ),
                  )
              ],
            ),
    );
  }

  void _chooseFiles() async {
    if (!kIsWeb) {
      final images = await AppPermissions.requestImages();
      final videos = await AppPermissions.requestVideos();
      if (images != PermissionStatus.granted || videos != PermissionStatus.granted) {
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
      type: widget.fileType ?? (widget.allowedExtensions != null ? FileType.custom : FileType.any),
      allowCompression: widget.allowCompression,
      allowedExtensions: widget.allowedExtensions,
      dialogTitle: widget.pickerDialogTitle,
      onFileLoading: (status) {
        _filePickerStatus.value = status;
      },
    );
    if (pickedFiles != null) {
      if (widget.maxBytes != null) {
        final bytes = pickedFiles.files.map<int>((e) => e.size).fold(0, (p, c) => p + c);
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

      if (!widget.onlyPick) {
        _selectedFiles.value = pickedFiles.files;
      }

      if (widget.onFilePicked != null) {
        widget.onFilePicked!(pickedFiles.files, _updateImages);
      }

      _manageUpload(pickedFiles.files);
    }
  }

  void _deleteFiles() {
    _selectedFiles.value = [];
    if (widget.onFilesRemoved != null) {
      widget.onFilesRemoved!();
    }
  }

  Widget _buildPreviewWidget(PlatformFile e, double padding) {
    if (e.extension != null) {
      final fileType = e.extension!.split('/')[0];
      if (['png', 'jpeg', 'jpg'].contains(fileType)) {
        if (kIsWeb || e.bytes != null) {
          return Image.memory(
            e.bytes!,
            width: 100 - padding,
            height: 100 - padding,
            fit: BoxFit.cover,
          );
        } else {
          return Image.file(
            io.File(e.path!),
            width: 100 - padding,
            height: 100 - padding,
            fit: BoxFit.cover,
          );
        }
        // return kIsWeb
        //     ? Image.memory(
        //         e.bytes!,
        //         width: 100 - padding,
        //         height: 100 - padding,
        //         fit: BoxFit.cover,
        //       )
        //     : Image.file(
        //         io.File(e.path!),
        //         width: 100 - padding,
        //         height: 100 - padding,
        //         fit: BoxFit.cover,
        //       );
      } else if (['mp4', 'flv', 'mkv', 'mpeg4'].contains(fileType)) {
        return const Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.orange,
          child: Center(
            child: Icon(
              Icons.video_collection_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
        );
      } else if (fileType == 'pdf') {
        return const Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.blue,
          child: Center(
            child: Icon(
              Icons.picture_as_pdf_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return const Text('unknown');
  }

  @override
  bool get wantKeepAlive => true;

  void _updateImages(List<Uint8List?> newImages) {
    assert(newImages.length == _selectedFiles.value.length);
    _selectedFiles.value = List.generate(_selectedFiles.value.length, (index) {
      final newImage = newImages[index];
      final originalFile = _selectedFiles.value[index];
      if (newImage != null) {
        return PlatformFile(name: originalFile.name, size: newImage.lengthInBytes, bytes: newImage);
      } else {
        return originalFile;
      }
    });
  }

  void _manageUpload(List<PlatformFile> pickedFiles) async {
    if (widget.uploadImmediately) {
      if (widget.onUpload != null) {
        _uploadProgress.value = 0;
        final uploadedFiles = await widget.onUpload!(pickedFiles, (progress) {
          _uploadProgress.value = progress;
        }, () {
          _uploadProgress.value = -2;
        });
        if (widget.onFileUploaded != null) {
          if (uploadedFiles != null) {
            widget.onFileUploaded!(Map.fromIterables(pickedFiles, uploadedFiles));
          } else {
            _uploadProgress.value = -1;
          }
        }
      }
    }
  }
}
