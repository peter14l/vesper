import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesper_flutter/features/vault/vault_screen.dart';
import 'package:vesper_flutter/features/recording/recording_screen.dart';
import 'package:vesper_flutter/features/settings/settings_screen.dart';
import 'package:vesper_flutter/shared/navigation/scaffold_with_navigation.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorVaultKey = GlobalKey<NavigatorState>(debugLabel: 'vault');
final _shellNavigatorRecordKey = GlobalKey<NavigatorState>(debugLabel: 'record');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouter = GoRouter(
  initialLocation: '/vault',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorVaultKey,
          routes: [
            GoRoute(
              path: '/vault',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VaultScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorRecordKey,
          routes: [
            GoRoute(
              path: '/record',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RecordingScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
