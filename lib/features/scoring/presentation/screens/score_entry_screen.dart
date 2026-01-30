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
  Set<int> selectedHearts = {}; // Track selected heart cards
  bool isHeartsDoubled = false; // Track if hearts are doubled
  int minus = 0;
  
  // For drag selection
  final Map<int, GlobalKey> _boxKeys = {};
  
  @override
  void initState() {
    super.initState();
    // Initialize keys for all boxes
    for (int i = 0; i < 13; i++) {
      _boxKeys[i] = GlobalKey();
    }
  }


  // Computed property for hash total (1 point per card, doubled if button pressed)
  int get hash => selectedHearts.length * (isHeartsDoubled ? 2 : 1);

  // When minus is selected, other cards should be disabled
  bool get areCardsDisabled => minus < 0;

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
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildIncrementOption(
                        '♠', 
                        'بنت السبيت', 
                        sibeeta, 
                        13, 
                        0, 
                        26, 
                        (val) {
                          setState(() {
                            sibeeta = val;
                            // When adding cards, reset minus
                            if (val > 0 && minus < 0) {
                              minus = 0;
                            }
                          });
                        },
                        isDisabled: areCardsDisabled,
                      ),
                      const SizedBox(height: 12),
                      _buildIncrementOption(
                        '♦', 
                        'عشرة الديمن', 
                        deman, 
                        10, 
                        0, 
                        20, 
                        (val) {
                          setState(() {
                            deman = val;
                            // When adding cards, reset minus
                            if (val > 0 && minus < 0) {
                              minus = 0;
                            }
                          });
                        },
                        isDisabled: areCardsDisabled,
                      ),
                      const SizedBox(height: 12),
                      _buildHeartsGrid(),
                      const SizedBox(height: 12),
                      _buildIncrementOption(
                        '-', 
                        'قري', 
                        minus, 
                        10, 
                        -20, 
                        0, 
                        (val) {
                          setState(() {
                            minus = val;
                            // When selecting minus, clear all cards
                            if (val < 0) {
                              sibeeta = 0;
                              deman = 0;
                              selectedHearts.clear();
                              isHeartsDoubled = false;
                            }
                          });
                        },
                        isDisabled: sibeeta > 0 || deman > 0 || hash > 0, // Disable minus when cards selected
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
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
                  child: Text(
                    'تـم',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeartsGrid() {
    return Opacity(
      opacity: areCardsDisabled ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  '♥',
                  style: GoogleFonts.rubik(
                    color: areCardsDisabled
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'قطع الهاص',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Total display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$hash',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid of 13 boxes with iPhone-style drag selection
            GestureDetector(
              onPanStart: (details) => _handleDrag(details.globalPosition),
              onPanUpdate: (details) => _handleDrag(details.globalPosition),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(13, (index) {
                  final isSelected = selectedHearts.contains(index);
                  return GestureDetector(
                    key: _boxKeys[index],
                    onTap: areCardsDisabled ? null : () {
                      setState(() {
                        // Sequential selection: selecting N selects all from 0 to N
                        if (isSelected) {
                          // Deselect this and all higher numbers
                          selectedHearts.removeWhere((i) => i >= index);
                        } else {
                          // Select this and all lower numbers
                          for (int i = 0; i <= index; i++) {
                            selectedHearts.add(i);
                          }
                        }
                        // When adding hearts, reset minus
                        if (selectedHearts.isNotEmpty && minus < 0) {
                          minus = 0;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected 
                                ? Colors.white 
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons row (Double + Select All)
            Row(
              children: [
                // Double button
                Expanded(
                  child: GestureDetector(
                    onTap: areCardsDisabled ? null : () {
                      setState(() {
                        isHeartsDoubled = !isHeartsDoubled;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isHeartsDoubled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'دبل',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isHeartsDoubled
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Select All / Deselect All button
                Expanded(
                  child: GestureDetector(
                    onTap: areCardsDisabled ? null : () {
                      setState(() {
                        if (selectedHearts.length == 13) {
                          // Deselect all
                          selectedHearts.clear();
                        } else {
                          // Select all
                          selectedHearts = Set.from(List.generate(13, (i) => i));
                        }
                        // When adding hearts, reset minus
                        if (selectedHearts.isNotEmpty && minus < 0) {
                          minus = 0;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          selectedHearts.length == 13 ? 'إلغاء الكل' : 'تحديد الكل',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDrag(Offset globalPosition) {
    if (areCardsDisabled) return;
    
    // Check which box the drag position is over
    for (int i = 0; i < 13; i++) {
      final key = _boxKeys[i];
      final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;
      
      if (renderBox != null) {
        final boxPosition = renderBox.localToGlobal(Offset.zero);
        final boxSize = renderBox.size;
        
        // Check if global position is within this box bounds
        if (globalPosition.dx >= boxPosition.dx &&
            globalPosition.dx <= boxPosition.dx + boxSize.width &&
            globalPosition.dy >= boxPosition.dy &&
            globalPosition.dy <= boxPosition.dy + boxSize.height) {
        // Found the box being dragged over
        setState(() {
          // 1. Select everything up to this box (inclusive)
          for (int j = 0; j <= i; j++) {
            selectedHearts.add(j);
          }
          // 2. Deselect everything AFTER this box
          selectedHearts.removeWhere((index) => index > i);
          
          // When adding hearts, reset minus
          if (selectedHearts.isNotEmpty && minus < 0) {
            minus = 0;
          }
        });
          return; // Exit once we found the box
        }
      }
    }
  }

  Widget _buildIncrementOption(
    String icon, 
    String title, 
    int currentVal, 
    int step, 
    int minVal, 
    int maxVal, 
    Function(int) onUpdate,
    {bool isDisabled = false}
  ) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
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
                    style: GoogleFonts.rubik(
                      color: isDisabled 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  isEnabled: !isDisabled && currentVal > minVal,
                  onPressed: () => onUpdate(currentVal - step),
                ),
                // Current value display
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$currentVal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Plus button
                _buildControlButton(
                  icon: Icons.add,
                  isEnabled: !isDisabled && currentVal < maxVal,
                  onPressed: () => onUpdate(currentVal + step),
                ),
              ],
            ),
          ],
        ),
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