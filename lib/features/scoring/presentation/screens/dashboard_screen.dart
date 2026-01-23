import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'player_selection_screen.dart';
import 'round_details_screen.dart';

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
            backgroundColor: const Color(0xFF2B2B2B),
            title: const Text('إنهاء اللعبة؟',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text('هل أنت متأكد من إنهاء اللعبة؟',
                textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFA9B7C6))),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('لا', style: TextStyle(color: Color(0xFF3574F0))),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('نعم', style: TextStyle(color: Colors.redAccent)),
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
        backgroundColor: const Color(0xFF1E1F22),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1F22),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFA9B7C6)),
            onPressed: () async {
              if (await _onWillPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text('بنت السبيت',
              style: TextStyle(color: Color(0xFFA9B7C6), fontSize: 20, fontWeight: FontWeight.bold)),
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
                            color: const Color(0xFF2B2B2B),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: p.isKing ? const Color(0xFF3574F0) : const Color(0xFF3E3E3E),
                              width: p.isKing ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${p.totalScore}',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              if (p.isKing) const Text('👑 الكنق', style: TextStyle(color: Color(0xFF3574F0), fontSize: 16)),
                              if (p.isDealer) const Text('الموزع', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
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
                                color: const Color(0xFF1E1F22),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isLatestRound ? const Color(0xFF3574F0) : const Color(0xFF3E3E3E),
                                  width: isLatestRound ? 2 : 1,
                                ),
                                boxShadow: isLatestRound
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF3574F0).withOpacity(0.12),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          backgroundColor: const Color(0xFF3574F0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: () {
                          // Prefill pending zeros immediately so the selection
                          // screen is already ready without animations.
                          game.prefillPendingZeros();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PlayerSelectionScreen()),
                          );
                        },
                        child: const Text('التسجيل', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3E3E3E)),
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
                                color: const Color(0xFF2B2B2B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('هل أنت متأكد من التراجع؟',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text('سيتم إزالة آخر جولة مسجلة. هل تريد المتابعة؟',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(color: Color.fromARGB(255, 255, 82, 82), fontSize: 14)),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.of(c).pop(false),
                                        child: const Text('لا', style: TextStyle(color: Color(0xFF3574F0), fontSize: 14)),
                                      ),
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: () => Navigator.of(c).pop(true),
                                        child: const Text('نعم', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
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
                      child: const Icon(Icons.undo, color: Color(0xFFA9B7C6), size: 20),
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