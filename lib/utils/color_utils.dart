import 'package:flutter/material.dart';

/// Maps a rating in the range [-5, +5] to a color from red to green.
Color ratingToColor(int rating) {
  // Normalize rating from [-5, +5] to [0.0, 1.0]
  final t = (rating + 5) / 10.0;
  return Color.lerp(Colors.red, Colors.green, t)!;
}
