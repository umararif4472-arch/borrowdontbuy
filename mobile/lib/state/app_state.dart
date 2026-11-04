import 'package:flutter/foundation.dart';

import '../core/utils/trust_score.dart';
import '../core/utils/formatters.dart';
import '../data/models/user.dart';
import '../data/models/item.dart';
import '../data/models/borrow_request.dart';
import '../data/models/wishlist_item.dart';
import '../data/mock/seed_data.dart';

class AppState extends ChangeNotifier {
  late List<AppUser> _users;
  late List<Item> _items;
  late List<BorrowRequest> _requests;
  late List<WishlistItem> _wishlist;
  late List<Review> _reviews;
  int _idCounter = 100;

  AppState() {
    _users = List.of(seedUsers());
    _items = List.of(seedItems(_users));
    _requests = List.of(seedRequests());
    _reviews = List.of(seedReviews());
    _wishlist = List.of(seedWishlist());
  }

  // For tests / custom seeding
  AppState.withData({
    required List<AppUser> users,
    required List<Item> items,
    required List<BorrowRequest> requests,
    required List<WishlistItem> wishlist,
    required List<Review> reviews,
  }) {
    _users = users;
    _items = items;
    _requests = requests;
    _wishlist = wishlist;
    _reviews = reviews;
  }

  List<AppUser> get users => List.unmodifiable(_users);
  List<Item> get items => List.unmodifiable(_items);
  List<BorrowRequest> get requests => List.unmodifiable(_requests);
  List<WishlistItem> get wishlist => List.unmodifiable(_wishlist);
  List<Review> get reviews => List.unmodifiable(_reviews);

  AppUser get currentUser => _users.firstWhere((u) => u.id == 'u-maya');
  AppUser userById(String id) =>
      _users.firstWhere((u) => u.id == id, orElse: () => currentUser);
  Item itemById(String id) => _items.firstWhere((i) => i.id == id);
  List<Review> reviewsFor(String userId) =>
      _reviews.where((r) => r.revieweeId == userId).toList();

  TrustScoreResult trustFor(AppUser user) {
    final now = DateTime.now();
    final ageDays = now.difference(user.joinedAt).inDays;
    return calculateTrustScore(
      TrustHistory(
        onTimeReturns: user.stats.onTimeReturns,
        totalReturns: user.stats.onTimeReturns + user.stats.lateReturns,
        reviewRatings: reviewsFor(user.id).map((r) => r.rating).toList(),
        phoneVerified: user.phoneVerified,
        emailVerified: user.emailVerified,
        accountAgeDays: ageDays < 0 ? 0 : ageDays,
        responseRate: user.responseRate,
      ),
    );
  }

