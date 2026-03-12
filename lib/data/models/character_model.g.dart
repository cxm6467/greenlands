// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterModel _$CharacterModelFromJson(Map<String, dynamic> json) =>
    CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      race: json['race'] as String,
      characterClass: json['characterClass'] as String,
      fellowshipRole: json['fellowshipRole'] as String,
      level: (json['level'] as num).toInt(),
      currentXp: (json['currentXp'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
      baseStats: Map<String, int>.from(json['baseStats'] as Map),
      totalStats: Map<String, int>.from(json['totalStats'] as Map),
      availableStatPoints: (json['availableStatPoints'] as num).toInt(),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$CharacterModelToJson(CharacterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'race': instance.race,
      'characterClass': instance.characterClass,
      'fellowshipRole': instance.fellowshipRole,
      'level': instance.level,
      'currentXp': instance.currentXp,
      'xpToNextLevel': instance.xpToNextLevel,
      'baseStats': instance.baseStats,
      'totalStats': instance.totalStats,
      'availableStatPoints': instance.availableStatPoints,
      'profileImageUrl': instance.profileImageUrl,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
