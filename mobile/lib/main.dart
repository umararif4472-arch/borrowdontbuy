import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'ui/app_shell.dart';

void main() {
  runApp(const BorrowDontBuyApp());
}

class BorrowDontBuyApp extends StatelessWidget {
  const BorrowDontBuyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: "Borrow Don't Buy",
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppShell(),
      ),
    );
  }
}
