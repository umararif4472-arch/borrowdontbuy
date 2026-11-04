# Borrow Don't Buy — Mobile

Flutter port of Borrow Don't Buy: borrow tools, gear, and party equipment
from neighbors instead of buying them, with trust built through a 0–100
reputation score instead of payments.

## Run

```bash
flutter pub get
flutter run -d chrome    # or windows / an Android device
flutter test             # trust-score, app-state, and widget tests
flutter analyze
```

## Structure

```
lib/
├ core/       theme (terracotta / moss / cream, Material 3),
│             trust-score calculator + formatters, shared widgets
├ data/       models (User, Item, BorrowRequest, WishlistItem)
│             and mock seed data ported from the web app
├ state/      AppState (provider / ChangeNotifier) — filtering,
│             request lifecycle, listing, wishlist pledges
└ ui/         app shell (Explore, Wishlist, Activity, Profile +
              List-item FAB) and feature screens
```

State is in-memory for the prototype, same seed users/items/requests as
the web app at the repo root, so trust scores match across both clients.
