import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorldMap extends StatelessWidget {
  final Set<String> visitedCountries;

  const WorldMap({super.key, required this.visitedCountries});

  Future<String> _loadSvg(BuildContext context) async {
    String svg = await rootBundle.loadString('assets/maps/world.svg');

    for (final code in visitedCountries) {
      svg = svg.replaceAll(
        'id="$code"',
        'id="$code" fill="#4CAF50"', // green
      );
    }

    return svg;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadSvg(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SvgPicture.string(
          snapshot.data!,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
