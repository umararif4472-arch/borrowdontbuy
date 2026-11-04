import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/reviews_list.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/item.dart';
import '../../../state/app_state.dart';
import '../not_found/not_found_screen.dart';
import '../profile/user_profile_screen.dart';
import 'photo_gallery_screen.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  Future<void> _share(BuildContext context, Item item) async {
    final text =
        'Borrow instead of buying: ${item.title} (${item.category}) — '
        '${item.borrowTerms.dailyFee == null ? 'free to borrow' : '\$${item.borrowTerms.dailyFee}/day'}, '
        'up to ${item.borrowTerms.maxDurationDays} days on Borrow Don\u2019t Buy.';
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, subject: item.title),
      );
      if (result.status == ShareResultStatus.unavailable) {
        throw StateError('share unavailable');
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Link copied')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final item = state.itemByIdOrNull(itemId);
    if (item == null) {
      return const NotFoundScreen(
        message: 'That item is not listed anymore — it may have been removed by its owner.',
      );
    }
    final owner = state.userById(item.ownerId);
    final trust = state.trustFor(owner);
    final isOwn = item.ownerId == state.currentUser.id;
    final dist = distanceKm(state.currentUser.homeLocation, item.location);
    final itemReviews = state.reviewsForItem(item.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        actions: [
          IconButton(
            tooltip: 'Share item',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _PhotoGallery(item: item),
          const SizedBox(height: 16),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${distanceLabel(dist)} · ${owner.neighborhood}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          _Section(title: 'Condition', body: item.condition),
          _Section(
            title: 'Borrow terms',
            body:
                'Up to ${item.borrowTerms.maxDurationDays} days · ${item.borrowTerms.dailyFee == null ? 'Free to borrow' : '\$${item.borrowTerms.dailyFee} per day'} · ${item.borrowTerms.depositAmount == null ? 'No deposit' : '\$${item.borrowTerms.depositAmount} refundable deposit'}',
          ),
          _Section(
            title: 'Pickup',
            body:
                '${_pickupLabel(item.borrowTerms.pickupPreference)} — ${item.borrowTerms.pickupInstructions}',
          ),
          const SizedBox(height: 8),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userId: owner.id),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(user: owner, radius: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                owner.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                owner.bio,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (state.showTrustScores) TrustBadge(result: trust),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                    if (state.showTrustScores) ...[
                      const SizedBox(height: 12),
                      _BreakdownRow(
                        label: 'On-time returns',
                        points: trust.breakdown.onTimeReturns,
                        max: 40,
                      ),
                      _BreakdownRow(
                        label: 'Reviews',
                        points: trust.breakdown.reviews,
                        max: 25,
                      ),
                      _BreakdownRow(
                        label: 'Verified profile',
                        points: trust.breakdown.verification,
                        max: 10,
                      ),
                      _BreakdownRow(
                        label: 'Account age',
                        points: trust.breakdown.accountAge,
                        max: 10,
                      ),
                      _BreakdownRow(
                        label: 'Responsiveness',
                        points: trust.breakdown.responsiveness,
                        max: 15,
                      ),
                    ],
                    Text(
                      'Typically replies in ~${owner.avgResponseMinutes} min · tap to view profile',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (isOwn)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'This is your listing — neighbors can request it from Explore.',
                ),
              ),
            )
          else if (!item.isAvailable)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  item.availability == 'borrowed'
                      ? 'This item is currently borrowed and cannot be requested right now.'
                      : 'This item is currently unavailable.',
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRequestSheet(context, item.id),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Request to borrow'),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Reviews for this item (${itemReviews.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ReviewsList(reviews: itemReviews),
        ],
      ),
    );
  }

  String _pickupLabel(String p) {
    switch (p) {
      case 'pickup':
        return 'Pickup only';
      case 'drop-off':
        return 'Drop-off';
      default:
        return 'Pickup or drop-off';
    }
  }

  void _showRequestSheet(BuildContext context, String itemId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BorrowSheet(itemId: itemId),
    );
  }
}

/// Photo strip for the item: PageView of network photos with a category
/// tile fallback (also the whole UI for the one photo-less seed item).
class _PhotoGallery extends StatefulWidget {
  final Item item;
  const _PhotoGallery({required this.item});
  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.item.photos;
    if (photos.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.creamDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                categoryIcon(widget.item.category),
                size: 56,
                color: AppColors.terracotta,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.item.category} · no photos yet',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.barkLight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PhotoGalleryScreen(item: widget.item, initialIndex: i),
                  ),
                ),
                child: Image.network(
                  photos[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(
                          color: AppColors.creamDark,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.creamDark,
                    child: Center(
                      child: Icon(
                        categoryIcon(widget.item.category),
                        size: 56,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final active = i == _index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? AppColors.terracotta : AppColors.sand,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final int points;
  final int max;
  const _BreakdownRow({
    required this.label,
    required this.points,
    required this.max,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : points / max,
                minHeight: 8,
                backgroundColor: AppColors.sand,
                color: AppColors.moss,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$points/$max',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _BorrowSheet extends StatefulWidget {
  final String itemId;
  const _BorrowSheet({required this.itemId});
  @override
  State<_BorrowSheet> createState() => _BorrowSheetState();
}

class _BorrowSheetState extends State<_BorrowSheet> {
  DateTime? _start;
  DateTime? _end;
  final _noteCtrl = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? (_start ?? now) : (_end ?? _start ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = picked;
      } else {
        _end = picked;
      }
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final item = state.itemById(widget.itemId);
    final pendingOverlaps = (_start != null && _end != null)
        ? state.pendingRequestsOverlapping(widget.itemId, _start!, _end!)
        : const [];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request to borrow',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(item.title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(true),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _start == null ? 'Start date' : shortDate(_start!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(false),
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(_end == null ? 'End date' : shortDate(_end!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Max ${item.borrowTerms.maxDurationDays} days for this item.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (pendingOverlaps.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 18,
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Heads up: ${pendingOverlaps.length == 1 ? 'another neighbor has' : '${pendingOverlaps.length} neighbors have'} a pending request for overlapping dates. The owner can only approve one — you can still send yours.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Note to the owner — what is it for, when can you pick up?',
              labelText: 'Note (optional)',
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_start == null || _end == null) {
                  setState(
                    () => _error = 'Please pick both a start and an end date.',
                  );
                  return;
                }
                final err = state.createBorrowRequest(
                  item,
                  _start!,
                  _end!,
                  _noteCtrl.text,
                );
                if (err != null) {
                  setState(() => _error = err);
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Request sent — check the Activity tab for updates.',
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Send request'),
            ),
          ),
        ],
      ),
    );
  }
}
