import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/character.dart';
import '../../providers/character_provider.dart';

class FellowshipRoleWidget extends ConsumerWidget {
  const FellowshipRoleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(characterCreationProvider).fellowshipRole;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '👥 Choose Your Fellowship Role 👥',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: FellowshipRole.values.map((role) {
                final isSelected = selectedRole == role;

                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : null,
                  child: InkWell(
                    onTap: () {
                      ref.read(characterCreationProvider.notifier).setFellowshipRole(role);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text(
                            role.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
