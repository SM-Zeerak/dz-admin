import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(const MyAdminApp());
}

class MyAdminApp extends StatelessWidget {
  const MyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Admin Panel',
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: AppRouter.router,
    );
  }
}
