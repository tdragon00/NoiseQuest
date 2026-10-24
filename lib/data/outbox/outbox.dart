import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum OutboxOpType {
  createQuest('create_quest'),
  startQuest('start_quest'),
  completeQuest('complete_quest'),
  cancelQuest('cancel_quest'),
  updateQuest('update_quest'),
  deleteQuest('delete_quest');

  const OutboxOpType(this.wire);
  final String wire;

  static OutboxOpType parse(String? value) => OutboxOpType.values.firstWhere(
        (t) => t.wire == value,
        orElse: () => OutboxOpType.createQuest,
      );
}

class OutboxOp extends Equatable {
  const OutboxOp({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final OutboxOpType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  factory OutboxOp.create(OutboxOpType type, Map<String, dynamic> payload) {
    return OutboxOp(
      id: const Uuid().v4(),
      type: type,
      payload: payload,
      createdAt: DateTime.now().toUtc(),
    );
  }

  factory OutboxOp.fromJson(Map<String, dynamic> json) => OutboxOp(
        id: json['id']?.toString() ?? const Uuid().v4(),
        type: OutboxOpType.parse(json['op']?.toString()),
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
        lastError: json['last_error'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'op': type.wire,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'attempts': attempts,
        'last_error': lastError,
      };

  OutboxOp copyWith({int? attempts, String? lastError}) => OutboxOp(
        id: id,
        type: type,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
      );

  String? get questId => payload['quest_id']?.toString();

  @override
  List<Object?> get props => [id, type, payload, createdAt, attempts, lastError];
}

List<OutboxOp> decodeOutbox(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => OutboxOp.fromJson(e.cast<String, dynamic>()))
        .toList();
  } catch (_) {
    return const [];
  }
}
