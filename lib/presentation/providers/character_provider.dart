import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/character.dart';
import '../../domain/usecases/character/create_character.dart';
import '../../domain/usecases/character/get_player_character.dart';

/// Provider for the current player character
final characterProvider = StateNotifierProvider<CharacterNotifier, AsyncValue<Character?>>((ref) {
  return CharacterNotifier(
    getPlayerCharacter: getIt<GetPlayerCharacter>(),
    createCharacter: getIt<CreateCharacter>(),
  );
});

class CharacterNotifier extends StateNotifier<AsyncValue<Character?>> {
  final GetPlayerCharacter _getPlayerCharacter;
  final CreateCharacter _createCharacter;

  CharacterNotifier({
    required GetPlayerCharacter getPlayerCharacter,
    required CreateCharacter createCharacter,
  })  : _getPlayerCharacter = getPlayerCharacter,
        _createCharacter = createCharacter,
        super(const AsyncValue.loading()) {
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    state = const AsyncValue.loading();
    try {
      final character = await _getPlayerCharacter();
      state = AsyncValue.data(character);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createNewCharacter({
    required String name,
    required CharacterRace race,
    required CharacterClass characterClass,
    required FellowshipRole fellowshipRole,
    required Map<String, int> allocatedStats,
  }) async {
    state = const AsyncValue.loading();
    try {
      final character = await _createCharacter(
        name: name,
        race: race,
        characterClass: characterClass,
        fellowshipRole: fellowshipRole,
        allocatedStats: allocatedStats,
      );
      state = AsyncValue.data(character);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Provider for character creation state
final characterCreationProvider = StateNotifierProvider<CharacterCreationNotifier, CharacterCreationState>((ref) {
  return CharacterCreationNotifier();
});

class CharacterCreationState {
  final String name;
  final CharacterRace? race;
  final CharacterClass? characterClass;
  final FellowshipRole? fellowshipRole;
  final Map<String, int> allocatedStats;
  final int currentStep;

  const CharacterCreationState({
    this.name = '',
    this.race,
    this.characterClass,
    this.fellowshipRole,
    this.allocatedStats = const {},
    this.currentStep = 0,
  });

  CharacterCreationState copyWith({
    String? name,
    CharacterRace? race,
    CharacterClass? characterClass,
    FellowshipRole? fellowshipRole,
    Map<String, int>? allocatedStats,
    int? currentStep,
  }) {
    return CharacterCreationState(
      name: name ?? this.name,
      race: race ?? this.race,
      characterClass: characterClass ?? this.characterClass,
      fellowshipRole: fellowshipRole ?? this.fellowshipRole,
      allocatedStats: allocatedStats ?? this.allocatedStats,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  bool get isNameValid => name.trim().isNotEmpty && name.length <= 50;
  bool get isRaceSelected => race != null;
  bool get isClassSelected => characterClass != null;
  bool get isFellowshipRoleSelected => fellowshipRole != null;
  bool get areStatsAllocated {
    final totalPoints = allocatedStats.values.fold(0, (sum, val) => sum + val);
    return totalPoints == 10;
  }

  bool get isComplete =>
      isNameValid &&
      isRaceSelected &&
      isClassSelected &&
      isFellowshipRoleSelected &&
      areStatsAllocated;
}

class CharacterCreationNotifier extends StateNotifier<CharacterCreationState> {
  CharacterCreationNotifier() : super(const CharacterCreationState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setRace(CharacterRace race) {
    state = state.copyWith(race: race);
  }

  void setClass(CharacterClass characterClass) {
    state = state.copyWith(characterClass: characterClass);
  }

  void setFellowshipRole(FellowshipRole role) {
    state = state.copyWith(fellowshipRole: role);
  }

  void setAllocatedStats(Map<String, int> stats) {
    state = state.copyWith(allocatedStats: stats);
  }

  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = const CharacterCreationState();
  }
}
