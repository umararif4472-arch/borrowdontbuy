import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/app_state.dart';
import 'user_profile_screen.dart';

/// The Profile tab — the general user profile rendered for the
/// signed-in user (which adds the account-management entries).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AppState>().currentUser.id;
    return UserProfileScreen(key: ValueKey(userId), userId: userId);
  }
}
