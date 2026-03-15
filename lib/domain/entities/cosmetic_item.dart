enum CosmeticType { avatarFrame, titleBadge, questCardTheme, emojiPack }

class CosmeticItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final CosmeticType type;
  final int gemCost;
  final bool isOwned;
  final bool isEquipped;
  final String? rarity; // 'common', 'uncommon', 'rare', 'epic', 'legendary'

  CosmeticItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.gemCost,
    required this.isOwned,
    required this.isEquipped,
    this.rarity,
  });

  CosmeticItem copyWith({bool? isOwned, bool? isEquipped}) {
    return CosmeticItem(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      type: type,
      gemCost: gemCost,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
      rarity: rarity,
    );
  }
}

extension CosmeticTypeExt on CosmeticType {
  String get displayName {
    switch (this) {
      case CosmeticType.avatarFrame:
        return 'Avatar Frame';
      case CosmeticType.titleBadge:
        return 'Title Badge';
      case CosmeticType.questCardTheme:
        return 'Quest Card Theme';
      case CosmeticType.emojiPack:
        return 'Emoji Pack';
    }
  }
}

/// Stub cosmetic shop catalog
List<CosmeticItem> createStubCosmeticCatalog() {
  return [
    // Avatar Frames
    CosmeticItem(
      id: 'frame_gold',
      name: 'Golden Frame',
      description: 'A prestigious golden border for your avatar',
      emoji: '🟨',
      type: CosmeticType.avatarFrame,
      gemCost: 50,
      isOwned: false,
      isEquipped: false,
      rarity: 'rare',
    ),
    CosmeticItem(
      id: 'frame_emerald',
      name: 'Emerald Frame',
      description: 'A vibrant emerald frame',
      emoji: '🟩',
      type: CosmeticType.avatarFrame,
      gemCost: 75,
      isOwned: false,
      isEquipped: false,
      rarity: 'epic',
    ),
    CosmeticItem(
      id: 'frame_crystal',
      name: 'Crystal Frame',
      description: 'A shimmering crystal frame (legendary)',
      emoji: '💎',
      type: CosmeticType.avatarFrame,
      gemCost: 150,
      isOwned: false,
      isEquipped: false,
      rarity: 'legendary',
    ),
    // Title Badges
    CosmeticItem(
      id: 'badge_hero',
      name: 'Hero Badge',
      description: 'Display "Hero" above your name',
      emoji: '🦸',
      type: CosmeticType.titleBadge,
      gemCost: 40,
      isOwned: false,
      isEquipped: false,
      rarity: 'uncommon',
    ),
    CosmeticItem(
      id: 'badge_legend',
      name: 'Legend Badge',
      description: 'Display "Legend" above your name',
      emoji: '👑',
      type: CosmeticType.titleBadge,
      gemCost: 100,
      isOwned: false,
      isEquipped: false,
      rarity: 'epic',
    ),
    CosmeticItem(
      id: 'badge_vortex',
      name: 'Vortex Badge',
      description: 'Display "Vortex Master" above your name',
      emoji: '🌀',
      type: CosmeticType.titleBadge,
      gemCost: 200,
      isOwned: false,
      isEquipped: false,
      rarity: 'legendary',
    ),
    // Quest Card Themes
    CosmeticItem(
      id: 'theme_ancient',
      name: 'Ancient Theme',
      description: 'Quest cards with an ancient parchment look',
      emoji: '📜',
      type: CosmeticType.questCardTheme,
      gemCost: 60,
      isOwned: false,
      isEquipped: false,
      rarity: 'uncommon',
    ),
    CosmeticItem(
      id: 'theme_neon',
      name: 'Neon Theme',
      description: 'Futuristic neon quest cards',
      emoji: '⚡',
      type: CosmeticType.questCardTheme,
      gemCost: 80,
      isOwned: false,
      isEquipped: false,
      rarity: 'rare',
    ),
    CosmeticItem(
      id: 'theme_mystical',
      name: 'Mystical Theme',
      description: 'Enchanted mystical quest cards',
      emoji: '🔮',
      type: CosmeticType.questCardTheme,
      gemCost: 120,
      isOwned: false,
      isEquipped: false,
      rarity: 'epic',
    ),
    // Emoji Packs
    CosmeticItem(
      id: 'emoji_dark',
      name: 'Dark Emoji Pack',
      description: 'Dark and moody emoji replacements',
      emoji: '🌑',
      type: CosmeticType.emojiPack,
      gemCost: 35,
      isOwned: false,
      isEquipped: false,
      rarity: 'uncommon',
    ),
    CosmeticItem(
      id: 'emoji_nature',
      name: 'Nature Emoji Pack',
      description: 'Forest and nature themed emojis',
      emoji: '🌲',
      type: CosmeticType.emojiPack,
      gemCost: 45,
      isOwned: false,
      isEquipped: false,
      rarity: 'uncommon',
    ),
    CosmeticItem(
      id: 'emoji_celestial',
      name: 'Celestial Emoji Pack',
      description: 'Stars and space themed emojis',
      emoji: '⭐',
      type: CosmeticType.emojiPack,
      gemCost: 90,
      isOwned: false,
      isEquipped: false,
      rarity: 'epic',
    ),
  ];
}
