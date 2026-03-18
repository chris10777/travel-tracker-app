import 'package:flutter/material.dart';
import '../models/city_model.dart';

Future<CityDetailedRating?> showCityRatingDialog(
  BuildContext context,
  String cityName, {
  CityDetailedRating? initial,
}) {
  return showDialog<CityDetailedRating>(
    context: context,
    builder: (context) =>
        CityRatingDialog(cityName: cityName, initial: initial),
  );
}

class CityRatingDialog extends StatefulWidget {
  final String cityName;
  final CityDetailedRating? initial;

  const CityRatingDialog({
    super.key,
    required this.cityName,
    this.initial,
  });

  @override
  State<CityRatingDialog> createState() => _CityRatingDialogState();
}

class _CityRatingDialogState extends State<CityRatingDialog> {
  late double flair;
  late double food;
  late double culture;
  late double safety;
  late double nature;
  late TextEditingController favoriteController;

  @override
  void initState() {
    super.initState();
    flair = widget.initial?.flair ?? 5;
    food = widget.initial?.food ?? 5;
    culture = widget.initial?.culture ?? 5;
    safety = widget.initial?.safety ?? 5;
    nature = widget.initial?.nature ?? 5;
    favoriteController =
        TextEditingController(text: widget.initial?.favoritePlace ?? '');
  }

  @override
  void dispose() {
    favoriteController.dispose();
    super.dispose();
  }

  double get topValue =>
      [flair, food, culture, safety, nature].reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text('Rate ${widget.cityName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlider(
              context,
              icon: Icons.auto_awesome,
              label: 'Flair',
              tooltip: 'Overall vibe and charm',
              value: flair,
              isTop: flair == topValue,
              isDark: isDark,
              onChanged: (v) => setState(() => flair = v),
            ),
            _buildSlider(
              context,
              icon: Icons.restaurant,
              label: 'Food',
              tooltip: 'Quality and variety of food',
              value: food,
              isTop: food == topValue,
              isDark: isDark,
              onChanged: (v) => setState(() => food = v),
            ),
            _buildSlider(
              context,
              icon: Icons.account_balance,
              label: 'Culture & Architecture',
              tooltip: 'Historical sites & cultural experiences',
              value: culture,
              isTop: culture == topValue,
              isDark: isDark,
              onChanged: (v) => setState(() => culture = v),
            ),
            _buildSlider(
              context,
              icon: Icons.health_and_safety,
              label: 'Safety & Hygiene',
              tooltip: 'Feeling safe and hygienic in the city',
              value: safety,
              isTop: safety == topValue,
              isDark: isDark,
              onChanged: (v) => setState(() => safety = v),
            ),
            _buildSlider(
              context,
              icon: Icons.park,
              label: 'Nature & Parks',
              tooltip: 'Availability of parks and green spaces',
              value: nature,
              isTop: nature == topValue,
              isDark: isDark,
              onChanged: (v) => setState(() => nature = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: favoriteController,
              decoration: const InputDecoration(
                labelText: 'Favorite Place (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              CityDetailedRating(
                flair: flair,
                food: food,
                culture: culture,
                safety: safety,
                nature: nature,
                favoritePlace: favoriteController.text,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────

  Widget _buildSlider(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
    required double value,
    required bool isTop,
    required bool isDark,
    required ValueChanged<double> onChanged,
  }) {
    final Color highlightColor = Colors.amber.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: tooltip,
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isTop ? highlightColor : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                '$label: ${value.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                  color: isTop ? highlightColor : null,
                ),
              ),
              if (isTop) ...[
                const SizedBox(width: 6),
                const Icon(Icons.star, size: 16, color: Colors.amber),
              ],
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:
                isDark ? highlightColor.withOpacity(0.9) : null,
            inactiveTrackColor:
                isDark ? Colors.grey.shade700 : null,
            thumbColor: highlightColor,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 100,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
