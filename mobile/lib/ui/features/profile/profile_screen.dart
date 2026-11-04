import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../state/app_state.dart';
import '../item_detail/item_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.currentUser;
    final trust = state.trustFor(me);
    final myItems = state.myItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            children: [
              UserAvatar(user: me, radius: 34),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${me.neighborhood} · Member since ${me.joinedAt.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          me.phoneVerified ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: me.phoneVerified
                              ? AppColors.moss
                              : AppColors.barkLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Phone ${me.phoneVerified ? 'verified' : 'unverified'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          me.emailVerified ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: me.emailVerified
                              ? AppColors.moss
                              : AppColors.barkLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Email ${me.emailVerified ? 'verified' : 'unverified'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(me.bio),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${trust.total}',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trust score',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TrustBadge(result: trust),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Bar(
                    label: 'On-time returns',
                    points: trust.breakdown.onTimeReturns,
                    max: 40,
                  ),
                  _Bar(
                    label: 'Reviews',
                    points: trust.breakdown.reviews,
                    max: 25,
                  ),
                  _Bar(
                    label: 'Verified profile',
                    points: trust.breakdown.verification,
                    max: 10,
                  ),
                  _Bar(
                    label: 'Account age',
                    points: trust.breakdown.accountAge,
                    max: 10,
                  ),
                  _Bar(
                    label: 'Responsiveness',
                    points: trust.breakdown.responsiveness,
                    max: 15,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Lends',
                  value: '${me.stats.successfulLends}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Borrows',
                  value: '${me.stats.successfulBorrows}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'On-time',
                  value:
                      '${me.stats.onTimeReturns}/${me.stats.onTimeReturns + me.stats.lateReturns}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Badges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (me.badges.isEmpty)
            const Text('No badges yet — your first on-time return earns one.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: me.badges
                  .map(
                    (b) => Chip(
                      avatar: const Icon(Icons.emoji_events, size: 16),
                      label: Text(b.label),
                      backgroundColor: AppColors.creamDark,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          Text(
            'My items (${myItems.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...myItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CategoryTile(category: item.category, size: 44),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${item.category} · ${distanceLabel(0)} · ${item.availability}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemDetailScreen(itemId: item.id),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int points;
  final int max;
  const _Bar({required this.label, required this.points, required this.max});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                value: points / max,
                minHeight: 9,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
