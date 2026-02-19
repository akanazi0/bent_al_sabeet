import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/number_utils.dart';
import '../widgets/keyboard_action_bar.dart';
import 'score_entry_screen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      final players = game.players ?? [];
      
      for (int i = 0; i < players.length; i++) {
        _controllers[i] = TextEditingController();
        _focusNodes[i] = FocusNode();
        
        // Load existing pending score if any
        final pending = game.pendingScoreForPlayer(i);
        if (pending != null && pending != 0) {
          _controllers[i]!.text = pending.toString();
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateScore(int playerIndex, String value) {
    final game = context.read<GameProvider>();
    game.selectPlayer(playerIndex);
    
    if (value.trim().isEmpty) {
      game.addManualScore(0);
    } else {
      final score = NumberUtils.tryParseInt(value.trim());
      if (score != null) {
        game.addManualScore(score);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final players = game.players ?? [];
    
    int minScores = players.isNotEmpty 
        ? players.map((p) => p.scores.length).reduce((a, b) => a < b ? a : b) 
        : 0;
    int currentRoundNumber = minScores + 1;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // حذف زر الرجوع العلوي
        leading: IconButton(
          tooltip: '',
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('التسجيلة رقم $currentRoundNumber', 
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          )),
      ),
      body: Stack(
        children: [
            Column(
              children: [
                // Mode switch
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<GameProvider>().setScoringMode(ScoringMode.card);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: game.scoringMode == ScoringMode.card
                                  ? const Color(0xFF3574F0)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'وضع البطاقات',
                              textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: game.scoringMode == ScoringMode.card
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<GameProvider>().setScoringMode(ScoringMode.manual);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: game.scoringMode == ScoringMode.manual
                                  ? const Color(0xFF3574F0)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'وضع يدوي',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: game.scoringMode == ScoringMode.manual
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: game.scoringMode == ScoringMode.manual
                      ? _buildManualModeList(game, players, keyboardHeight)
                      : _buildCardModeGrid(game, players, keyboardHeight),
                ),
              ],
            ),
            
            // Fixed bottom buttons
            Positioned(
              left: 20,
              right: 20,
              // Pin to bottom safe area + 40px (Ad) + 12px (Margin)
              bottom: MediaQuery.paddingOf(context).bottom + 40 + 12,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3574F0), // اللون الأزرق
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: game.currentRoundProgress == players.length
                            ? () {
                                final List<String> errors = [];
                                
                                // Check if all players have zero scores
                                bool allZero = true;
                                for (int i = 0; i < players.length; i++) {
                                  final tot = game.pendingScoreForPlayer(i) ?? 0;
                                  if (tot != 0) {
                                    allZero = false;
                                    break;
                                  }
                                }
                                if (allZero) {
                                  errors.add('لا يمكن تسجيل جولة صفرية\nيرجى إدخال نقاط لكل لاعب');
                                }
                                
                                // Only validate card-specific rules in card mode
                                if (game.scoringMode == ScoringMode.card && !allZero) {
                                  int sibeetaCount = 0;
                                  int demanCount = 0;
                                  int totalHash = 0;
                                  for (int i = 0; i < players.length; i++) {
                                    final comps = game.pendingComponentsForPlayer(i) ?? {'sibeeta': 0, 'deman': 0, 'hash': 0, 'minus': 0};
                                    if ((comps['sibeeta'] as num? ?? 0).toInt() > 0) sibeetaCount++;
                                    if ((comps['deman'] as num? ?? 0).toInt() > 0) demanCount++;
                                    totalHash += (comps['hash'] as num? ?? 0).toInt();
                                  }
                                  
                                  // Require exactly one queen and exactly one 10-diamond.
                                  if (sibeetaCount != 1) {
                                    errors.add('يجب ان يمتلك لاعب واحد بطاقة بنت السبيت\nيرجى التحقق من هو صاحب البطاقة');
                                  }
                                  if (demanCount != 1) {
                                    errors.add('يجب ان يمتلك لاعب واحد بطاقة عشرة الديمن\nيرجى التحقق من هو صاحب البطاقة');
                                  }

                                  // Hearts total must be exactly 13 or 26 across all players.
                                  if (!(totalHash == 13 || totalHash == 26)) {
                                    errors.add('مجموع نقاط الهاص يجب ان يكون 13 او 26 نقطة فقط\nالمجموع الحالي: $totalHash');
                                  }
                                }

                                if (errors.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      content: Text(
                                        errors.join('\n\n'),
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context).dialogTheme.contentTextStyle?.copyWith(
                                          fontSize: 20,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: Text('حسنا', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                game.finalizeRound();
                                Navigator.pop(context); // العودة للداشبورد يدوياً
                              }
                            : null,
                        child: Text('تسجيل', 
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: game.currentRoundProgress > 0 ? () async {
                        final should = await showDialog<bool>(
                          context: context,
                          builder: (c) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('هل أنت متأكد من إعادة التعيين ؟',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).dialogTheme.titleTextStyle),
                                  const SizedBox(height: 12),
                                  Text('سيتم حذف جميع النقاط المدخلة في هذه الجولة. هل تريد المتابعة ؟',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).dialogTheme.contentTextStyle?.copyWith(
                                        color: const Color.fromARGB(255, 255, 82, 82),
                                      )),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.of(c).pop(false),
                                        child: Text('لا', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                                      ),
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: () => Navigator.of(c).pop(true),
                                        child: Text('نعم', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                        if (should == true) {
                          game.clearPendingScores();
                          // Also clear local text controllers to keep UI in sync
                          for (var controller in _controllers.values) {
                            controller.clear();
                          }
                        }
                      } : null,
                      child: Icon(Icons.refresh, color: game.currentRoundProgress > 0 ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).dividerColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Keyboard action bar
            if (_focusNodes.values.any((n) => n.hasFocus) && keyboardHeight > 0 && game.scoringMode == ScoringMode.manual)
              Positioned(
                left: 0,
                right: 0,
                bottom: keyboardHeight,
                child: KeyboardActionBar(
                  onPrevious: () {
                    // Find which index is focused
                    int currentIdx = -1;
                    for (int i = 0; i < players.length; i++) {
                      if (_focusNodes[i]?.hasFocus ?? false) {
                        currentIdx = i;
                        break;
                      }
                    }
                    if (currentIdx > 0) {
                      _focusNodes[currentIdx - 1]?.requestFocus();
                    }
                  },
                  onNext: () {
                    int currentIdx = -1;
                    for (int i = 0; i < players.length; i++) {
                      if (_focusNodes[i]?.hasFocus ?? false) {
                        currentIdx = i;
                        break;
                      }
                    }
                    if (currentIdx != -1 && currentIdx < players.length - 1) {
                      _focusNodes[currentIdx + 1]?.requestFocus();
                    }
                  },
                  onDone: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
          ],
        ),
      );
  }

  Widget _buildManualModeList(GameProvider game, List<Player> players, double keyboardHeight) {
    // Bottom padding: Ad(40) + Button(54) + Spacing(20) + Safe Area
    final double bottomPadding = keyboardHeight > 0 
        ? keyboardHeight + 80 
        : MediaQuery.paddingOf(context).bottom + 120;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding),
      itemCount: players.length,

      itemBuilder: (context, i) {
        final p = players[i];
        final hasScoredThisRound = game.pendingScoreForPlayer(i) != null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasScoredThisRound
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasScoredThisRound
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  p.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_controllers.containsKey(i))
                Expanded(
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center, // Center text vertically
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF3574F0),
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0), // Push text down
                       isDense: true,
                    ),
                    onChanged: (value) => _updateScore(i, value),
                    onSubmitted: (value) {
                      _updateScore(i, value);
                      // Move to next player if available
                      if (i + 1 < players.length && _focusNodes.containsKey(i + 1)) {
                        _focusNodes[i + 1]!.requestFocus();
                      } else {
                        _focusNodes[i]?.unfocus();
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardModeGrid(GameProvider game, List<Player> players, double keyboardHeight) {
    // Bottom padding: Ad(40) + Button(54) + Spacing(20) + Safe Area
    final double bottomPadding = keyboardHeight > 0 
        ? keyboardHeight + 80 
        : MediaQuery.paddingOf(context).bottom + 120;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: players.length,
      itemBuilder: (context, i) {
        final p = players[i];
        bool hasScoredThisRound = game.pendingScoreForPlayer(i) != null;
        
        return InkWell(
          onTap: () {
            context.read<GameProvider>().selectPlayer(i);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScoreEntryScreen()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: hasScoredThisRound 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: hasScoredThisRound ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 22)), // 18 -> 22
                if (hasScoredThisRound)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('${game.pendingScoreForPlayer(i)}', 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF3574F0), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 24,
                      )),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}