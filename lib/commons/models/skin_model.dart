import 'package:flutter/material.dart';

/// Énumération pour la rareté des skins
enum SkinRarity { common, rare, epic, legendary }

/// Extension pour obtenir une représentation visuelle de la rareté
extension SkinRarityExtension on SkinRarity {
  String get displayName {
    switch (this) {
      case SkinRarity.common:
        return 'Common';
      case SkinRarity.rare:
        return 'Rare';
      case SkinRarity.epic:
        return 'Epic';
      case SkinRarity.legendary:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case SkinRarity.common:
        return Colors.grey;
      case SkinRarity.rare:
        return Colors.blue;
      case SkinRarity.epic:
        return Colors.purple;
      case SkinRarity.legendary:
        return Colors.orange;
    }
  }
}

/// Modèle pour les skins des pions
class SkinModel {
  final String id;
  final String name;
  final int price;
  final String assetPath;
  final SkinRarity rarity;

  const SkinModel({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    required this.rarity,
  });
}
