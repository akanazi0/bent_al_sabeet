import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/providers/game_provider.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/screens/main_menu_screen.dart';

void main() {
  // Speed up animations globally (values < 1.0 speed up, > 1.0 slow down).
  // Adjusted to match snappier modern app feel.
  timeDilation = 0.75;

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => GameProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'حاسبة بنت السبيت',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1F22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3574F0),
          surface: Color(0xFF2B2B2B),
          onSurface: Colors.white,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        }),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1F22),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3574F0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}