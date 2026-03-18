import 'package:flutter/material.dart';
import '../utils/continent_data.dart';
import '../widgets/continent_detail_sheet.dart';

class ContinentProgress extends StatelessWidget {
  final Map<String, int> progress;
  final Set<String> visitedCountries;

  const ContinentProgress({
    super.key,
    required this.progress,
    required this.visitedCountries,
  });

  Color _continentColor(String continent, bool completed) {
    if (completed) {
      return const Color(0xFFFFD700); // 🥇 Gold
    }

    switch (continent) {
      case 'Europe':
        return Colors.blue;
      case 'Asia':
        return Colors.red;
      case 'Africa':
        return Colors.orange;
      case 'North America':
        return Colors.green;
      case 'South America':
        return Colors.teal;
      case 'Oceania':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _continentEmoji(String continent) {
    switch (continent) {
      case 'Europe':
        return '🌍';
      case 'Asia':
        return '🌏';
      case 'Africa':
        return '🌍';
      case 'North America':
        return '🌎';
      case 'South America':
        return '🌎';
      case 'Oceania':
        return '🌊';
      default:
        return '🗺️';
    }
  }

  void _openContinentDetails(BuildContext context, String continent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ContinentDetailSheet(
        continent: continent,
        visitedCountries: visitedCountries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: continentTotals.keys.map((continent) {
        final int visited = progress[continent] ?? 0;
        final int total = continentTotals[continent] ?? 0;

        final double value = total == 0 ? 0 : visited / total;
        final int percent = (value * 100).clamp(0, 100).round();
        final bool completed = total > 0 && visited >= total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌐 Header (tap opens detail sheet)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openContinentDetails(context, continent),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left
                      Text(
                        '${_continentEmoji(continent)} $continent',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Right
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            completed ? '100% ✓' : '$percent%',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: completed
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$visited of $total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // 📊 Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _continentColor(continent, completed),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
