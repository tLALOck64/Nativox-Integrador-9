import '../models/practice_mode_model.dart';
import '../models/challenge_model.dart';
import '../models/practice_stats_model.dart';

class PracticeService {
  static final PracticeService _instance = PracticeService._internal();
  factory PracticeService() => _instance;
  PracticeService._internal();

  // Datos simulados de modos de práctica
  final List<PracticeModeModel> _practiceModes = [
    PracticeModeModel(
      id: 'listen',
      icon: '🎧',
      title: 'Escuchar',
      subtitle: 'Pronunciación',
      difficulty: PracticeDifficulty.easy,
      completedSessions: 7,
    ),
    PracticeModeModel(
      id: 'speak',
      icon: '💬',
      title: 'Hablar',
      subtitle: 'Practica tu voz',
      difficulty: PracticeDifficulty.medium,
      completedSessions: 4,
    ),
    PracticeModeModel(
      id: 'write',
      icon: '✍️',
      title: 'Escribir',
      subtitle: 'Ortografía',
      difficulty: PracticeDifficulty.medium,
      completedSessions: 3,
    ),
    PracticeModeModel(
      id: 'translate',
      icon: '🧩',
      title: 'Traducir',
      subtitle: 'Comprensión',
      difficulty: PracticeDifficulty.hard,
      completedSessions: 1,
    ),
  ];

  // Datos simulados de desafíos
  final List<ChallengeModel> _challenges = [
    ChallengeModel(
      id: 'perfect_streak',
      emoji: '🔥',
      title: 'Racha perfecta',
      durationMinutes: 10,
      objective: '15 respuestas correctas',
      xpReward: 50,
      bonusReward: 'Desbloquea insignia',
      progress: 12,
      target: 15,
      status: ChallengeStatus.inProgress,
    ),
    ChallengeModel(
      id: 'greetings_master',
      emoji: '🌟',
      title: 'Maestro de saludos',
      durationMinutes: 5,
      objective: 'Practica saludos',
      xpReward: 25,
      bonusReward: 'Nuevo avatar',
      status: ChallengeStatus.available,
    ),
    ChallengeModel(
      id: 'speed_challenge',
      emoji: '⚡',
      title: 'Velocidad',
      durationMinutes: 3,
      objective: 'Responde rápido',
      xpReward: 75,
      bonusReward: 'Gemas bonus',
      status: ChallengeStatus.available,
    ),
  ];

  // Estadísticas simuladas
  PracticeStatsModel _practiceStats = PracticeStatsModel(
    wordsPracticed: 156,
    accuracy: 89.0,
    weeklyGoalDays: 3,
    weeklyGoalTarget: 5,
    totalSessions: 24,
    totalTimeMinutes: 450,
    lastPracticeDate: DateTime.now().subtract(const Duration(hours: 2)),
    categoryProgress: {
      'Saludos': 85,
      'Familia': 60,
      'Comida': 40,
      'Naturaleza': 20,
    },
  );

  // Obtener todos los modos de práctica
  Future<List<PracticeModeModel>> getPracticeModes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_practiceModes);
  }

  // Obtener modo de práctica por ID
  Future<PracticeModeModel?> getPracticeModeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _practiceModes.firstWhere((mode) => mode.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener todos los desafíos
  Future<List<ChallengeModel>> getChallenges() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_challenges);
  }

  // Obtener desafíos disponibles
  Future<List<ChallengeModel>> getAvailableChallenges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _challenges
        .where((challenge) => 
            challenge.status == ChallengeStatus.available ||
            challenge.status == ChallengeStatus.inProgress)
        .toList();
  }

  // Obtener estadísticas de práctica
  Future<PracticeStatsModel> getPracticeStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _practiceStats;
  }

  // Iniciar sesión de práctica
  Future<bool> startPracticeSession(String modeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final modeIndex = _practiceModes.indexWhere((mode) => mode.id == modeId);
      if (modeIndex != -1 && _practiceModes[modeIndex].isUnlocked) {
        // Aquí iniciarías la lógica de la sesión de práctica
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Completar sesión de práctica
  Future<bool> completePracticeSession(String modeId, {
    required int wordsCorrect,
    required int totalWords,
    required int durationMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final modeIndex = _practiceModes.indexWhere((mode) => mode.id == modeId);
      if (modeIndex != -1) {
        // Actualizar modo de práctica
        _practiceModes[modeIndex] = _practiceModes[modeIndex].copyWith(
          completedSessions: _practiceModes[modeIndex].completedSessions + 1,
        );

        // Actualizar estadísticas
        final newAccuracy = (wordsCorrect / totalWords) * 100;
        _practiceStats = _practiceStats.copyWith(
          wordsPracticed: _practiceStats.wordsPracticed + totalWords,
          accuracy: (_practiceStats.accuracy + newAccuracy) / 2, // Promedio simple
          totalSessions: _practiceStats.totalSessions + 1,
          totalTimeMinutes: _practiceStats.totalTimeMinutes + durationMinutes,
          lastPracticeDate: DateTime.now(),
        );

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Iniciar desafío
  Future<bool> startChallenge(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
          status: ChallengeStatus.inProgress,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Actualizar progreso del desafío
  Future<bool> updateChallengeProgress(String challengeId, int newProgress) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        final challenge = _challenges[challengeIndex];
        _challenges[challengeIndex] = challenge.copyWith(
          progress: newProgress,
          status: newProgress >= challenge.target
              ? ChallengeStatus.completed
              : ChallengeStatus.inProgress,
          completedAt: newProgress >= challenge.target 
              ? DateTime.now() 
              : null,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Actualizar meta semanal
  Future<bool> updateWeeklyGoal(int newGoalDays) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      _practiceStats = _practiceStats.copyWith(weeklyGoalDays: newGoalDays);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reiniciar estadísticas (para testing)
  Future<void> resetPracticeData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Reiniciar modos de práctica
    for (int i = 0; i < _practiceModes.length; i++) {
      _practiceModes[i] = _practiceModes[i].copyWith(completedSessions: 0);
    }
    
    // Reiniciar desafíos
    for (int i = 0; i < _challenges.length; i++) {
      _challenges[i] = _challenges[i].copyWith(
        status: ChallengeStatus.available,
        progress: 0,
        completedAt: null,
      );
    }
    
    // Reiniciar estadísticas
    _practiceStats = PracticeStatsModel(
      wordsPracticed: 0,
      accuracy: 0.0,
      weeklyGoalDays: 0,
      weeklyGoalTarget: 5,
      totalSessions: 0,
      totalTimeMinutes: 0,
      lastPracticeDate: DateTime.now(),
    );
  }
}