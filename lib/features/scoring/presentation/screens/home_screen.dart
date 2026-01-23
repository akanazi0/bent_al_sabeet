import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int playerCount = 4;
  final List<TextEditingController> controllers = List.generate(5, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        elevation: 0,
        title: const Text(
          'إعداد الجلسة',
          style: TextStyle(color: Color(0xFFA9B7C6), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'عدد اللاعبين',
              style: TextStyle(color: Color(0xFF626569), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [4, 5].map((count) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ChoiceChip(
                  label: Text('$count'),
                  selected: playerCount == count,
                  selectedColor: const Color(0xFF3574F0),
                  backgroundColor: const Color(0xFF2B2B2B),
                  labelStyle: TextStyle(color: playerCount == count ? Colors.white : const Color(0xFFA9B7C6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onSelected: (val) => setState(() => playerCount = count),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'أسماء اللاعبين',
              style: TextStyle(color: Color(0xFF626569), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: playerCount,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextField(
                    controller: controllers[i],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'اسم اللاعب ${i + 1}',
                      labelStyle: const TextStyle(color: Color(0xFF626569)),
                      filled: true,
                      fillColor: const Color(0xFF2B2B2B),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E3E3E)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3574F0)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3574F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  final names = controllers
                      .take(playerCount)
                      .map((c) => c.text.isEmpty ? 'لاعب ${controllers.indexOf(c) + 1}' : c.text)
                      .toList();
                  context.read<GameProvider>().startNewGame(names, 151);
                  
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, anim, secAnim) => const DashboardScreen(),
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
                child: const Text('بدء الجلسة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}