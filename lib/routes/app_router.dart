import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../features/map/map_screen.dart';
import '../features/profile/pet_profile_screen.dart';
import '../features/community/community_screen.dart';
import '../features/settings/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/map',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Map
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              name: 'map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        // Tab 2: Profile & Collar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const PetProfileScreen(),
            ),
          ],
        ),
        // Tab 3: Community Feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              name: 'community',
              builder: (context, state) => const CommunityScreen(),
            ),
          ],
        ),
        // Tab 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
