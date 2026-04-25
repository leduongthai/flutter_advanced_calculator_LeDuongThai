
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/calculator_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => CalculatorProvider(storage)),
      ],
      child: const AdvancedCalculatorApp(),
    ),
  );
}

class AdvancedCalculatorApp extends StatelessWidget {
  const AdvancedCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Advanced Calculator',
      debugShowCheckedModeBanner: false,
      theme:      ThemeProvider.lightTheme,
      darkTheme:  ThemeProvider.darkTheme,
      themeMode:  themeProvider.themeMode,
      home:       const CalculatorScreen(),
    );
  }
}
