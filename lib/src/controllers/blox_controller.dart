import 'dart:convert';

import 'package:blox_editor/src/models/block.dart';
import 'package:blox_editor/src/models/text_block.dart';
import 'package:flutter/material.dart';

import '../../blox_editor.dart';

class BloxController extends ChangeNotifier {
  BloxController({List<Block>? blocks}) {
    blocks != null ? _blocks = blocks : _blocks = <Block>[];
  }

  late final List<Block> _blocks;

  List<Block> get blocks => _blocks;

  bool get hasBlocks => _blocks.isNotEmpty;

  int get blocksCount => _blocks.length;

  void addBlocks(List<Block> blocks) {
    if (blocks.isNotEmpty) {
      _blocks.addAll(blocks);
      notifyListeners();
    }
  }

  void addBlock(covariant Block block, {int? index, bool notify = true}) {
    if (index != null) {
      _blocks.insert(index, block);
    } else {
      _blocks.add(block);
    }

    if (notify) {
      notifyListeners();
    }
  }

  void removeBlock(covariant Block block, {bool notify = true}) {
    _blocks.remove(block);

    block.dispose();

    if (notify) {
      notifyListeners();
    }
  }

  void move(int index, int newIndex) {
    if (blocksCount <= 1) {
      return;
    }

    final currentBlock = _blocks[index];
    final nextBlock = _blocks[newIndex];
    _blocks[index] = nextBlock;
    _blocks[newIndex] = currentBlock;

    notifyListeners();
  }

  void clearAllBlocks() {
    _blocks.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toJson() {
    return _blocks.map((e) {
      if (e is TextBlock) {
        return {
          'block': 'TEXT',
          'fields': {'quill': e.controller.document.toDelta().toJson()}
        };
      } else if (e is ImageBlock) {
        return {
          'block': 'IMAGE',
          'fields': {
            'type': 'SINGLE',
            'urls': [e.controller.uploadKey]
          }
        };
      } else if (e is VideoBlock) {
        return {
          'block': 'VIDEO',
          'fields': {
            'type': 'SINGLE',
            'urls': [e.controller.uploadKey]
          }
        };
      }
      return <String, dynamic>{};
    }).toList();
  }
}
