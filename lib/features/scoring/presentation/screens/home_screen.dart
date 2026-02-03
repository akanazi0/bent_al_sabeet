import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/number_utils.dart';
import '../widgets/keyboard_action_bar.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int playerCount = 4;
  int pointsLimit = 152; // Default points limit
  final List<TextEditingController> controllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    pointsLimitFocusNode.dispose();
    super.dispose();
  }

  final FocusNode pointsLimitFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Add listeners to controllers to refresh UI on text entry
    for (var controller in controllers) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: '',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'إعداد الجلسة',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aligned Row for Player Count and Points Limit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player count selection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'عدد اللاعبين',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              children: [4, 5].map((count) => ChoiceChip(
                                showCheckmark: false, // Removed checkmark
                                label: Padding(
                                  padding: const EdgeInsets.only(top: 4.0), // Nudge down for better centering
                                  child: Text('$count', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                selected: playerCount == count,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      playerCount = count;
                                    });
                                  }
                                },
                                selectedColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: playerCount == count 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: playerCount == count
                                      ? Colors.white
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Points limit input
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نقاط اللعبة',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80, 
                              height: 48, // Fixed height to match chips approximately
                              child: TextField(
                                focusNode: pointsLimitFocusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center, // Force vertical centering
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                enableSuggestions: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                                ],
                                onSubmitted: (_) {
                                  // Just close keyboard for numeric limit
                                  pointsLimitFocusNode.unfocus();
                                },
                                decoration: InputDecoration(
                                  hintText: '152',
                                  contentPadding: const EdgeInsets.fromLTRB(8, 6, 8, 0), // Push text down
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8), // Matching radius
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 20, // Matching font size
                                  fontWeight: FontWeight.w600,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      pointsLimit = 152; 
                                    } else {
                                      final limit = NumberUtils.tryParseInt(value);
                                      if (limit != null && limit > 0) {
                                        pointsLimit = limit;
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'أسماء اللاعبين',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      // Add padding to handle keyboard and bottom button
                      padding: EdgeInsets.only(bottom: (keyboardHeight > 0) ? keyboardHeight + 60 : 80),
                      itemCount: playerCount,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: controllers[i],
                          focusNode: focusNodes[i],
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          onSubmitted: (_) {
                            focusNodes[i].unfocus();
                          },
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'اسم اللاعب ${i + 1}',
                            hintText: 'اللاعب ${i + 1}',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                            ),
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle?.copyWith(
                              fontSize: 18,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Fixed bottom button
            Positioned(
              left: 24,
              right: 24,
              bottom: 12,
              child: SizedBox(
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
                    final names = controllers
                        .take(playerCount)
                        .map((c) => c.text.trim())
                        .toList();
                    
                    // Auto-fill empty names
                    for (int i = 0; i < names.length; i++) {
                      if (names[i].isEmpty) {
                        names[i] = 'اللاعب ${i + 1}';
                      }
                    }

                    context.read<GameProvider>().startNewGame(names, pointsLimit);
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: Text(
                    'بدء الجلسة',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),

            // Keyboard action bar floating above keyboard
            if (keyboardHeight > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: keyboardHeight,
                child: KeyboardActionBar(
                  onPrevious: () {
                    // Collect all FocusNodes in order
                    final allNodes = [pointsLimitFocusNode, ...focusNodes.take(playerCount)];
                    // Find current focused node index
                    int currentIndex = allNodes.indexWhere((node) => node.hasFocus);
                    if (currentIndex > 0) {
                      allNodes[currentIndex - 1].requestFocus();
                    }
                  },
                  onNext: () {
                    final allNodes = [pointsLimitFocusNode, ...focusNodes.take(playerCount)];
                    int currentIndex = allNodes.indexWhere((node) => node.hasFocus);
                    if (currentIndex != -1 && currentIndex < allNodes.length - 1) {
                      allNodes[currentIndex + 1].requestFocus();
                    }
                  },
                  onDone: () {
                    pointsLimitFocusNode.unfocus();
                    for (var node in focusNodes) {
                      node.unfocus();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}