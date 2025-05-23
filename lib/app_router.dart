// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'layout/admin_scaffold.dart';
// import 'screens/dashboard_screen.dart';
// import 'screens/settings_screen.dart';

// class AppRouter {
//   static final router = GoRouter(
//     initialLocation: '/dashboard',
//     routes: [
//       ShellRoute(
//         builder: (context, state, child) {
//           return AdminScaffold(child: child);
//         },
//         routes: [
//           GoRoute(
//             path: '/dashboard',
//             builder: (context, state) => const DashboardScreen(),
//           ),
//           GoRoute(
//             path: '/settings',
//             builder: (context, state) => const SettingsScreen(),
//           ),
//         ],
//       ),
//     ],
//   );
// }

import 'package:dz_admin_panel/screens/auth_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'layout/admin_scaffold.dart';
import 'screens/dashboard_screen/dashboard_screen.dart';
import 'screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login', // Start on login page
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AdminScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
