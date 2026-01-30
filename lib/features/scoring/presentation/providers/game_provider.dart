import 'package:flutter/material.dart';

class Player {
  final String name;
  final List<int> scores = [];
  bool isKing = false;
  bool isDealer = false;

  Player({required this.name});

  int get totalScore => scores.fold(0, (a, b) => a + b);
}

class GameProvider extends ChangeNotifier {
  List<Player>? players;
  int? _selectedPlayerIndex;
  int pointsLimit = 152; // Default limit
  // Store pending score components per player so we can validate special cards
  // (بنت السبيت, عشرة الديمن, الهاص, الماينس) individually before finalizing.
  final Map<int, Map<String, int>> _pendingScores = {};

  int? get selectedPlayerIndex => _selectedPlayerIndex;

  void startNewGame(List<String> names, int limit) {
    pointsLimit = limit;
    players = names.map((name) => Player(name: name)).toList();
    // Ensure no titles at the very start of a new game; titles will
    // be assigned only after the first committed round via
    // `finalizeRound()`. Initialize each player's scores with a single
    // zero so totals show 0 by default.
    _pendingScores.clear();
    _selectedPlayerIndex = null;
    for (var p in players!) {
      p.isDealer = false;
      p.isKing = false;
      p.scores.clear();
    }
    notifyListeners();
  }

  void selectPlayer(int index) {
    _selectedPlayerIndex = index;
    notifyListeners();
  }


  /// Add pending score components for the currently selected player.
  void addPendingScoreComponents({required int sibeeta, required int deman, required int hash, required int minus}) {
    if (players == null || _selectedPlayerIndex == null) return;
    _pendingScores[_selectedPlayerIndex!] = {
      'sibeeta': sibeeta,
      'deman': deman,
      'hash': hash,
      'minus': minus,
    };
    _selectedPlayerIndex = null;
    notifyListeners();
  }

  /// Prefill pending scores with zeros for all players that don't have a pending value.
  /// Useful when opening the player-selection UI so players that will score 0
  /// can be quickly committed without extra taps.
  void prefillPendingZeros() {
    if (players == null) return;
    for (int i = 0; i < players!.length; i++) {
      if (!_pendingScores.containsKey(i)) {
        _pendingScores[i] = {'sibeeta': 0, 'deman': 0, 'hash': 0, 'minus': 0};
      }
    }
    notifyListeners();
  }

  void finalizeRound() {
    if (players == null) return;
    // Commit pending scores to each player's score list. If a player has no
    // pending score, commit a 0 for that round.
    for (int i = 0; i < players!.length; i++) {
      final components = _pendingScores.containsKey(i)
          ? _pendingScores[i]!
          : {'sibeeta': 0, 'deman': 0, 'hash': 0, 'minus': 0};
      final val = (components['sibeeta'] ?? 0) + (components['deman'] ?? 0) + (components['hash'] ?? 0) + (components['minus'] ?? 0);
      players![i].scores.add(val);
    }

    // Clear pending scores after committing.
    _pendingScores.clear();

    // Update king: mark ALL players tied for the minimum score.
    int minScore = players!.map((p) => p.totalScore).reduce((a, b) => a < b ? a : b);
    for (var p in players!) {
      p.isKing = p.totalScore == minScore;
    }

    // Update dealer (الموزع): keep previous dealer if tied for the maximum;
    // otherwise assign to the earliest player in the tie.
    int maxScore = players!.map((p) => p.totalScore).reduce((a, b) => a > b ? a : b);
    final tiedDealerIndices = <int>[];
    for (int i = 0; i < players!.length; i++) {
      if (players![i].totalScore == maxScore) tiedDealerIndices.add(i);
    }
    int prevDealerIndex = players!.indexWhere((p) => p.isDealer);
    // clear all dealers first
    for (var p in players!) p.isDealer = false;
    if (tiedDealerIndices.isNotEmpty) {
      if (prevDealerIndex != -1 && tiedDealerIndices.contains(prevDealerIndex)) {
        players![prevDealerIndex].isDealer = true;
      } else {
        players![tiedDealerIndices.first].isDealer = true;
      }
    }

    notifyListeners();
  }

  int get currentRoundProgress {
    if (players == null || players!.isEmpty) return 0;
    // Use pending (uncommitted) scores to determine progress for the
    // currently being-entered round.
    return _pendingScores.length;
  }

  /// Returns the pending total (sum of components) for a player, or null.
  int? pendingScoreForPlayer(int index) {
    final c = _pendingScores[index];
    if (c == null) return null;
    return (c['sibeeta'] ?? 0) + (c['deman'] ?? 0) + (c['hash'] ?? 0) + (c['minus'] ?? 0);
  }

  /// Returns the raw pending components map for a player, or null.
  Map<String, int>? pendingComponentsForPlayer(int index) => _pendingScores[index];


  void undoLastRound() {
    if (players == null) return;
    for (var p in players!) {
      if (p.scores.isNotEmpty) p.scores.removeLast();
    }
    // If we've undone back to zero committed rounds, remove any titles.
    final hasAnyRounds = players!.any((p) => p.scores.isNotEmpty);
    if (!hasAnyRounds) {
      for (var p in players!) {
        p.isKing = false;
        p.isDealer = false;
      }
    } else {
      // Recalculate kings based on common minimum
      int minScore = players!.map((p) => p.totalScore).reduce((a, b) => a < b ? a : b);
      for (var p in players!) {
        p.isKing = p.totalScore == minScore;
      }
    }
    notifyListeners();
  }

  Map<String, List<Player>>? checkForGameOver() {
    if (players == null || players!.isEmpty) return null;
    
    // Check if any player has reached or exceeded the points limit
    bool limitReached = players!.any((p) => p.totalScore >= pointsLimit);
    
    if (limitReached) {
      // Find min and max scores
      int minScore = players!.map((p) => p.totalScore).reduce((a, b) => a < b ? a : b);
      int maxScore = players!.map((p) => p.totalScore).reduce((a, b) => a > b ? a : b);
      
      List<Player> winners = players!.where((p) => p.totalScore == minScore).toList();
      List<Player> losers = players!.where((p) => p.totalScore == maxScore).toList();
      
      return {'winners': winners, 'losers': losers};
    }
    
    return null;
  }
}