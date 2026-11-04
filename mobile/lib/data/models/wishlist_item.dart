class WishlistItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final int targetPoints;
  final int pointsPledged;
  final int requestCount;
  final String requestedByName;
  const WishlistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetPoints,
    required this.pointsPledged,
    required this.requestCount,
    required this.requestedByName,
  });
  double get progress =>
      targetPoints == 0 ? 0 : (pointsPledged / targetPoints).clamp(0.0, 1.0);
  WishlistItem copyWith({int? pointsPledged, int? requestCount}) {
    return WishlistItem(
      id: id,
      title: title,
      description: description,
      category: category,
      targetPoints: targetPoints,
      pointsPledged: pointsPledged ?? this.pointsPledged,
      requestCount: requestCount ?? this.requestCount,
      requestedByName: requestedByName,
    );
  }
}
