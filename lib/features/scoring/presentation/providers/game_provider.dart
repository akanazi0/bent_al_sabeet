import 'package:flutter/material.dart';
import '../../data/player_model.dart';

class GameProvider extends ChangeNotifier {
  GameSession? session;

  void startNewGame(List<String> names, int limit) {
    session = GameSession(
      players: names.map((n) => Player(name: n)).toList(),
      scoreLimit: limit,
    );
    notifyListeners();
  }

  void addRound(List<int> scores) {
    if (session == null) return;
    
    for (int i = 0; i < session!.players.length; i++) {
      session!.players[i].totalScore += scores[i];
      session!.players[i].roundHistory.add(scores[i]);
    }
    session!.rounds.add(scores);
    _updateTitles();
    notifyListeners();
  }

  void undoLastRound() {
    if (session == null || session!.rounds.isEmpty) return;
    
    List<int> lastRound = session!.rounds.removeLast();
    for (int i = 0; i < session!.players.length; i++) {
      session!.players[i].totalScore -= lastRound[i];
      session!.players[i].roundHistory.removeLast();
    }
    _updateTitles();
    notifyListeners();
  }

  void _updateTitles() {
    if (session == null) return;
    
    int min = session!.players.map((p) => p.totalScore).reduce((a, b) => a < b ? a : b);
    int max = session!.players.map((p) => p.totalScore).reduce((a, b) => a > b ? a : b);

    for (var p in session!.players) {
      p.isKing = (p.totalScore == min && min != 0);
    }

    bool dealerSet = false;
    for (var p in session!.players) {
      if (p.totalScore == max && max != 0 && !dealerSet) {
        p.isDealer = true;
        dealerSet = true;
      } else {
        p.isDealer = false;
      }
    }
  }
}