import 'package:go_router/go_router.dart';

import 'barcode_screen.dart';
import 'camera_scanner_screen.dart';
import 'example_screen.dart';
import 'home_screen.dart';
import 'main_layout.dart';
import 'profile_screen.dart';
import 'push_example.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // --- Profile Route ---
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      builder: (context, state) => const ProfileScreen(),
    ),
    // --- Push Example Route ---
    GoRoute(
      path: '/push-example',
      name: PushExampleScreen.name,
      builder: (context, state) => const PushExampleScreen(),
    ),

    // --- Main App Layout ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: HomeScreen.name,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/example',
              name: ExampleScreen.name,
              builder: (context, state) => const ExampleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/barcode',
              name: BarcodeScreen.name,
              builder: (context, state) => const BarcodeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/camera-scanner',
              name: CameraScannerScreen.name,
              builder: (context, state) => const CameraScannerScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
