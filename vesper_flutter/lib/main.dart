import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesper_flutter/shared/navigation/app_router.dart';
import 'package:vesper_flutter/shared/theme/vesper_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: VesperApp(),
    ),
  );
}

class VesperApp extends ConsumerWidget {
  const VesperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Vesper',
      debugShowCheckedModeBanner: false,
      theme: VesperTheme.light(),
      darkTheme: VesperTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
