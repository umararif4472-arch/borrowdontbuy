import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../state/app_state.dart';

class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final item = state.itemById(itemId);
    final owner = state.userById(item.ownerId);
    final trust = state.trustFor(owner);
    final isOwn = item.ownerId == state.currentUser.id;
    final dist = distanceKm(state.currentUser.homeLocation, item.location);
    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
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
                    categoryIcon(item.category),
                    size: 56,
                    color: AppColors.terracotta,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.barkLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      TrustBadge(result: trust),
                    ],
                  ),
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
                  Text(
                    'Typically replies in ~${owner.avgResponseMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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
                onPressed: () => _showRequestSheet(context, itemId),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Request to borrow'),
              ),
            ),
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
