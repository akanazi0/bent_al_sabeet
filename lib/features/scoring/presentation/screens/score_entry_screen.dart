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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: '',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تسجيل النقاط',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIncrementOption('♠', 'بنت السبيت', sibeeta, 13, 0, 26, (val) => setState(() => sibeeta = val)),
                    _buildIncrementOption('♦', 'عشرة الديمن', deman, 10, 0, 20, (val) => setState(() => deman = val)),
                    _buildIncrementOption('♥', 'الهاص', hash, 1, 0, 26, (val) => setState(() => hash = val)),
                    _buildIncrementOption('-', 'الماينس', minus, 10, -20, 0, (val) => setState(() => minus = val)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
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
                    context.read<GameProvider>().addPendingScoreComponents(
                          sibeeta: sibeeta, deman: deman, hash: hash, minus: minus);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'تـم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncrementOption(String icon, String title, int currentVal, int step, int minVal, int maxVal, Function(int) onUpdate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        children: [
          // Icon and title
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  icon,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus button
              _buildControlButton(
                icon: Icons.remove,
                isEnabled: currentVal > minVal,
                onPressed: () => onUpdate(currentVal - step),
              ),
              // Current value display
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$currentVal',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Plus button
              _buildControlButton(
                icon: Icons.add,
                isEnabled: currentVal < maxVal,
                onPressed: () => onUpdate(currentVal + step),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
            size: 20,
          ),
        ),
      ),
    );
  }
}