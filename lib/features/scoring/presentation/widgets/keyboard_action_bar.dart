import 'package:flutter/material.dart';

/// A widget that provides a toolbar above the keyboard with "Next" and "Done" buttons.
/// Especially useful for numeric keyboards on iOS which lack these actions.
class KeyboardActionBar extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onDone;
  final bool showNext;
  final bool showDone;

  const KeyboardActionBar({
    super.key,
    this.onNext,
    this.onDone,
    this.showNext = true,
    this.showDone = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showNext && onNext != null)
            TextButton(
              onPressed: onNext,
              child: Text(
                'التالي',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Carlito',
                ),
              ),
            ),
          if (showNext && showDone)
            const VerticalDivider(width: 1, indent: 12, endIndent: 12),
          if (showDone && onDone != null)
            TextButton(
              onPressed: onDone,
              child: Text(
                'تم',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Carlito',
                ),
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
