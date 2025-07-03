import '../models/user_progress_model.dart';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  // Simulación de datos del usuario
  UserProgressModel _userProgress = UserProgressModel(
    userId: 'user123',
    overallProgress: 0.3,
    currentLevel: 'Básico',
    streakDays: 7,
    totalLessonsCompleted: 2,
    totalTimeSpent: 45, // minutos
    nextLesson: 'Saludos tradicionales',
    lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
  );

  // Obtener progreso del usuario
  Future<UserProgressModel> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _userProgress;
  }

  // Actualizar progreso general
  Future<bool> updateOverallProgress(double progress) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      _userProgress = _userProgress.copyWith(
        overallProgress: progress,
        lastActivity: DateTime.now(),
      );
      
      // Actualizar nivel basado en progreso
      String newLevel = _calculateLevel(progress);
      if (newLevel != _userProgress.currentLevel) {
        _userProgress = _userProgress.copyWith(currentLevel: newLevel);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Actualizar racha de días
  Future<bool> updateStreak() async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final now = DateTime.now();
      final lastActivity = _userProgress.lastActivity;
      final daysSinceLastActivity = now.difference(lastActivity).inDays;
      
      int newStreak = _userProgress.streakDays;
      
      if (daysSinceLastActivity == 1) {
        // Continuar racha
        newStreak += 1;
      } else if (daysSinceLastActivity > 1) {
        // Reiniciar racha
        newStreak = 1;
      }
      // Si daysSinceLastActivity == 0, mantener racha actual
      
      _userProgress = _userProgress.copyWith(
        streakDays: newStreak,
        lastActivity: now,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Completar una lección
  Future<bool> completeLesson(String lessonId, int duration) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      _userProgress = _userProgress.copyWith(
        totalLessonsCompleted: _userProgress.totalLessonsCompleted + 1,
        totalTimeSpent: _userProgress.totalTimeSpent + duration,
        lastActivity: DateTime.now(),
      );
      
      // Actualizar progreso general
      await _recalculateOverallProgress();
      
      // Actualizar racha
      await updateStreak();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Establecer siguiente lección
  Future<bool> setNextLesson(String lessonTitle) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      _userProgress = _userProgress.copyWith(nextLesson: lessonTitle);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final hoursSpent = (_userProgress.totalTimeSpent / 60).round();
    final averageSessionTime = _userProgress.totalLessonsCompleted > 0
        ? (_userProgress.totalTimeSpent / _userProgress.totalLessonsCompleted).round()
        : 0;
    
    return {
      'overallProgress': _userProgress.overallProgress,
      'currentLevel': _userProgress.currentLevel,
      'streakDays': _userProgress.streakDays,
      'totalLessonsCompleted': _userProgress.totalLessonsCompleted,
      'totalTimeSpent': _userProgress.totalTimeSpent,
      'hoursSpent': hoursSpent,
      'averageSessionTime': averageSessionTime,
      'nextLesson': _userProgress.nextLesson,
      'isStreakActive': _userProgress.isStreakActive,
    };
  }

  // Reiniciar progreso del usuario
  Future<void> resetUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userProgress = UserProgressModel(
      userId: _userProgress.userId,
      overallProgress: 0.0,
      currentLevel: 'Principiante',
      streakDays: 0,
      totalLessonsCompleted: 0,
      totalTimeSpent: 0,
      nextLesson: 'Saludos básicos',
      lastActivity: DateTime.now(),
    );
  }

  // Métodos privados
  String _calculateLevel(double progress) {
    if (progress >= 0.8) return 'Avanzado';
    if (progress >= 0.5) return 'Intermedio';
    if (progress >= 0.2) return 'Básico';
    return 'Principiante';
  }

  Future<void> _recalculateOverallProgress() async {
    // Aquí podrías implementar una lógica más compleja
    // basada en las lecciones completadas
    // Por ahora, aumentamos el progreso de forma incremental
    double newProgress = _userProgress.overallProgress + 0.1;
    if (newProgress > 1.0) newProgress = 1.0;
    
    _userProgress = _userProgress.copyWith(overallProgress: newProgress);
  }
}