  List<Item> filteredItems({
    String query = '',
    String? category,
    double? maxDistanceKm,
    bool onlyAvailable = false,
  }) {
    final me = currentUser.homeLocation;
    final q = query.trim().toLowerCase();
    var result = _items.where((item) {
      if (onlyAvailable && !item.isAvailable) return false;
      if (category != null &&
          category.isNotEmpty &&
          item.category != category) {
        return false;
      }
      if (q.isNotEmpty) {
        final hay = '${item.title} ${item.description} ${item.category}'
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (maxDistanceKm != null) {
        if (distanceKm(me, item.location) > maxDistanceKm) return false;
      }
      return true;
    }).toList();
    result.sort(
      (a, b) =>
          distanceKm(me, a.location).compareTo(distanceKm(me, b.location)),
    );
    return result;
  }

  List<Item> get myItems =>
      _items.where((i) => i.ownerId == currentUser.id).toList();

  List<BorrowRequest> get incomingRequests {
    final myIds = myItems.map((i) => i.id).toSet();
    // include items owned by Maya even if list changes
    final owned = _items
        .where((i) => i.ownerId == currentUser.id)
        .map((i) => i.id)
        .toSet();
    final ids = {...myIds, ...owned};
    return _requests.where((r) => ids.contains(r.itemId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<BorrowRequest> get outgoingRequests {
    return _requests.where((r) => r.borrowerId == currentUser.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get pendingIncomingCount =>
      incomingRequests.where((r) => r.status == 'pending').length;

  String ownerIdFor(BorrowRequest r) => itemById(r.itemId).ownerId;

  void _replaceRequest(BorrowRequest updated) {
    final idx = _requests.indexWhere((r) => r.id == updated.id);
    if (idx >= 0) _requests[idx] = updated;
  }

  void approveRequest(String requestId) {
    final r = _requests.firstWhere((x) => x.id == requestId);
    if (r.status != 'pending') return;
    _replaceRequest(
      r.copyWith(
        status: 'approved',
        respondedAt: DateTime.now(),
        dueAt: r.period.end,
      ),
    );
    notifyListeners();
  }

  void declineRequest(String requestId) {
    final r = _requests.firstWhere((x) => x.id == requestId);
    if (r.status != 'pending') return;
    _replaceRequest(
      r.copyWith(status: 'declined', respondedAt: DateTime.now()),
    );
    notifyListeners();
  }

  void markPickedUp(String requestId) {
    final r = _requests.firstWhere((x) => x.id == requestId);
    if (r.status != 'approved') return;
    _replaceRequest(r.copyWith(status: 'active'));
    // mark item borrowed
    final idx = _items.indexWhere((i) => i.id == r.itemId);
    if (idx >= 0) _items[idx] = _items[idx].copyWith(availability: 'borrowed');
    notifyListeners();
  }

  void markReturned(String requestId, {required bool onTime}) {
    final r = _requests.firstWhere((x) => x.id == requestId);
    if (r.status != 'active' && r.status != 'approved') return;
    _replaceRequest(r.copyWith(status: 'returned', returnedAt: DateTime.now()));
    final idx = _items.indexWhere((i) => i.id == r.itemId);
    if (idx >= 0) _items[idx] = _items[idx].copyWith(availability: 'available');
    // update borrower stats
    final bIdx = _users.indexWhere((u) => u.id == r.borrowerId);
    if (bIdx >= 0) {
      final u = _users[bIdx];
      final s = u.stats;
      _users[bIdx] = u.copyWith(
        stats: s.copyWith(
          successfulBorrows: s.successfulBorrows + 1,
          onTimeReturns: s.onTimeReturns + (onTime ? 1 : 0),
          lateReturns: s.lateReturns + (onTime ? 0 : 1),
        ),
      );
    }
    // lender successful lends
    final ownerId = itemById(r.itemId).ownerId;
    final lIdx = _users.indexWhere((u) => u.id == ownerId);
    if (lIdx >= 0) {
      final u = _users[lIdx];
      _users[lIdx] = u.copyWith(
        stats: u.stats.copyWith(successfulLends: u.stats.successfulLends + 1),
      );
    }
    notifyListeners();
  }

  /// Returns null on success, or an error message.
  String? createBorrowRequest(
    Item item,
    DateTime start,
    DateTime end,
    String note,
  ) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (item.ownerId == currentUser.id) {
      return 'You cannot borrow your own item.';
    }
    if (!item.isAvailable) return 'This item is not available right now.';
    if (e.isBefore(s)) return 'End date must be on or after the start date.';
    if (s.isBefore(today)) return 'Start date cannot be in the past.';
    final days = e.difference(s).inDays + 1;
    if (days > item.borrowTerms.maxDurationDays) {
      return 'This item can be borrowed for up to ${item.borrowTerms.maxDurationDays} days.';
    }
    // overlap check against approved/active requests for same item (inclusive)
    for (final r in _requests) {
      if (r.itemId != item.id) continue;
      if (r.status != 'approved' &&
          r.status != 'active' &&
          r.status != 'pending') {
        continue;
      }
      final rs = DateTime(
        r.period.start.year,
        r.period.start.month,
        r.period.start.day,
      );
      final re = DateTime(
        r.period.end.year,
        r.period.end.month,
        r.period.end.day,
      );
      final overlaps = !s.isAfter(re) && !rs.isAfter(e);
      if (overlaps && (r.status == 'approved' || r.status == 'active')) {
        return 'Those dates overlap an existing booking for this item.';
      }
    }
    _idCounter++;
    _requests.insert(
      0,
      BorrowRequest(
        id: 'req-new-$_idCounter',
        itemId: item.id,
        borrowerId: currentUser.id,
        period: BorrowPeriod(start: s, end: e),
        note: note.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  Item createItem({
    required String title,
    required String category,
    required String description,
    required String condition,
    required int maxDurationDays,
    int? depositAmount,
    int? dailyFee,
    String pickupPreference = 'either',
    String pickupInstructions = '',
  }) {
    _idCounter++;
    final item = Item(
      id: 'i-new-$_idCounter',
      ownerId: currentUser.id,
      title: title.trim(),
      description: description.trim(),
      category: category,
      condition: condition.trim(),
      location: currentUser.homeLocation,
      availability: 'available',
      borrowTerms: BorrowTerms(
        maxDurationDays: maxDurationDays,
        depositAmount: depositAmount,
        dailyFee: dailyFee,
        pickupPreference: pickupPreference,
        pickupInstructions: pickupInstructions.trim(),
      ),
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    notifyListeners();
    return item;
  }

  void pledgePoints(String wishlistItemId, int points) {
    final idx = _wishlist.indexWhere((w) => w.id == wishlistItemId);
    if (idx < 0 || points <= 0) return;
    final w = _wishlist[idx];
    final next = w.pointsPledged + points;
    _wishlist[idx] = w.copyWith(
      pointsPledged: next > w.targetPoints ? w.targetPoints : next,
    );
    notifyListeners();
  }

  void needThisToo(String wishlistItemId) {
    final idx = _wishlist.indexWhere((w) => w.id == wishlistItemId);
    if (idx < 0) return;
    _wishlist[idx] = _wishlist[idx].copyWith(
      requestCount: _wishlist[idx].requestCount + 1,
    );
    notifyListeners();
  }
}
