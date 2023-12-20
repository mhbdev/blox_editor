import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextEditor extends StatefulWidget {
  final String? placeholder;
  final QuillController controller;

  const TextEditor({super.key, this.placeholder, required this.controller});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1023;

    return QuillProvider(
      configurations: QuillConfigurations(
          controller: widget.controller,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('fa'),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: QuillToolbar(
              configurations: QuillToolbarConfigurations(
                  color: Colors.red,
                  multiRowsDisplay: true,
                  showHeaderStyle: false,
                  showQuote: true,
                  showCodeBlock: isDesktop,
                  showListCheck: isDesktop,
                  showRedo: isDesktop,
                  showUndo: isDesktop,
                  showIndent: isDesktop,
                  showDividers: isDesktop,
                  showInlineCode: false,
                  showStrikeThrough: false,
                  showFontSize: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showFontFamily: false,
                  showSearchButton: false,
                  toolbarSectionSpacing: 8,
                  sectionDividerColor: Colors.red),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            height: 200,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(8).copyWith(bottom: 32),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: QuillEditor(
                scrollController: _scrollController,
                focusNode: _focusNode,
                configurations: QuillEditorConfigurations(
                  autoFocus: false,
                  placeholder: widget.placeholder,
                  padding: EdgeInsets.zero,
                  scrollable: true,
                  expands: true,
                  readOnly: false,
                  keyboardAppearance: Brightness.dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
