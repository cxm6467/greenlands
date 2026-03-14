class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType questType;
  final QuestDifficulty difficulty;
  final QuestStatus status;
  final int xpReward;
  final List<QuestObjective> objectives;
  final int requiredLevel;
  final List<String> prerequisites;
  final bool isGenerated;
  final String? generationContext;
  final String? recurrenceRule;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Quest({
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

  /// Check if the quest is available to accept
  bool get isAvailable => status == QuestStatus.available;

  /// Check if the quest is currently active
  bool get isActive => status == QuestStatus.active;

  /// Check if the quest is completed
  bool get isCompleted => status == QuestStatus.completed;

  /// Check if all objectives are completed
  bool get areAllObjectivesCompleted =>
      objectives.every((obj) => obj.completed);

  /// Get the number of completed objectives
  int get completedObjectivesCount =>
      objectives.where((obj) => obj.completed).length;

  /// Get progress as a percentage
  double get progressPercent =>
      objectives.isEmpty ? 0 : completedObjectivesCount / objectives.length;

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? questType,
    QuestDifficulty? difficulty,
    QuestStatus? status,
    int? xpReward,
    List<QuestObjective>? objectives,
    int? requiredLevel,
    List<String>? prerequisites,
    bool? isGenerated,
    String? generationContext,
    String? recurrenceRule,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questType: questType ?? this.questType,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      objectives: objectives ?? this.objectives,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      prerequisites: prerequisites ?? this.prerequisites,
      isGenerated: isGenerated ?? this.isGenerated,
      generationContext: generationContext ?? this.generationContext,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Quest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QuestObjective {
  final String text;
  final bool completed;

  const QuestObjective({required this.text, required this.completed});

  QuestObjective copyWith({String? text, bool? completed}) {
    return QuestObjective(
      text: text ?? this.text,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestObjective && other.text == text;
  }

  @override
  int get hashCode => text.hashCode;
}

enum QuestType {
  main('Main Quest', '⚔️', 'Critical to the main story'),
  side('Side Quest', '📜', 'Optional adventures and tales'),
  daily('Daily Quest', '🔄', 'Repeating daily challenges'),
  generated('Generated Quest', '🤖', 'AI-generated adventure');

  final String displayName;
  final String emoji;
  final String description;

  const QuestType(this.displayName, this.emoji, this.description);
}

enum QuestDifficulty {
  easy('Easy', '⭐', 'Suitable for beginners'),
  medium('Medium', '⭐⭐', 'Moderate challenge'),
  hard('Hard', '⭐⭐⭐', 'For experienced adventurers');

  final String displayName;
  final String emoji;
  final String description;

  const QuestDifficulty(this.displayName, this.emoji, this.description);
}

enum QuestStatus {
  available('Available', '📋', 'Ready to accept'),
  active('Active', '🔥', 'Currently pursuing'),
  completed('Completed', '✅', 'Successfully finished'),
  failed('Failed', '❌', 'Quest was abandoned');

  final String displayName;
  final String emoji;
  final String description;

  const QuestStatus(this.displayName, this.emoji, this.description);
}
