import 'user.dart';

const List<String> kItemCategories = [
  'Tools',
  'Outdoor & Camping',
  'Party & Events',
  'Kitchen',
  'Electronics',
  'Sports',
  'Kids & Baby',
  'Other',
];

class BorrowTerms {
  final int maxDurationDays;
  final int? depositAmount;
  final int? dailyFee;
  final String pickupPreference; // pickup | drop-off | either
  final String pickupInstructions;
  const BorrowTerms({
    required this.maxDurationDays,
    required this.depositAmount,
    required this.dailyFee,
    required this.pickupPreference,
    required this.pickupInstructions,
  });
}

class Item {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final String condition;
  final LatLng location;
  final String availability; // available | borrowed | unavailable
  final BorrowTerms borrowTerms;
  final DateTime createdAt;
  const Item({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.location,
    required this.availability,
    required this.borrowTerms,
    required this.createdAt,
  });
  bool get isAvailable => availability == 'available';
  Item copyWith({String? availability}) {
    return Item(
      id: id,
      ownerId: ownerId,
      title: title,
      description: description,
      category: category,
      condition: condition,
      location: location,
      availability: availability ?? this.availability,
      borrowTerms: borrowTerms,
      createdAt: createdAt,
    );
  }
}
