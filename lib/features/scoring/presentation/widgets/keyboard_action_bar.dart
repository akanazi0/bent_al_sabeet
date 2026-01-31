import 'package:flutter/material.dart';

/// A widget that provides a toolbar above the keyboard with "Next" and "Done" buttons.
/// Especially useful for numeric keyboards on iOS which lack these actions.
class KeyboardActionBar extends StatelessWidget {
  final VoidCallback? onDone;
  final bool showDone;

  const KeyboardActionBar({
    super.key,
    this.onDone,
    this.showDone = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight == 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showDone && onDone != null)
              TextButton(
                onPressed: onDone,
                child: Text(
                  'تم',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
