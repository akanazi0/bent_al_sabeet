import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'player_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _verticalController = ScrollController();
  GameProvider? _gameProvider;

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('إنهاء اللعبة ؟',
                textAlign: TextAlign.right,
                style: Theme.of(context).dialogTheme.titleTextStyle),
            content: Text('هل أنت متأكد من إنهاء اللعبة ؟',
                textAlign: TextAlign.right, 
                style: Theme.of(context).dialogTheme.contentTextStyle),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('لا', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('نعم', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.redAccent)),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verticalController.hasClients) {
        try {
          _verticalController.jumpTo(_verticalController.position.maxScrollExtent);
        } catch (_) {}
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gp = Provider.of<GameProvider>(context);
    if (_gameProvider != gp) {
      _gameProvider?.removeListener(_scrollToLatest);
      _gameProvider = gp;
      _gameProvider?.addListener(_scrollToLatest);
    }
  }

  @override
  void dispose() {
    _gameProvider?.removeListener(_scrollToLatest);
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final playersList = game.players ?? [];
    final playerCount = playersList.length;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            tooltip: '',
            icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () async {
              if (await _onWillPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text('بنت السبيت',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ),
        body: Column(
          children: [
            // Top player strip sized to match grid columns so columns align.
            LayoutBuilder(builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth - 24; // account for horizontal padding
              final double spacing = (playerCount > 1) ? 8.0 : 0.0;
              final double cellWidth = playerCount > 0 ? (availableWidth - (playerCount - 1) * spacing) / playerCount : availableWidth;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 130,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(playerCount, (i) {
                        final p = playersList[i];
                        return Container(
                          width: cellWidth,
                          margin: EdgeInsets.only(right: i == playerCount - 1 ? 0 : spacing, left: 0, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: p.isKing ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                              width: p.isKing ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${p.totalScore}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),

                              if (p.isDealer) Text('الموزع', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontSize: 16)),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // Grid of rounds under player cards: columns aligned per player,
            // oldest at top, newest at bottom. Vertical-only scroll.
            Builder(builder: (context) {
              final int maxRounds = playersList.isEmpty
                  ? 0
                  : playersList.map((p) => p.scores.length).reduce((a, b) => a > b ? a : b);
              final double cellHeight = 56.0; // slightly larger for touch

              if (maxRounds == 0) {
                return const SizedBox(height: 40);
              }

              final int lastIndex = maxRounds - 1;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: LayoutBuilder(builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  final double cellWidth = (availableWidth - (playerCount - 1) * 8) / (playerCount > 0 ? playerCount : 1);

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: ListView.builder(
                      controller: _verticalController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: maxRounds,
                      itemBuilder: (context, roundIndex) {
                        // show oldest at top -> newest at bottom
                        return Row(
                          children: List.generate(playerCount, (pIndex) {
                            final p = playersList[pIndex];
                            final bool has = roundIndex < p.scores.length;
                            final text = has ? '${p.scores[roundIndex]}' : '';
                            final bool isLatestRound = roundIndex == lastIndex;
                            return Container(
                              width: cellWidth,
                              margin: EdgeInsets.only(right: pIndex == playerCount - 1 ? 0 : 8, bottom: 8),
                              height: cellHeight,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isLatestRound ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                                  width: isLatestRound ? 2 : 1,
                                ),
                                boxShadow: isLatestRound
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                                child: Center(
                                  child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                            );
                          }),
                        );
                      },
                    ),
                  );
                }),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {
                          // Prefill pending zeros immediately so the selection
                          // screen is already ready without animations.
                          game.prefillPendingZeros();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlayerSelectionScreen()),
                          ).then((_) {
                            final result = game.checkForGameOver();
                            if (result != null) {
                              final winners = result['winners'] as List<Player>;
                              final losers = result['losers'] as List<Player>;
                              
                              showDialog(
                                barrierDismissible: false,
                                context: context, 
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('انتهت اللعبة', 
                                          textAlign: TextAlign.center, 
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rubik')
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Losers section
                                        Text('قامت على', 
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold)
                                        ),
                                        const SizedBox(height: 8),
                                          ...losers.map((p) => Text(
                                            '${p.name} (${p.totalScore})',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontSize: 20, 
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                          
                                          const Divider(height: 32),
                                          
                                          // Winners section
                                          Text('نقاط اللعبة', 
                                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)
                                          ),
                                          const SizedBox(height: 8),
                                          ...winners.map((p) => Text(
                                            '${p.name} (${p.totalScore})',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontSize: 20, 
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                          
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: Text('حسناً', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        child: Text('التسجيل', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () async {
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
                                  Text('هل أنت متأكد من التراجع ؟',
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).dialogTheme.titleTextStyle),
                                  const SizedBox(height: 12),
                                  Text('سيتم إزالة آخر جولة مسجلة. هل تريد المتابعة ؟',
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
                          game.undoLastRound();
                        }
                      },
                      child: Icon(Icons.undo, color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}