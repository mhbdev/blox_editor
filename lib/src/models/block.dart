import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class Block extends Equatable {
  final String id = const Uuid().v4();

  Block();

  @override
  List<Object?> get props => [id];

  void dispose();
}
