import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'score_entry_screen.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final players = game.players ?? [];
    
    int minScores = players.isNotEmpty 
        ? players.map((p) => p.scores.length).reduce((a, b) => a < b ? a : b) 
        : 0;
    int currentRoundNumber = minScores + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F22),
        elevation: 0,
        automaticallyImplyLeading: false, // حذف زر الرجوع العلوي
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA9B7C6)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('التسجيل رقم $currentRoundNumber', 
          style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
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
                          ? const Color(0xFF3574F0).withOpacity(0.1) 
                          : const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: hasScoredThisRound ? const Color(0xFF3574F0) : const Color(0xFF3E3E3E)
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.name, style: const TextStyle(fontSize: 18, color: Color(0xFFA9B7C6))),
                        if (hasScoredThisRound)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('${game.pendingScoreForPlayer(i)}', 
                              style: const TextStyle(color: Color(0xFF3574F0), fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // الزر الأزرق المطلوب في الأسفل - يظهر دائماً، مفعل فقط عند إكمال الجولة
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3574F0), // اللون الأزرق
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: game.currentRoundProgress == players.length
                    ? () {
                        // Validate special-card rules across pending components
                        int sibeetaCount = 0;
                        int demanCount = 0;
                        int totalHash = 0;
                        for (int i = 0; i < players.length; i++) {
                          final comps = game.pendingComponentsForPlayer(i) ?? {'sibeeta': 0, 'deman': 0, 'hash': 0, 'minus': 0};
                          if ((comps['sibeeta'] ?? 0) > 0) sibeetaCount++;
                          if ((comps['deman'] ?? 0) > 0) demanCount++;
                          totalHash += (comps['hash'] ?? 0);
                        }

                        final List<String> errors = [];
                        // Reject if all players have pending total == 0
                        bool allZero = true;
                        for (int i = 0; i < players.length; i++) {
                          final tot = game.pendingScoreForPlayer(i) ?? 0;
                          if (tot != 0) {
                            allZero = false;
                            break;
                          }
                        }
                        if (allZero) {
                          errors.add('لا يمكن تسجيل جولة بجميع اللاعبين بصفر\nيرجى إدخال نقاط لكل لاعب');
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
                          errors.add('مجموع نقاط الهاص يجب ان تكون 13 او 26 نقطة\nالمجموع الحالي: $totalHash');
                        }

                        if (errors.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1F22),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              content: Text(
                                errors.join('\n\n'),
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Color(0xFFA9B7C6), fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('حسناً', style: TextStyle(color: Color(0xFF3574F0))),
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
                child: const Text('تسجيل', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}