enum PlaceCategory { activity, restaurant }

class SavedPlace {
  final String placeId;
  final String name;
  final double rating;
  final int userRatingsTotal;
  final String address;
  final PlaceCategory category;
  bool visited;

  SavedPlace({
    required this.placeId,
    required this.name,
    required this.rating,
    required this.userRatingsTotal,
    required this.address,
    required this.category,
    this.visited = false,
  });

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'rating': rating,
        'userRatingsTotal': userRatingsTotal,
        'address': address,
        'category': category.name,
        'visited': visited,
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      placeId: json['placeId'],
      name: json['name'],
      rating: (json['rating'] as num).toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
      address: json['address'],
      category: PlaceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PlaceCategory.activity,
      ),
      visited: json['visited'] ?? false,
    );
  }
}
