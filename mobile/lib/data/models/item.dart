import 'user.dart';

const List<String> kItemCategories = [
  'Tools',
  'Outdoor & Camping',
  'Party & Events',
  'Kitchen',
  'Electronics',
  'Sports',
  'Kids & Baby',
  'Cars & Vehicles',
  'Houses & Places',
  'Indoor Sports',
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
  BorrowTerms copyWith({
    int? maxDurationDays,
    int? depositAmount,
    bool clearDeposit = false,
    int? dailyFee,
    bool clearFee = false,
    String? pickupPreference,
    String? pickupInstructions,
  }) {
    return BorrowTerms(
      maxDurationDays: maxDurationDays ?? this.maxDurationDays,
      depositAmount: clearDeposit
          ? null
          : (depositAmount ?? this.depositAmount),
      dailyFee: clearFee ? null : (dailyFee ?? this.dailyFee),
      pickupPreference: pickupPreference ?? this.pickupPreference,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
    );
  }
}

class Item {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final String condition;
  final List<String> photos;
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
    this.photos = const [],
    required this.location,
    required this.availability,
    required this.borrowTerms,
    required this.createdAt,
  });
  bool get isAvailable => availability == 'available';
  Item copyWith({
    String? title,
    String? description,
    String? category,
    String? condition,
    String? availability,
    BorrowTerms? borrowTerms,
    List<String>? photos,
  }) {
    return Item(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      photos: photos ?? this.photos,
      location: location,
      availability: availability ?? this.availability,
      borrowTerms: borrowTerms ?? this.borrowTerms,
      createdAt: createdAt,
    );
  }
}
