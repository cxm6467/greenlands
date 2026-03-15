import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cosmetic_item.dart';

/// Provider for cosmetic shop inventory (stub implementation, in-memory)
final shopProvider = StateNotifierProvider<ShopNotifier, List<CosmeticItem>>((
  ref,
) {
  return ShopNotifier();
});

class ShopNotifier extends StateNotifier<List<CosmeticItem>> {
  ShopNotifier() : super(createStubCosmeticCatalog());

  /// Purchase a cosmetic item (deducts gems, marks as owned)
  bool purchaseItem(String itemId, int currentGems) {
    final item = state.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    if (currentGems < item.gemCost) {
      return false; // Insufficient gems
    }

    // Mark as owned
    state = state.map((cosmetic) {
      if (cosmetic.id == itemId) {
        return cosmetic.copyWith(isOwned: true);
      }
      return cosmetic;
    }).toList();

    return true;
  }

  /// Equip a cosmetic item (unequips others of the same type)
  void equipItem(String itemId) {
    late final CosmeticItem item;
    try {
      item = state.firstWhere((i) => i.id == itemId);
    } catch (_) {
      throw Exception('Item not found');
    }

    state = state.map((cosmetic) {
      // Unequip others of the same type
      if (cosmetic.type == item.type && cosmetic.id != itemId) {
        return cosmetic.copyWith(isEquipped: false);
      }
      // Equip the selected item
      if (cosmetic.id == itemId) {
        return cosmetic.copyWith(isEquipped: true);
      }
      return cosmetic;
    }).toList();
  }

  /// Unequip a cosmetic item
  void unequipItem(String itemId) {
    state = state.map((cosmetic) {
      if (cosmetic.id == itemId) {
        return cosmetic.copyWith(isEquipped: false);
      }
      return cosmetic;
    }).toList();
  }

  /// Get items by type
  List<CosmeticItem> getItemsByType(CosmeticType type) {
    return state.where((item) => item.type == type).toList();
  }

  /// Get all owned items
  List<CosmeticItem> getOwnedItems() {
    return state.where((item) => item.isOwned).toList();
  }

  /// Get all equipped items
  List<CosmeticItem> getEquippedItems() {
    return state.where((item) => item.isEquipped).toList();
  }
}
