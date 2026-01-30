import 'package:flutter/material.dart';
import 'home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: [
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
                    boxShadow: [
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
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo02.png',
                    width: 260,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'حساب بنت السبيت',
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