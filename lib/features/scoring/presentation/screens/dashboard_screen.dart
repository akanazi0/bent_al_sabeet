import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/providers/game_provider.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/screens/score_entry_screen.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/widgets/undo_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الجلسة الحالية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: game.session?.players.length ?? 0,
              itemBuilder: (context, i) {
                var p = game.session!.players[i];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${p.totalScore}', style: const TextStyle(fontSize: 20)),
                      if (p.isKing) const Text('👑 كنج', style: TextStyle(color: Colors.amber)),
                      if (p.isDealer) const Text('🃏 الموزع', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: game.session?.rounds.length ?? 0,
              itemBuilder: (context, i) => ListTile(
                title: Text('الجولة ${i + 1}'),
                subtitle: Text(game.session!.rounds[i].join(' | ')),
                onTap: () => _showRoundSummary(context, i),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToScoring(context),
                    child: const Text('تسجيل'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showUndoDialog(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                  child: const Text('تراجع', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإعدادات'),
        content: const Text('تغيير الحد الأقصى للنقاط (قريباً)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          )
        ],
      ),
    );
  }

  void _showRoundSummary(BuildContext context, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ملخص الجولة ${index + 1}')),
    );
  }

  void _navigateToScoring(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScoreEntryScreen()),
    );
  }

  void _showUndoDialog(BuildContext context) {
    showUndoDialog(context);
  }
}