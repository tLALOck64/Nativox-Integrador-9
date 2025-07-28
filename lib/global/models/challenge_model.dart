enum ChallengeStatus {
  available,
  inProgress,
  completed,
  locked,
}

class ChallengeModel {
  final String id;
  final String emoji;
  final String title;
  final int durationMinutes;
  final String objective;
  final int xpReward;
  final String bonusReward;
  final ChallengeStatus status;
  final int progress;
  final int target;
  final DateTime? completedAt;
  final DateTime? availableUntil;

  ChallengeModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.durationMinutes,
    required this.objective,
    required this.xpReward,
    required this.bonusReward,
    this.status = ChallengeStatus.available,
    this.progress = 0,
    this.target = 100,
    this.completedAt,
    this.availableUntil,
  });

  // Factory constructor para crear desde JSON
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'],
      emoji: json['emoji'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      objective: json['objective'],
      xpReward: json['xpReward'],
      bonusReward: json['bonusReward'],
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString() == 'ChallengeStatus.${json['status']}',
        orElse: () => ChallengeStatus.available,
      ),
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 100,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      availableUntil: json['availableUntil'] != null 
          ? DateTime.parse(json['availableUntil'])
          : null,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emoji': emoji,
      'title': title,
      'durationMinutes': durationMinutes,
      'objective': objective,
      'xpReward': xpReward,
      'bonusReward': bonusReward,
      'status': status.toString().split('.').last,
      'progress': progress,
      'target': target,
      'completedAt': completedAt?.toIso8601String(),
      'availableUntil': availableUntil?.toIso8601String(),
    };
  }

  // Método para crear una copia con modificaciones
  ChallengeModel copyWith({
    String? id,
    String? emoji,
    String? title,
    int? durationMinutes,
    String? objective,
    int? xpReward,
    String? bonusReward,
    ChallengeStatus? status,
    int? progress,
    int? target,
    DateTime? completedAt,
    DateTime? availableUntil,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      objective: objective ?? this.objective,
      xpReward: xpReward ?? this.xpReward,
      bonusReward: bonusReward ?? this.bonusReward,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      completedAt: completedAt ?? this.completedAt,
      availableUntil: availableUntil ?? this.availableUntil,
    );
  }

  // Getters útiles
  double get progressPercentage => progress / target;
  
  bool get isCompleted => status == ChallengeStatus.completed;
  
  bool get isExpired => availableUntil != null && 
      DateTime.now().isAfter(availableUntil!);
  
  String get statusText {
    switch (status) {
      case ChallengeStatus.available:
        return 'Disponible';
      case ChallengeStatus.inProgress:
        return 'En progreso';
      case ChallengeStatus.completed:
        return 'Completado';
      case ChallengeStatus.locked:
        return 'Bloqueado';
    }
  }

  String get timeText => '⏱️ $durationMinutes min';
  
  String get rewardText => '🏆 +$xpReward XP • $bonusReward';
}