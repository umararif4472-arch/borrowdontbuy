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
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 32),
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
            const SizedBox(height: 24),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HowItWorksPoint(icon: Icons.search, label: 'Find it nearby'),
                _HowItWorksPoint(
                  icon: Icons.calendar_month_outlined,
                  label: 'Request your dates',
                ),
                _HowItWorksPoint(
                  icon: Icons.verified_outlined,
                  label: 'Return, build trust',
                ),
              ],
            ),
            const SizedBox(height: 28),
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

/// One compact how-it-works point: icon over a 3–4 word label.
class _HowItWorksPoint extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HowItWorksPoint({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
