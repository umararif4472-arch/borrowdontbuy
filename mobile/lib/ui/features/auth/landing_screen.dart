import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Welcome screen shown instead of the app shell when signed out.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.handshake_outlined,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Why buy it when your neighbor already owns one?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text(
              'Borrow tools, gear, and party equipment from people on your block — free or for a small fee.',
              style: TextStyle(fontSize: 15, color: AppColors.barkLight),
            ),
            const SizedBox(height: 28),
            const _HowItWorks(
              icon: Icons.search,
              title: '1. Find it nearby',
              body: 'Search the neighborhood catalog and check the distance and the owner\u2019s trust score.',
            ),
            const _HowItWorks(
              icon: Icons.calendar_month_outlined,
              title: '2. Request your dates',
              body: 'Pick a start and end date. The owner approves, you pick it up, the clock starts.',
            ),
            const _HowItWorks(
              icon: Icons.verified_outlined,
              title: '3. Return it, build trust',
              body: 'On-time returns and kind reviews raise your trust score — and everyone can see it.',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Log in'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _HowItWorks({
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.mossDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
