import 'package:flutter/material.dart';

/// A widget that provides a toolbar above the keyboard with "Next" and "Done" buttons.
/// Especially useful for numeric keyboards on iOS which lack these actions.
class KeyboardActionBar extends StatelessWidget {
  final VoidCallback? onDone;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool showDone;

  const KeyboardActionBar({
    super.key,
    this.onDone,
    this.onPrevious,
    this.onNext,
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
          children: [
            // Left-aligned navigation arrows
            if (onPrevious != null || onNext != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onPrevious,
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      color: onPrevious != null 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).dividerColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: onNext,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: onNext != null 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).dividerColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            
            const Spacer(),
            
            // Right-aligned Done button
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

