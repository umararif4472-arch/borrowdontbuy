# Borrow Don't Buy 🏡

> Why buy it when your neighbor already owns one?

A hyperlocal peer-to-peer lending network: neighbors list items they own but
rarely use (tools, gear, party equipment) so people nearby can borrow them —
free or for a small fee. Trust is built through an on-screen reputation
system instead of payment processing.

**Fully working prototype** — every button, form, and flow runs end-to-end
against an in-memory mock data layer with simulated network latency.

## Run it

```bash
npm install
npm run dev        # → http://localhost:5173
```

Other scripts:

```bash
npm test           # 65 unit tests (pure utils + form reducer)
npm run build      # type-check (tsc) + production build
npm run preview    # serve the production build
```

You're "signed in" as **Maya Chen** (`u-maya`, Richmond) — the mock session
user.

## Architecture

One rule keeps the mock layer swappable for a real backend later:
**components never import seeds or the store directly — everything goes
through `@/services` and `@/context`.**

```
src/
├── types/          # Data models (User, Item, BorrowRequest, Review, …)
├── utils/          # Pure logic — trustScore, dates, distance, filters,
│                   #   validation, mapProjection (all unit-tested)
├── data/seed/      # Mock seed data (builders with relative dates)
├── services/       # Data access layer: in-memory "DB" + async API that
│                   #   simulates latency and enforces all business rules
├── context/        # AppProvider + useReducer (global state, hydration)
├── hooks/          # useItems, useFilteredItems, useTrustScore(s),
│                   #   useRequests, useNotifications, useMessages, useAsync
├── components/     # Dumb/presentational: ui/ kit, items/, reviews/, layout/
└── features/       # Feature pages: landing, browse (incl. ItemMap),
                    #   item-detail, list-item (form reducer + drafts),
                    #   dashboard, profile, messages, not-found
```

### Key design decisions

- **Trust score is a pure function** (`utils/trustScore.ts`): history in →
  0–100 score + tier out. Never stored; recomputed from users + reviews
  wherever a name appears, so returns/reviews move scores visibly.
  Weights: on-time returns 40 · reviews 25 · verification 10 · account age
  10 · responsiveness 15.
- **Service layer = the mock server.** All mutations validate there
  (ownership, state transitions, date-range overlaps, double-review
  prevention), so client-side validation can't drift into data corruption.
  Reads deep-clone results like an HTTP boundary would. Swapping to real
  HTTP means reimplementing `services/*` only.
- **Filtering lives in hooks.** `useFilteredItems` wraps the same pure
  `filterItems` util the service uses; the browse UI never runs inline
  `.filter()` in JSX. Search input is debounced (250 ms).
- **List-an-item is one reducer** (`features/list-item/listItemForm.ts`) —
  draft values, step index, and per-step validation with visible inline
  errors. Drafts persist to localStorage, so leaving mid-form restores
  progress (with a "Start over" escape hatch). Publishing calls
  `itemsApi.createItem` → shared store → context, so the new listing is
  visible app-wide instantly.
- **Custom SVG map** (`features/browse/ItemMap.tsx`): no map library — pins
  are placed by a unit-tested lat/lng→pixel projection with uniform scale,
  so pin spacing and the radius-filter ring match real-world kilometers.
  Pins are real buttons (keyboard accessible) and open preview cards.

### Request lifecycle

```
pending → approved → active → completed
   ↘ declined    (markPickedUp)  (markReturned — updates user stats,
                                  which feeds the trust score)
```

Seeded state covers every phase: a pending incoming request (approve/decline
in the dashboard), a pending outgoing request, an active borrow due
tomorrow, a completed borrow awaiting review, and a declined request.

## Design language

Warm and neighborly, not corporate SaaS: terracotta (action) + moss green
(trust) + cream/bark neutrals, rounded 3xl corners, emoji-forward category
identity, friendly empty states ("This page wandered off the block 🧭").
Mobile-first: bottom tab bar with a raised "list an item" CTA, sticky item
CTA bar, and map/list toggle on /browse.

## Notes & known limits

- Mock state is per-session: a full browser reload reseeds the in-memory
  store (SPA navigation preserves all writes). Draft persistence for the
  listing form survives reloads via localStorage.
- Item photos use `picsum.photos` (needs internet); every photo surface has
  an emoji fallback tile, and one seeded item ships photo-less on purpose.
- "Share" uses the Web Share API with clipboard-copy fallback.
