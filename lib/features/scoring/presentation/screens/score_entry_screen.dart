import 'package:flutter/material.dart';
import 'package:bent_al_sabeet/features/scoring/presentation/providers/game_provider.dart';
import 'package:flutter/material.dart';

class ScoreEntryScreen extends StatefulWidget {
  const ScoreEntryScreen({super.key});

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  int sibeeta = 0;
  int deman = 0;
  int hash = 0;
  int minus = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل نقاط اللاعب')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildOption('بنت السبيت', [0, 13, 26], (val) => setState(() => sibeeta = val), sibeeta),
          const Divider(),
          _buildOption('عشرة الديمن', [0, 10, 20], (val) => setState(() => deman = val), deman),
          const Divider(),
          ListTile(
            title: const Text('الهاص'),
            trailing: SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                onChanged: (val) => setState(() => hash = int.tryParse(val) ?? 0),
              ),
            ),
          ),
          const Divider(),
          _buildOption('الماينس', [0, -10, -20], (val) => setState(() => minus = val), minus),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: () {
              int total = sibeeta + deman + hash + minus;
              Navigator.pop(context, total);
            },
            child: const Text('تم'),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String title, List<int> values, Function(int) onSelect, int currentVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: values.map((v) => ChoiceChip(
            label: Text('$v'),
            selected: currentVal == v,
            onSelected: (selected) => onSelect(v),
          )).toList(),
        ),
      ],
    );
  }
}