// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestModel _$QuestModelFromJson(Map<String, dynamic> json) => QuestModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  questType: json['quest_type'] as String,
  difficulty: json['difficulty'] as String,
  status: json['status'] as String,
  xpReward: (json['xp_reward'] as num).toInt(),
  objectives: (json['objectives'] as List<dynamic>)
      .map((e) => QuestObjectiveModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  requiredLevel: (json['required_level'] as num).toInt(),
  prerequisites: (json['prerequisites'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isGenerated: (json['is_generated'] as num).toInt(),
  generationContext: json['generation_context'] as String?,
  recurrenceRule: json['recurrence_rule'] as String?,
  acceptedAt: json['accepted_at'] as String?,
  completedAt: json['completed_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$QuestModelToJson(QuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'quest_type': instance.questType,
      'difficulty': instance.difficulty,
      'status': instance.status,
      'xp_reward': instance.xpReward,
      'objectives': instance.objectives,
      'required_level': instance.requiredLevel,
      'prerequisites': instance.prerequisites,
      'is_generated': instance.isGenerated,
      'generation_context': instance.generationContext,
      'recurrence_rule': instance.recurrenceRule,
      'accepted_at': instance.acceptedAt,
      'completed_at': instance.completedAt,
      'created_at': instance.createdAt,
    };

QuestObjectiveModel _$QuestObjectiveModelFromJson(Map<String, dynamic> json) =>
    QuestObjectiveModel(
      text: json['text'] as String,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$QuestObjectiveModelToJson(
  QuestObjectiveModel instance,
) => <String, dynamic>{'text': instance.text, 'completed': instance.completed};
