import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/mcp/mcp_client.dart';
import 'features/ar_viewer/presentation/ar_viewer_screen.dart';
import 'features/ar_viewer/presentation/ar_viewer_state.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/error_screen.dart';
import 'shared/widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/ar',
        builder: (context, state) => const ARViewerScreen(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) {
          final message = state.extra as String? ?? 'An unexpected error occurred.';
          return ErrorScreen(message: message);
        },
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CinnamorolAR',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    final mcpClient = McpClient();
    final isHealthy = await mcpClient.checkHealth();
    
    if (mounted) {
      if (!isHealthy) {
        ref.read(arViewerProvider.notifier).setOfflineMode(true);
        // We continue anyway, just in offline mode with fallback values
      }
      context.go('/ar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}
