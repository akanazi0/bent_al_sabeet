import 'package:flutter/material.dart';

enum ScoringMode { card, manual }

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
  ScoringMode scoringMode = ScoringMode.card; // Default to card mode
  bool isHeartsDoubled = false; // Global hearts doubled state for current round
  // Store pending score components per player so we can validate special cards
  // (بنت السبيت, عشرة الديمن, الهاص, الماينس) individually before finalizing.
  // Using Map<String, dynamic> to store 'selectedHearts' as a Set<int>.
  final Map<int, Map<String, dynamic>> _pendingScores = {};

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

  void setScoringMode(ScoringMode mode) {
    scoringMode = mode;
    notifyListeners();
  }

  void toggleHeartsDoubled() {
    isHeartsDoubled = !isHeartsDoubled;
    // Recalculate all pending scores with the new doubled state
    _recalculatePendingScores();
    notifyListeners();
  }

  /// Recalculate all pending scores based on current doubled state
  void _recalculatePendingScores() {
    _pendingScores.forEach((playerIndex, components) {
      final selectedHearts = components['selectedHearts'] as Set<int>? ?? <int>{};
      final heartsCount = selectedHearts.length;
      // Update hash based on current doubled state
      components['hash'] = heartsCount * (isHeartsDoubled ? 2 : 1);
    });
  }

  /// Add manual score for the currently selected player (used in manual mode).
  void addManualScore(int score) {
    if (players == null || _selectedPlayerIndex == null) return;
    _pendingScores[_selectedPlayerIndex!] = {
      'sibeeta': 0,
      'deman': 0,
      'hash': 0,
      'minus': score,
      'selectedHearts': <int>{},
    };
    _selectedPlayerIndex = null;
    notifyListeners();
  }


  /// Add pending score components for the currently selected player.
  void addPendingScoreComponents({
    required int sibeeta, 
    required int deman, 
    required int hash, 
    required int minus,
    Set<int>? selectedHearts,
  }) {
    if (players == null || _selectedPlayerIndex == null) return;
    // Store the hearts count and recalculate hash based on current doubled state
    final heartsCount = selectedHearts?.length ?? 0;
    final actualHash = heartsCount * (isHeartsDoubled ? 2 : 1);
    
    _pendingScores[_selectedPlayerIndex!] = {
      'sibeeta': sibeeta,
      'deman': deman,
      'hash': actualHash,
      'minus': minus,
      'selectedHearts': selectedHearts ?? <int>{},
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
        _pendingScores[i] = {
          'sibeeta': 0, 
          'deman': 0, 
          'hash': 0, 
          'minus': 0,
          'selectedHearts': <int>{},
        };
      }
    }
    notifyListeners();
  }

  /// Clear all pending scores for the current round and set all players to 0
  void clearPendingScores() {
    _pendingScores.clear();
    isHeartsDoubled = false;
    // Prefill all players with 0
    if (players != null) {
      for (int i = 0; i < players!.length; i++) {
        _pendingScores[i] = {
          'sibeeta': 0,
          'deman': 0,
          'hash': 0,
          'minus': 0,
          'selectedHearts': <int>{},
        };
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
      final val = (components['sibeeta'] as int? ?? 0) + 
                  (components['deman'] as int? ?? 0) + 
                  (components['hash'] as int? ?? 0) + 
                  (components['minus'] as int? ?? 0);
      players![i].scores.add(val);
    }

    // Clear pending scores after committing.
    _pendingScores.clear();
    isHeartsDoubled = false; // Reset doubled state for next round

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
    for (var p in players!) {
      p.isDealer = false;
    }
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
    return (c['sibeeta'] as int? ?? 0) + 
           (c['deman'] as int? ?? 0) + 
           (c['hash'] as int? ?? 0) + 
           (c['minus'] as int? ?? 0);
  }

  /// Returns the raw pending components map for a player, or null.
  Map<String, dynamic>? pendingComponentsForPlayer(int index) => _pendingScores[index];

  /// Check if بنت السبيت (Queen of Spades) has been claimed by another player
  bool isSibeetaClaimedByOther(int currentPlayerIndex) {
    for (int i = 0; i < (players?.length ?? 0); i++) {
      if (i != currentPlayerIndex) {
        final components = _pendingScores[i];
        if (components != null && (components['sibeeta'] as num? ?? 0).toInt() > 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Check if عشرة الديمن (10 of Diamonds) has been claimed by another player
  bool isDemanClaimedByOther(int currentPlayerIndex) {
    for (int i = 0; i < (players?.length ?? 0); i++) {
      if (i != currentPlayerIndex) {
        final components = _pendingScores[i];
        if (components != null && (components['deman'] as num? ?? 0).toInt() > 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns the total count of hearts taken by OTHER players in the current round.
  int getTotalHeartsTakenByOthers(int currentPlayerIndex) {
    int count = 0;
    _pendingScores.forEach((playerIdx, components) {
      if (playerIdx != currentPlayerIndex) {
        final hearts = components['selectedHearts'] as Set<int>?;
        if (hearts != null) {
          count += hearts.length;
        }
      }
    });
    return count;
  }


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