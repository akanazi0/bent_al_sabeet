import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حاسبة بنت السبيت',
      themeMode: ThemeMode.dark,
      theme: _buildDarkTheme(),
      home: const MainMenuScreen(),
      // Standardize scroll behavior across all platforms
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const ClampingScrollPhysics(),
        scrollbars: true,
      ),
      // Fix scaling issues: Overriding textScaler to ensure consistency across iOS system settings
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    // Define all text styles explicitly with Rubik font to prevent platform fallbacks
    // Use GoogleFonts.rubikTextTheme as a base to ensure platform-agnostic font loading
    // then override specific styles for maximum control.
    final baseTextTheme = GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme);
    
    final textTheme = baseTextTheme.copyWith(
      // Display styles (large titles)
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.2,
      ),
      // Headline styles
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.3,
      ),
      // Title styles
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.3,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
        height: 1.3,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.3,
      ),
      // Body styles (most common)
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.5,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFA9B7C6),
        letterSpacing: 0,
        height: 1.5,
      ),
      // Label styles (buttons, chips)
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      // Trick Material widgets into using the same platform style everywhere
      platform: TargetPlatform.android,
      // Standardize density across Web, Desktop, and Mobile
      visualDensity: VisualDensity.standard,
      fontFamily: GoogleFonts.rubik().fontFamily, // Global font family from GoogleFonts
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF131416),
      
      // Ensure Cupertino widgets also use the same design language
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF3574F0),
        textTheme: CupertinoTextThemeData(
          primaryColor: Colors.white,
          textStyle: GoogleFonts.rubik(color: const Color(0xFFA9B7C6)),
          actionTextStyle: GoogleFonts.rubik(color: const Color(0xFF3574F0)),
          navActionTextStyle: GoogleFonts.rubik(color: const Color(0xFF3574F0)),
          navTitleTextStyle: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3574F0),
        secondary: Color(0xFF3574F0),
        surface: Color(0xFF2B2B2B),
        onSurface: Colors.white,
        onPrimary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      
      // Text theme - all styles explicitly defined
      textTheme: textTheme,
      
      // Primary text theme (for contrast)
      primaryTextTheme: textTheme,
      
      // Disable splash effects
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      
      // Divider color
      dividerColor: const Color(0xFF3E3E3E),
      
      // Platform-agnostic page transitions (Custom Premium Animation)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
          TargetPlatform.linux: CustomPageTransitionBuilder(),
          TargetPlatform.macOS: CustomPageTransitionBuilder(),
          TargetPlatform.windows: CustomPageTransitionBuilder(),
        },
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF131416),
        foregroundColor: const Color(0xFFA9B7C6),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFA9B7C6),
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFA9B7C6),
          size: 24,
        ),
      ),
      
      // ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3574F0),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3574F0),
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      
      // OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFA9B7C6),
          side: const BorderSide(color: Color(0xFF3E3E3E)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2B2B2B),
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0,
        ),
        contentTextStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA9B7C6),
          letterSpacing: 0,
          height: 1.5,
        ),
      ),
      
      // InputDecoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2B2B2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3574F0)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        labelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA9B7C6),
          letterSpacing: 0,
        ),
        hintStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
          letterSpacing: 0,
        ),
        helperStyle: GoogleFonts.rubik(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA9B7C6),
          letterSpacing: 0,
        ),
        errorStyle: GoogleFonts.rubik(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.redAccent,
          letterSpacing: 0,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2B2B2B),
        selectedColor: const Color(0xFF3574F0),
        disabledColor: const Color(0xFF2B2B2B).withOpacity(0.5),
        labelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        secondaryLabelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: Color(0xFFA9B7C6),
        size: 24,
      ),
      
      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// A custom page transition builder that provides a horizontal slide effect (Right to Left).
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Balanced easing - not too fast, not too slow
    const curve = Curves.easeInOut;
    
    // Slide from Right (1.0) to Center (0.0) -> "Start goes Right" (appears from right)
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: child, 
    );
  }
}