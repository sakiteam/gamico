import 'package:flutter/material.dart';

/// Id used when a game offers no choice for the rematch: everyone simply votes
/// "the same game again".
const String kGamicoSameGameReplayOption = "same";

/// One choice offered at the end of an online match — a game mode, a board
/// size, a difficulty… Whatever the game lets players change before the
/// rematch.
///
/// The framework only ever compares [id]s (they travel between devices and
/// must be stable across versions); [label] and [icon] are the game's, already
/// localized.
@immutable
class GamicoReplayOption {
  final String id;
  final String label;
  final IconData icon;

  const GamicoReplayOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      other is GamicoReplayOption &&
      other.id == id &&
      other.label == label &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(id, label, icon);
}
