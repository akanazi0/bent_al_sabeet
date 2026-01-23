import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

void showUndoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تنبيه'),
      content: const Text('في حال ضغطت على حسنا باللون الأحمر سيتم مسح آخر جلسة'),
      actions: [
        TextButton(
          child: const Text('إلغاء', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('حسنا', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Provider.of<GameProvider>(context, listen: false).undoLastRound();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}