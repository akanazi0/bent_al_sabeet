import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

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
      backgroundColor: const Color(0xFF1E1F22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        elevation: 0,
        title: const Text('تسجيل النقاط', 
          style: TextStyle(color: Color(0xFFA9B7C6), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.5),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          _buildOption('♠', 'بنت السبيت', [0, 13, 26], (val) => setState(() => sibeeta = val), sibeeta),
                      const SizedBox(height: 24),
                      _buildOption('♦', 'عشرة الديمن', [0, 10, 20], (val) => setState(() => deman = val), deman),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF3E3E3E)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                              leading: const Text('♥', style: TextStyle(color: Color(0xFF3574F0), fontSize: 26)),
                          title: const Text('الهاص (نقاط يدوية)', style: TextStyle(color: Color(0xFFA9B7C6), fontSize: 14, fontWeight: FontWeight.bold)),
                          trailing: SizedBox(
                            width: 80,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFF626569)),
                                border: InputBorder.none,
                              ),
                              onChanged: (val) => setState(() => hash = int.tryParse(val) ?? 0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOption('-', 'الماينس', [0, -10, -20], (val) => setState(() => minus = val), minus),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3574F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () {
                  context.read<GameProvider>().addPendingScoreComponents(
                        sibeeta: sibeeta, deman: deman, hash: hash, minus: minus);
                  Navigator.pop(context);
                },
                child: const Text('تـم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String icon, String title, List<int> values, Function(int) onSelect, int currentVal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF3E3E3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Text(icon, style: const TextStyle(color: Color(0xFF3574F0), fontSize: 26)),
                const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: values.map((v) => ChoiceChip(
              label: Text('$v'),
              selected: currentVal == v,
              selectedColor: const Color(0xFF3574F0),
              backgroundColor: const Color(0xFF1E1F22),
              labelStyle: TextStyle(color: currentVal == v ? Colors.white : const Color(0xFFA9B7C6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onSelected: (selected) => onSelect(v),
            )).toList(),
          ),
        ],
      ),
    );
  }
}