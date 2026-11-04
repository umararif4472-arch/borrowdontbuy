class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);
}

class UserStats {
  final int successfulLends;
  final int successfulBorrows;
  final int onTimeReturns;
  final int lateReturns;
  const UserStats({
    required this.successfulLends,
    required this.successfulBorrows,
    required this.onTimeReturns,
    required this.lateReturns,
  });
  UserStats copyWith({
    int? successfulLends,
    int? successfulBorrows,
    int? onTimeReturns,
    int? lateReturns,
  }) {
    return UserStats(
      successfulLends: successfulLends ?? this.successfulLends,
      successfulBorrows: successfulBorrows ?? this.successfulBorrows,
      onTimeReturns: onTimeReturns ?? this.onTimeReturns,
      lateReturns: lateReturns ?? this.lateReturns,
    );
  }
}

class UserBadge {
  final String id;
  final String label;
  final String description;
  final DateTime earnedAt;
  const UserBadge({
    required this.id,
    required this.label,
    required this.description,
    required this.earnedAt,
  });
}

class AppUser {
  final String id;
  final String name;
  final String bio;
  final String neighborhood;
  final LatLng homeLocation;
  final DateTime joinedAt;
  final bool phoneVerified;
  final bool emailVerified;
  final double responseRate;
  final int avgResponseMinutes;
  final UserStats stats;
  final List<UserBadge> badges;
  const AppUser({
    required this.id,
    required this.name,
    required this.bio,
    required this.neighborhood,
    required this.homeLocation,
    required this.joinedAt,
    required this.phoneVerified,
    required this.emailVerified,
    required this.responseRate,
    required this.avgResponseMinutes,
    required this.stats,
    required this.badges,
  });
  AppUser copyWith({UserStats? stats}) {
    return AppUser(
      id: id,
      name: name,
      bio: bio,
      neighborhood: neighborhood,
      homeLocation: homeLocation,
      joinedAt: joinedAt,
      phoneVerified: phoneVerified,
      emailVerified: emailVerified,
      responseRate: responseRate,
      avgResponseMinutes: avgResponseMinutes,
      stats: stats ?? this.stats,
      badges: badges,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class Review {
  final String id;
  final String requestId;
  final String itemId;
  final String reviewerId;
  final String revieweeId;
  final String reviewerRole; // lender | borrower
  final int rating;
  final String comment;
  final DateTime createdAt;
  const Review({
    required this.id,
    required this.requestId,
    required this.itemId,
    required this.reviewerId,
    required this.revieweeId,
    required this.reviewerRole,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
