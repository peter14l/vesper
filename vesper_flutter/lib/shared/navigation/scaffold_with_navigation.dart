import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return _DesktopScaffold(navigationShell: navigationShell);
        } else {
          return _MobileScaffold(navigationShell: navigationShell);
        }
      },
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: NavigationBar(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.8),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: [
              NavigationDestination(
                icon: Icon(PhosphorIcons.folder()),
                selectedIcon: Icon(PhosphorIcons.folder(PhosphorIconsStyle.fill)),
                label: 'Vault',
              ),
              NavigationDestination(
                icon: Icon(PhosphorIcons.microphone()),
                selectedIcon: Icon(PhosphorIcons.microphone(PhosphorIconsStyle.fill)),
                label: 'Record',
              ),
              NavigationDestination(
                icon: Icon(PhosphorIcons.gear()),
                selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 200,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            labelType: NavigationRailLabelType.none,
            destinations: [
              NavigationRailDestination(
                icon: Icon(PhosphorIcons.folder()),
                selectedIcon: Icon(PhosphorIcons.folder(PhosphorIconsStyle.fill)),
                label: const Text('Vault'),
              ),
              NavigationRailDestination(
                icon: Icon(PhosphorIcons.microphone()),
                selectedIcon: Icon(PhosphorIcons.microphone(PhosphorIconsStyle.fill)),
                label: const Text('Record'),
              ),
              NavigationRailDestination(
                icon: Icon(PhosphorIcons.gear()),
                selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
                label: const Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}
