import 'package:flutter/material.dart';
import 'package:lumiers/auth/signin.dart';
import 'package:lumiers/utils/user_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (_) => UserProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les enfants de la lumiere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6670),
          primary: const Color(0xFF4A6670),
          secondary: const Color(0xFFE6D5CA),
          tertiary: const Color(0xFFDAA520),
        ),
        scaffoldBackgroundColor: const Color(0xFFE6D5CA),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SignInPage(),
    );
  }
}
