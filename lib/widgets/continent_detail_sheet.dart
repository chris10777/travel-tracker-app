import 'package:flutter/material.dart';
import '../utils/continent_data.dart';
import '../utils/country_flag.dart';

class ContinentDetailSheet extends StatelessWidget {
  final String continent;
  final Set<String> visitedCountries;

  const ContinentDetailSheet({
    super.key,
    required this.continent,
    required this.visitedCountries,
  });

  @override
  Widget build(BuildContext context) {
    final allCountries = continentToCountries[continent] ?? [];

    final visited =
        allCountries.where((c) => visitedCountries.contains(c)).toList();
    final missing =
        allCountries.where((c) => !visitedCountries.contains(c)).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

// ─── Header: Handle + Close Button ─────────────────────────
SizedBox(
  height: 56, // ⬇️ deutlich niedriger
  width: double.infinity,
  child: Stack(
    children: [
      // Handle (klar tiefer positioniert)
      Positioned(
        top: 24,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),

      // Close Button (rechts, NICHT oben)
      Positioned(
        top: 18,
        right: 0,
        child: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 30,
          splashRadius: 22,
          tooltip: 'Close',
          color: Colors.grey.shade700,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    ],
  ),
),



            const SizedBox(height: 14),

            // ─── Title ───────────────────────────────────────────────
            Text(
              continent,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${visited.length} of ${allCountries.length} countries visited',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 16),

            // ─── Content ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                children: [
                  _section(
                    title: 'Visited',
                    countries: visited,
                    visited: true,
                  ),
                  const SizedBox(height: 20),
                  _section(
                    title: 'Missing',
                    countries: missing,
                    visited: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  Widget _section({
    required String title,
    required List<String> countries,
    required bool visited,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: visited ? Colors.green : Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: visited
                    ? Colors.green.withOpacity(0.15)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                countries.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      visited ? Colors.green.shade800 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Country List
        ...countries.map(
          (code) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  countryCodeToEmoji(code),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    countryNames[code] ?? code,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          visited ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (visited)
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

