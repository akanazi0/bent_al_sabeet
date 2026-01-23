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
      appBar: AppBar(title: const Text('تسجيل اللعبة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('عدد اللاعبين'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4, 5].map((count) => ChoiceChip(
                label: Text('$count'),
                selected: playerCount == count,
                onSelected: (val) => setState(() => playerCount = count),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: playerCount,
                itemBuilder: (context, i) => TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(labelText: 'اسم اللاعب ${i + 1}'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final names = controllers.take(playerCount).map((c) => c.text.isEmpty ? 'لاعب ${controllers.indexOf(c) + 1}' : c.text).toList();
                context.read<GameProvider>().startNewGame(names, 151);
                Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
              },
              child: const Text('بدء الجلسة'),
            ),
          ],
        ),
      ),
    );
  }
}