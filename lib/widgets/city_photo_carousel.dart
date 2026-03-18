import 'dart:io';
import 'package:flutter/material.dart';
import '../models/city_model.dart';

class CityPhotoCarousel extends StatelessWidget {
  final List<Photo> photos;

  const CityPhotoCarousel({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRect( // 🔒 verhindert Overflow
      child: SizedBox(
        height: double.infinity, // 👈 bekommt Höhe vom Expanded der Card
        width: double.infinity,
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return Image.file(
              File(photos[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),
      ),
    );
  }
}
