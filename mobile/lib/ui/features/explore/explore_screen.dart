import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../data/models/item.dart';
import '../../../state/app_state.dart';
import '../item_detail/item_detail_screen.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/user_profile_screen.dart';
import 'item_map_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;
  double? _maxDistance;
  bool _onlyAvailable = false;
  bool _showMap = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.filteredItems(
      query: _query,
      category: _category,
      maxDistanceKm: _maxDistance,
      onlyAvailable: _onlyAvailable,
    );
    final me = state.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Borrow Don't Buy",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Text(
              '${me.neighborhood} · ${me.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: Badge(
              isLabelVisible:
                  state.notificationsEnabled &&
                  state.notificationBadgeCount > 0,
              label: Text('${state.notificationBadgeCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MessagesScreen())),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: me.id),
              ),
            ),
            child: UserAvatar(user: me, radius: 18),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search drills, tents, mixers…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                ),
                ...kItemCategories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) =>
                          setState(() => _category = _category == c ? null : c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text(
                  'Distance:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 8),
                ...<double?>[null, 1, 3, 5].map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(d == null ? 'Any' : '${d.toInt()} km'),
                      selected: _maxDistance == d,
                      onSelected: (_) => setState(() => _maxDistance = d),
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Available only', style: TextStyle(fontSize: 13)),
                Switch(
                  value: _onlyAvailable,
                  activeThumbColor: AppColors.moss,
                  onChanged: (v) => setState(() => _onlyAvailable = v),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                Text(
                  items.length == 1
                      ? '1 item nearby'
                      : '${items.length} items nearby',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.list, size: 16),
                      label: Text('List'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.map_outlined, size: 16),
                      label: Text('Map'),
                    ),
                  ],
                  selected: {_showMap},
                  onSelectionChanged: (s) => setState(() => _showMap = s.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showMap
                ? ItemMapView(items: items, maxDistanceKm: _maxDistance)
                : items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: AppColors.barkLight.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nothing matches — try widening your distance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Or clear your search and category filters.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final owner = state.userById(item.ownerId);
                      final dist = distanceKm(me.homeLocation, item.location);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailScreen(itemId: item.id),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CategoryTile(
                                    category: item.category,
                                    size: 64,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.category} · ${distanceLabel(dist)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _MiniChip(
                                              text:
                                                  item.borrowTerms.dailyFee ==
                                                      null
                                                  ? 'Free'
                                                  : '\$${item.borrowTerms.dailyFee}/day',
                                            ),
                                            _MiniChip(
                                              text:
                                                  item
                                                          .borrowTerms
                                                          .depositAmount ==
                                                      null
                                                  ? 'No deposit'
                                                  : '\$${item.borrowTerms.depositAmount} deposit',
                                            ),
                                            _MiniChip(
                                              text: item.isAvailable
                                                  ? 'Available'
                                                  : item.availability ==
                                                        'borrowed'
                                                  ? 'Borrowed'
                                                  : 'Unavailable',
                                              highlight: item.isAvailable,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            UserAvatar(user: owner, radius: 12),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                owner.name,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            TrustBadge(
                                              result: state.trustFor(owner),
                                              compact: true,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final bool highlight;
  const _MiniChip({required this.text, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.moss.withValues(alpha: 0.12)
            : AppColors.creamDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: highlight ? AppColors.mossDark : AppColors.bark,
        ),
      ),
    );
  }
}
