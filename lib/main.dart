import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_router.dart'; // your router file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBEEURdAHVV808J9IBKZxVlV5cbbAjQKV0",
      authDomain: "dynamixzone-c44d1.firebaseapp.com",
      projectId: "dynamixzone-c44d1",
      storageBucket: "dynamixzone-c44d1.firebasestorage.app",
      messagingSenderId: "522048940316",
      appId: "1:522048940316:web:594bda42fa824b002472d9",
      measurementId: "G-CYBJNRNBC1",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'Admin Panel',
      theme: ThemeData.dark(useMaterial3: true)
    );
  }
}
