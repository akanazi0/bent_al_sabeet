import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/providers/game_provider.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF131416),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  timeDilation = 0.75;

  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => GameProvider()),
        ],
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
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'حاسبة بنت السبيت',
      theme: _buildDarkTheme(),
      home: const MainMenuScreen(),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      fontFamily: 'Rubik',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFA9B7C6)),
        bodyMedium: TextStyle(color: Color(0xFFA9B7C6)),
      ),
      splashFactory: NoSplash.splashFactory,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF131416),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3574F0),
        surface: Color(0xFF2B2B2B),
        onSurface: Colors.white,
      ),
      dividerColor: const Color(0xFF3E3E3E),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF131416),
        foregroundColor: Color(0xFFA9B7C6),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3574F0),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}