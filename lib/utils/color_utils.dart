import 'package:flutter/material.dart';

/// Maps a rating in the range [-5, +5] to a color from red through yellow
/// to green, giving better visual separation between adjacent values.
Color ratingToColor(int rating) {
  // Normalize rating from [-5, +5] to [0.0, 1.0]
  final t = (rating + 5) / 10.0;
  if (t < 0.5) {
    // Red → Yellow for the negative-to-neutral range
    return Color.lerp(Colors.red, Colors.amber, t * 2)!;
  } else {
    // Yellow → Green for the neutral-to-positive range
    return Color.lerp(Colors.amber, Colors.green, (t - 0.5) * 2)!;
  }
}
