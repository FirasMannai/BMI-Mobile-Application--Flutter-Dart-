// Importing necessary packages for the app
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash_page.dart';
import 'biometric_login_page.dart';
import 'input_page.dart';
import 'notification_service.dart';
import 'theme_provider.dart';
import 'bmi_provider.dart';

// Main function to start the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationService().init();
  // Initialize theme
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  // Initialize BMI history
  final bmiProvider = BMIProvider();
  await bmiProvider.loadHistory();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => bmiProvider),
      ],
      child: const BMICalculator(),
    ),
  );
}

// Main app widget
class BMICalculator extends StatelessWidget {
  const BMICalculator({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'BMI Calculator',
      // Define light and dark themes
      theme: themeProvider.isDarkTheme
          ? ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF0A0E21),
              scaffoldBackgroundColor: const Color(0xFF0A0E21),
              cardColor: const Color(0xFF1D1E33),
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFFEB1555),
                secondary: const Color(0xFF4C4F5E),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.grey[200]!,
                surface: const Color(0xFF1D1E33),
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            )
          : ThemeData.light().copyWith(
              primaryColor: const Color(0xFF6200EE),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              cardColor: const Color(0xFFFFFFFF),
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF03DAC6),
                secondary: const Color(0xFF018786),
                onPrimary: Colors.black,
                onSecondary: Colors.black,
                onSurface: Colors.grey[900]!,
                surface: const Color(0xFFFFFFFF),
              ),
              textTheme: ThemeData.light().textTheme.apply(
                    bodyColor: Colors.black,
                    displayColor: Colors.black,
                  ),
            ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/biometric': (context) => const BiometricLoginPage(),
        '/input': (context) => const InputPage(),
      },
    );
  }
}
