import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: [
          // Theme Toggle
          Positioned(
            top: 64,
            right: 24,
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => gameProvider.toggleTheme(),
                    icon: Icon(
                      gameProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow effect
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: Theme.of(context).brightness == Brightness.dark ? [
                      // Subtle inner glow
                      BoxShadow(
                        color: const Color(0xFF3574F0).withOpacity(0.08),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                      // Medium glow
                      BoxShadow(
                        color: const Color(0xFF3574F0).withOpacity(0.12),
                        blurRadius: 140,
                        spreadRadius: 80,
                      ),
                      // Stronger outer glow
                      BoxShadow(
                        color: const Color(0xFF3574F0).withOpacity(0.18),
                        blurRadius: 200,
                        spreadRadius: 120,
                      ),
                      // Brightest ambient glow
                      BoxShadow(
                        color: const Color(0xFF3574F0).withOpacity(0.25),
                        blurRadius: 280,
                        spreadRadius: 160,
                      ),
                    ] : [],
                  ),
                  child: Transform.scale(
                    scale: Theme.of(context).brightness == Brightness.dark ? 1.0 : 1.05,
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark 
                          ? 'assets/images/logo02.png'
                          : 'assets/images/logo_light.png',
                      width: 260,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'حاسبة بنت السبيت',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 40),
                // New Game Button
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3574F0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: Text(
                      'لعبة جديدة',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}