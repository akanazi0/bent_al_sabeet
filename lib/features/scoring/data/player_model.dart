class Player {
  String name;
  int totalScore;
  bool isKing;
  bool isDealer;
  List<int> roundHistory;

  Player({
    required this.name,
    this.totalScore = 0,
    this.isKing = false,
    this.isDealer = false,
    List<int>? roundHistory,
  }) : roundHistory = roundHistory ?? [];
}

class GameSession {
  List<Player> players;
  int scoreLimit;
  List<List<int>> rounds;

  GameSession({
    required this.players,
    this.scoreLimit = 151,
    List<List<int>>? rounds,
  }) : rounds = rounds ?? [];
}