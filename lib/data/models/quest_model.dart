import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quest.dart';

part 'quest_model.g.dart';

@JsonSerializable()
class QuestModel {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'quest_type')
  final String questType;
  final String difficulty;
  final String status;
  @JsonKey(name: 'xp_reward')
  final int xpReward;
  final List<QuestObjectiveModel> objectives;
  @JsonKey(name: 'required_level')
  final int requiredLevel;
  final List<String> prerequisites;
  @JsonKey(name: 'is_generated')
  final int isGenerated;
  @JsonKey(name: 'generation_context')
  final String? generationContext;
  @JsonKey(name: 'recurrence_rule')
  final String? recurrenceRule;
  @JsonKey(name: 'accepted_at')
  final String? acceptedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  const QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questType,
    required this.difficulty,
    required this.status,
    required this.xpReward,
    required this.objectives,
    required this.requiredLevel,
    required this.prerequisites,
    required this.isGenerated,
    this.generationContext,
    this.recurrenceRule,
    this.acceptedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory QuestModel.fromJson(Map<String, dynamic> json) =>
      _$QuestModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestModelToJson(this);

  factory QuestModel.fromEntity(Quest quest) {
    return QuestModel(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      questType: quest.questType.name,
      difficulty: quest.difficulty.name,
      status: quest.status.name,
      xpReward: quest.xpReward,
      objectives: quest.objectives
          .map((obj) => QuestObjectiveModel.fromEntity(obj))
          .toList(),
      requiredLevel: quest.requiredLevel,
      prerequisites: quest.prerequisites,
      isGenerated: quest.isGenerated ? 1 : 0,
      generationContext: quest.generationContext,
      recurrenceRule: quest.recurrenceRule,
      acceptedAt: quest.acceptedAt?.toIso8601String(),
      completedAt: quest.completedAt?.toIso8601String(),
      createdAt: quest.createdAt.toIso8601String(),
    );
  }

  Quest toEntity() {
    return Quest(
      id: id,
      title: title,
      description: description,
      questType: QuestType.values.firstWhere((e) => e.name == questType),
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == difficulty,
      ),
      status: QuestStatus.values.firstWhere((e) => e.name == status),
      xpReward: xpReward,
      objectives: objectives.map((obj) => obj.toEntity()).toList(),
      requiredLevel: requiredLevel,
      prerequisites: prerequisites,
      isGenerated: isGenerated == 1,
      generationContext: generationContext,
      recurrenceRule: recurrenceRule,
      acceptedAt: acceptedAt != null ? DateTime.parse(acceptedAt!) : null,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      createdAt: DateTime.parse(createdAt),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'quest_type': questType,
      'difficulty': difficulty,
      'status': status,
      'xp_reward': xpReward,
      'objectives': _encodeObjectives(objectives),
      'required_level': requiredLevel,
      'prerequisites': _encodePrerequisites(prerequisites),
      'is_generated': isGenerated,
      'generation_context': generationContext,
      'recurrence_rule': recurrenceRule,
      'accepted_at': _isoStringToDbTimestamp(acceptedAt),
      'completed_at': _isoStringToDbTimestamp(completedAt),
      'created_at': _isoStringToDbTimestamp(createdAt),
    };
  }

  factory QuestModel.fromDatabase(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      questType: map['quest_type'] as String,
      difficulty: map['difficulty'] as String,
      status: map['status'] as String,
      xpReward: map['xp_reward'] as int,
      objectives: _decodeObjectives(map['objectives'] as String),
      requiredLevel: map['required_level'] as int,
      prerequisites: _decodePrerequisites(map['prerequisites'] as String?),
      isGenerated: map['is_generated'] as int,
      generationContext: map['generation_context'] as String?,
      recurrenceRule: map['recurrence_rule'] as String?,
      acceptedAt: _dbTimestampToIsoString(map['accepted_at']),
      completedAt: _dbTimestampToIsoString(map['completed_at']),
      createdAt:
          _dbTimestampToIsoString(map['created_at']) ??
          DateTime.now().toIso8601String(),
    );
  }

  static String _encodeObjectives(List<QuestObjectiveModel> objectives) {
    return jsonEncode(objectives.map((obj) => obj.toJson()).toList());
  }

  static List<QuestObjectiveModel> _decodeObjectives(String encoded) {
    if (encoded.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded
        .map((obj) => QuestObjectiveModel.fromJson(obj as Map<String, dynamic>))
        .toList();
  }

  static String _encodePrerequisites(List<String> prerequisites) {
    return jsonEncode(prerequisites);
  }

  static List<String> _decodePrerequisites(String? encoded) {
    if (encoded == null || encoded.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((e) => e as String).toList();
  }

  /// Convert an ISO-8601 string to an integer timestamp (milliseconds since epoch)
  /// suitable for storage in an INTEGER column. Returns null if [isoString] is null.
  static int? _isoStringToDbTimestamp(String? isoString) {
    if (isoString == null) return null;
    return DateTime.parse(isoString).millisecondsSinceEpoch;
  }

  /// Convert a database timestamp value (either INTEGER milliseconds or a String)
  /// to an ISO-8601 string. Returns null if [value] is null or unrecognized.
  static String? _dbTimestampToIsoString(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      ).toIso8601String();
    }
    if (value is String) {
      // Assume it is already an ISO-8601 string.
      return value;
    }
    // Unrecognized type; fail gracefully.
    return null;
  }
}

@JsonSerializable()
class QuestObjectiveModel {
  final String text;
  final bool completed;

  const QuestObjectiveModel({required this.text, required this.completed});

  factory QuestObjectiveModel.fromJson(Map<String, dynamic> json) =>
      _$QuestObjectiveModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestObjectiveModelToJson(this);

  factory QuestObjectiveModel.fromEntity(QuestObjective objective) {
    return QuestObjectiveModel(
      text: objective.text,
      completed: objective.completed,
    );
  }

  QuestObjective toEntity() {
    return QuestObjective(text: text, completed: completed);
  }
}
