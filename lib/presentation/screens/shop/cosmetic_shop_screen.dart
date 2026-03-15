import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/cosmetic_item.dart';
import '../../providers/mini_game_provider.dart';
import '../../providers/shop_provider.dart';

class CosmeticShopScreen extends ConsumerWidget {
  const CosmeticShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shopProvider);
    final gems = ref.watch(gemsProvider);
    final itemsByType = <CosmeticType, List<CosmeticItem>>{};

    for (final item in items) {
      itemsByType.putIfAbsent(item.type, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('COSMETIC SHOP'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Row(
                children: [
                  Text(
                    '💎 $gems',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GreenlandsTheme.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Add Gems button (stub IAP)
          ElevatedButton.icon(
            onPressed: () => _showIapStubDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('ADD GEMS'),
          ),
          const SizedBox(height: 24),
          // Items by type
          ...itemsByType.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...entry.value.map((item) {
                  return _buildItemCard(context, ref, item, gems);
                }),
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    CosmeticItem item,
    int currentGems,
  ) {
    final canAfford = currentGems >= item.gemCost;
    final rarityColor = GreenlandsTheme.getRarityColor(item.rarity ?? 'common');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.rarity != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha: 0.2),
                            border: Border.all(color: rarityColor, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.rarity!.toUpperCase(),
                            style: TextStyle(
                              color: rarityColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                if (item.isOwned)
                  Column(
                    children: [
                      const Text(
                        'OWNED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.isEquipped)
                        const Text(
                          '✓ EQUIPPED',
                          style: TextStyle(
                            fontSize: 10,
                            color: GreenlandsTheme.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        '💎 ${item.gemCost}',
                        style: TextStyle(
                          color: canAfford
                              ? GreenlandsTheme.accentGold
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed: canAfford
                              ? () => _purchaseItem(
                                  context,
                                  ref,
                                  item,
                                  currentGems,
                                )
                              : null,
                          child: const Text(
                            'BUY',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(
    BuildContext context,
    WidgetRef ref,
    CosmeticItem item,
    int currentGems,
  ) {
    final canAfford = currentGems >= item.gemCost;

    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough gems! Play mini-games to earn more.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final shopNotifier = ref.read(shopProvider.notifier);
    final success = shopNotifier.purchaseItem(item.id, currentGems);

    if (success) {
      ref.read(gemsProvider.notifier).removeGems(item.gemCost);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchased ${item.name}!'),
          backgroundColor: GreenlandsTheme.successGreen,
        ),
      );
    }
  }

  void _showIapStubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💎 ADD GEMS'),
        content: const Text(
          'In-app purchases are coming soon! For now, earn gems by playing mini-games when you complete quest objectives.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
