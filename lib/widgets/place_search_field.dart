import 'dart:async';
import 'package:flutter/material.dart';

/// 🔍 Platzhalter für OSM-basierte Suche
/// Wird später durch echte OSM / lokale Search ersetzt
class PlaceSearchField extends StatefulWidget {
  final void Function(String placeId) onSelected;
  final double? latitude;
  final double? longitude;

  const PlaceSearchField({
    super.key,
    required this.onSelected,
    this.latitude,
    this.longitude,
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  /// 🚧 OSM Search Results (temporär leer / lokal)
  List<_OsmSearchResult> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final query = value.trim();

      if (query.isEmpty) {
        if (mounted) setState(() => _results = []);
        return;
      }

      // ─────────────────────────────────────────────
      // 🚧 TEMP: OSM Search Stub
      // Später ersetzen durch:
      // - lokale OSM Index Suche
      // - oder Server-Search (Nominatim / eigener Index)
      // ─────────────────────────────────────────────

      final results = <_OsmSearchResult>[
        _OsmSearchResult(
          id: 'osm_$query',
          label: query,
        ),
      ];

      if (!mounted) return;
      setState(() => _results = results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search places...',
          ),
        ),

        // 🔽 Results
        ..._results.map(
          (r) => ListTile(
            title: Text(r.label),
            onTap: () {
              widget.onSelected(r.id);
              _controller.text = r.label;
              setState(() => _results = []);
            },
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────
/// Interne OSM Search Result Struktur
/// ─────────────────────────────────────────────
class _OsmSearchResult {
  final String id;
  final String label;

  _OsmSearchResult({
    required this.id,
    required this.label,
  });
}
