import 'package:flutter/material.dart';

Color ratingColor(String label) {
  switch (label) {
    case 'Flair':
      return Colors.deepPurple;
    case 'Food':
      return Colors.orange;
    case 'Culture & Architecture':
      return Colors.blue;
    case 'Safety & Hygiene':
      return Colors.teal;
    case 'Nature & Parks':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

Color ratingBadgeColor(double rating) {
  if (rating >= 8.5) return Colors.amber;
  if (rating >= 7.0) return Colors.green;
  return Colors.grey;
}
