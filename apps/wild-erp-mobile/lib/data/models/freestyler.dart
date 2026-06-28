class Freestyler {
  final String id;
  final String userId;
  final String? userName;
  final String? avatarUrl;
  final int wins;
  final int losses;
  final int draws;
  final int eloRating;
  final int totalBattles;
  final int longestWinStreak;
  final int currentWinStreak;
  final Map<String, double>? statSliders;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Freestyler({
    required this.id,
    required this.userId,
    this.userName,
    this.avatarUrl,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.eloRating = 1000,
    this.totalBattles = 0,
    this.longestWinStreak = 0,
    this.currentWinStreak = 0,
    this.statSliders,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Freestyler.fromJson(Map<String, dynamic> json) {
    return Freestyler(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      eloRating: json['elo_rating'] as int? ?? 1000,
      totalBattles: json['total_battles'] as int? ?? 0,
      longestWinStreak: json['longest_win_streak'] as int? ?? 0,
      currentWinStreak: json['current_win_streak'] as int? ?? 0,
      statSliders: json['stat_sliders'] != null
          ? Map<String, double>.from(json['stat_sliders'] as Map)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'elo_rating': eloRating,
      'total_battles': totalBattles,
      'longest_win_streak': longestWinStreak,
      'current_win_streak': currentWinStreak,
      'stat_sliders': statSliders,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get winRate =>
      totalBattles > 0 ? (wins / totalBattles * 100) : 0;

  String get record => '$wins - $losses - $draws';
}

class Battle {
  final String id;
  final String? freestyler1Id;
  final String? freestyler2Id;
  final String? freestyler1Name;
  final String? freestyler2Name;
  final String? winnerId;
  final String? winnerName;
  final String? loserId;
  final String? loserName;
  final bool isDraw;
  final int? score1;
  final int? score2;
  final String? notes;
  final DateTime battleDate;
  final DateTime createdAt;

  Battle({
    required this.id,
    this.freestyler1Id,
    this.freestyler2Id,
    this.freestyler1Name,
    this.freestyler2Name,
    this.winnerId,
    this.winnerName,
    this.loserId,
    this.loserName,
    this.isDraw = false,
    this.score1,
    this.score2,
    this.notes,
    required this.battleDate,
    required this.createdAt,
  });

  factory Battle.fromJson(Map<String, dynamic> json) {
    return Battle(
      id: json['id'] as String,
      freestyler1Id: json['freestyler_1_id'] as String?,
      freestyler2Id: json['freestyler_2_id'] as String?,
      freestyler1Name: json['freestyler_1_name'] as String?,
      freestyler2Name: json['freestyler_2_name'] as String?,
      winnerId: json['winner_id'] as String?,
      winnerName: json['winner_name'] as String?,
      loserId: json['loser_id'] as String?,
      loserName: json['loser_name'] as String?,
      isDraw: json['is_draw'] as bool? ?? false,
      score1: json['score1'] as int?,
      score2: json['score2'] as int?,
      notes: json['notes'] as String?,
      battleDate: DateTime.tryParse(json['battle_date'] as String? ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'freestyler_1_id': freestyler1Id,
      'freestyler_2_id': freestyler2Id,
      'freestyler_1_name': freestyler1Name,
      'freestyler_2_name': freestyler2Name,
      'winner_id': winnerId,
      'winner_name': winnerName,
      'loser_id': loserId,
      'loser_name': loserName,
      'is_draw': isDraw,
      'score1': score1,
      'score2': score2,
      'notes': notes,
      'battle_date': battleDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get result {
    if (isDraw) return 'Empate';
    if (winnerName != null) return 'Gana: $winnerName';
    return 'Pendiente';
  }

  String get matchUp {
    final p1 = freestyler1Name ?? '???';
    final p2 = freestyler2Name ?? '???';
    final score =
        score1 != null && score2 != null ? ' ($score1 - $score2)' : '';
    return '$p1 vs $p2$score';
  }
}
