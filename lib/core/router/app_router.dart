import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/game_page.dart';
import '../../presentation/pages/level_select_page.dart';
import '../../presentation/pages/menu_page.dart';
import '../../presentation/pages/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (_, __) => const NoTransitionPage(child: SplashPage()),
    ),
    GoRoute(
      path: '/menu',
      pageBuilder: (_, __) => _slide(const MenuPage()),
    ),
    GoRoute(
      path: '/levels',
      pageBuilder: (_, __) => _slide(const LevelSelectPage()),
    ),
    GoRoute(
      path: '/game/:level',
      pageBuilder: (_, state) {
        final level = int.parse(state.pathParameters['level']!);
        return _slide(GamePage(level: level));
      },
    ),
  ],
);

CustomTransitionPage<void> _slide(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (_, animation, __, widget) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: widget),
      ),
    );
