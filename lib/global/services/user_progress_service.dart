import '../models/user_progress_model.dart';
import '../../core/services/streak_manager.dart';
import '../../games/lecciones/lesson_service.dart';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  final StreakManager _streakManager = StreakManager();
  final LessonService _lessonService = LessonService();

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
    
    // Obtener la racha real desde StreakManager
    int streak = await _streakManager.getTotalDays();
    
    // Calcular progreso basado en lecciones completadas vs total
    double calculatedProgress = await _calculateProgressFromLessons();
    
    _userProgress = _userProgress.copyWith(
      streakDays: streak,
      overallProgress: calculatedProgress,
      lastActivity: DateTime.now(),
    );
    
    // Actualizar nivel basado en el progreso calculado
    String newLevel = _calculateLevel(calculatedProgress);
    if (newLevel != _userProgress.currentLevel) {
      _userProgress = _userProgress.copyWith(currentLevel: newLevel);
    }
    
    return _userProgress;
  }

  // Nuevo método para calcular progreso basado en lecciones
  Future<double> _calculateProgressFromLessons() async {
    try {
      // Obtener estadísticas de progreso desde el servicio de lecciones
      final progressStats = await _lessonService.getProgressStats();
      
      final int completedLessons = progressStats['completedLessons'] ?? 0;
      final int totalLessons = progressStats['totalLessons'] ?? 0;
      
      // Calcular progreso como porcentaje de lecciones completadas
      if (totalLessons > 0) {
        double progress = completedLessons / totalLessons;
        // Asegurar que el progreso esté entre 0.0 y 1.0
        return progress.clamp(0.0, 1.0);
      }
      
      return 0.0;
    } catch (e) {
      print('Error calculating progress from lessons: $e');
      return _userProgress.overallProgress; // Mantener progreso anterior si hay error
    }
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
      // Marcar la lección como completada en el servicio de lecciones
      await _lessonService.completeLesson(lessonId);
      
      _userProgress = _userProgress.copyWith(
        totalLessonsCompleted: _userProgress.totalLessonsCompleted + 1,
        totalTimeSpent: _userProgress.totalTimeSpent + duration,
        lastActivity: DateTime.now(),
      );
      
      // Recalcular progreso basado en lecciones actualizadas
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
    
    // Obtener estadísticas actualizadas de lecciones
    final lessonStats = await _lessonService.getProgressStats();
    
    final hoursSpent = (_userProgress.totalTimeSpent / 60).round();
    final averageSessionTime = _userProgress.totalLessonsCompleted > 0
        ? (_userProgress.totalTimeSpent / _userProgress.totalLessonsCompleted).round()
        : 0;
    
    return {
      'overallProgress': _userProgress.overallProgress,
      'currentLevel': _userProgress.currentLevel,
      'streakDays': _userProgress.streakDays,
      'totalLessonsCompleted': lessonStats['completedLessons'] ?? _userProgress.totalLessonsCompleted,
      'totalLessons': lessonStats['totalLessons'] ?? 0,
      'totalTimeSpent': _userProgress.totalTimeSpent,
      'hoursSpent': hoursSpent,
      'averageSessionTime': averageSessionTime,
      'nextLesson': _userProgress.nextLesson,
      'isStreakActive': _userProgress.isStreakActive,
      'completionRate': lessonStats['completionRate'] ?? 0.0,
    };
  }

  // Reiniciar progreso del usuario
  Future<void> resetUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Resetear progreso en el servicio de lecciones
    await _lessonService.resetProgress();
    
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
    // Calcular progreso basado en lecciones completadas vs total
    double newProgress = await _calculateProgressFromLessons();
    
    _userProgress = _userProgress.copyWith(overallProgress: newProgress);
  }

  Future<void> initStreak() async {
    await _streakManager.registerFirstUse();
    await _streakManager.registerNewDayIfNeeded();
  }

  Future<DateTime?> getFirstUseDate() async {
    return await _streakManager.getFirstUseDate();
  }

  Future<int> getTotalDays() async {
    return await _streakManager.getTotalDays();
  }

  Future<DateTime?> getLastStreakDay() async {
    return await _streakManager.getLastDay();
  }
}