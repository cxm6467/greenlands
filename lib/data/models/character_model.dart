import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/character.dart';

part 'character_model.g.dart';

@JsonSerializable()
class CharacterModel {
  final String id;
  final String name;
  final String race;
  final String characterClass;
  final String fellowshipRole;
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final Map<String, int> baseStats;
  final Map<String, int> totalStats;
  final int availableStatPoints;
  final String? profileImageUrl;
  final String createdAt;
  final String updatedAt;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.race,
    required this.characterClass,
    required this.fellowshipRole,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.baseStats,
    required this.totalStats,
    required this.availableStatPoints,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterModelToJson(this);

  factory CharacterModel.fromEntity(Character character) {
    return CharacterModel(
      id: character.id,
      name: character.name,
      race: character.race.name,
      characterClass: character.characterClass.name,
      fellowshipRole: character.fellowshipRole.name,
      level: character.level,
      currentXp: character.currentXp,
      xpToNextLevel: character.xpToNextLevel,
      baseStats: character.baseStats,
      totalStats: character.totalStats,
      availableStatPoints: character.availableStatPoints,
      profileImageUrl: character.profileImageUrl,
      createdAt: character.createdAt.toIso8601String(),
      updatedAt: character.updatedAt.toIso8601String(),
    );
  }

  Character toEntity() {
    return Character(
      id: id,
      name: name,
      race: CharacterRace.values.firstWhere((e) => e.name == race),
      characterClass: CharacterClass.values.firstWhere(
        (e) => e.name == characterClass,
      ),
      fellowshipRole: FellowshipRole.values.firstWhere(
        (e) => e.name == fellowshipRole,
      ),
      level: level,
      currentXp: currentXp,
      xpToNextLevel: xpToNextLevel,
      baseStats: baseStats,
      totalStats: totalStats,
      availableStatPoints: availableStatPoints,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'name': name,
      'race': race,
      'class': characterClass,
      'fellowship_role': fellowshipRole,
      'level': level,
      'current_xp': currentXp,
      'xp_to_next_level': xpToNextLevel,
      'base_stats': _encodeStats(baseStats),
      'total_stats': _encodeStats(totalStats),
      'available_stat_points': availableStatPoints,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CharacterModel.fromDatabase(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] as String,
      name: map['name'] as String,
      race: map['race'] as String,
      characterClass: map['class'] as String,
      fellowshipRole: map['fellowship_role'] as String,
      level: map['level'] as int,
      currentXp: map['current_xp'] as int,
      xpToNextLevel: map['xp_to_next_level'] as int,
      baseStats: _decodeStats(map['base_stats'] as String),
      totalStats: _decodeStats(map['total_stats'] as String),
      availableStatPoints: map['available_stat_points'] as int,
      profileImageUrl: map['profile_image_url'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  static String _encodeStats(Map<String, int> stats) {
    return stats.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  static Map<String, int> _decodeStats(String encoded) {
    if (encoded.isEmpty) return {};
    return Map.fromEntries(
      encoded.split(',').map((pair) {
        final parts = pair.split(':');
        return MapEntry(parts[0], int.parse(parts[1]));
      }),
    );
  }
}
