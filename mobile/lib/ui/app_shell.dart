import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'features/explore/explore_screen.dart';
import 'features/wishlist/wishlist_screen.dart';
import 'features/activity/activity_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/list_item/list_item_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _screens = const [
    ExploreScreen(),
    WishlistScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<AppState>().pendingIncomingCount;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ListItemScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('List item'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.swap_horiz_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.swap_horiz),
            ),
            label: 'Activity',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
