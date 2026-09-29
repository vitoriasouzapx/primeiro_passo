import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/app_controller.dart';
import 'screens/welcome_screen.dart';
import 'widgets/ui.dart';
import 'services/firebase_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cloud = await configuredCloud();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppController(cloud: cloud)..init(),
      child: const PrimeiroPassoApp(),
    ),
  );
}

class PrimeiroPassoApp extends StatelessWidget {
  const PrimeiroPassoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Primeiro Passo',
      theme: ThemeData(
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: purple),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)))),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: blue,
          surface: Colors.white,
        ),
        textTheme: Theme.of(context)
            .textTheme
            .apply(bodyColor: ink, displayColor: ink),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: purple, width: 1.4),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
