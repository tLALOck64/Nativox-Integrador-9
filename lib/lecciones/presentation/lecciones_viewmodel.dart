import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';
import '../../services/lesson_service.dart';

enum LessonsState { initial, loading, loaded, error }

class LessonsViewModel extends ChangeNotifier {
  final LessonService _lessonService = LessonService();
  
  // State
  LessonsState _state = LessonsState.initial;
  Map<String, List<LessonModel>> _lessonsByLevel = {};
  Map<String, int> _lessonStats = {};
  String _errorMessage = '';
  int _selectedIndex = 1; // Lessons tab is selected
  
  // Orden de niveles para mostrar
  final List<String> _levelOrder = ['Básico', 'Intermedio', 'Avanzado'];
  
  // Getters
  LessonsState get state => _state;
  Map<String, List<LessonModel>> get lessonsByLevel => _lessonsByLevel;
  Map<String, int> get lessonStats => _lessonStats;
  String get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;
  List<String> get levelOrder => _levelOrder;
  
  bool get isLoading => _state == LessonsState.loading;
  bool get hasError => _state == LessonsState.error;
  bool get hasData => _lessonsByLevel.isNotEmpty;
  
  // Public methods
  Future<void> loadData() async {
    try {
      _setState(LessonsState.loading);
      
      // Cargar datos en paralelo
      final results = await Future.wait([
        _lessonService.getLessonsByLevel(),
        _lessonService.getLessonStats(),
      ]);
      
      _lessonsByLevel = results[0] as Map<String, List<LessonModel>>;
      _lessonStats = results[1] as Map<String, int>;
      
      _setState(LessonsState.loaded);
    } catch (e) {
      _errorMessage = 'Error al cargar las lecciones';
      _setState(LessonsState.error);
    }
  }
  
  Future<void> refreshData() async {
    await loadData();
  }
  
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
  
  bool canStartLesson(LessonModel lesson) {
    return !lesson.isLocked;
  }
  
  String getLessonMessage(LessonModel lesson) {
    if (lesson.isLocked) {
      return 'Esta lección está bloqueada. Completa las anteriores primero.';
    }
    
    if (lesson.isCompleted) {
      return 'Ya completaste esta lección. ¡Bien hecho! Puedes repetirla.';
    }
    
    return 'Iniciando lección: ${lesson.title}';
  }
  
  Future<void> startLesson(LessonModel lesson) async {
    // Simular inicio de lección
    // Aquí podrías navegar a la pantalla de la lección individual
    // return NavigationService.navigateToLessonDetail(lesson);
  }
  
  List<MapEntry<String, List<LessonModel>>> getOrderedLevels() {
    final orderedLevels = <MapEntry<String, List<LessonModel>>>[];
    
    // Agregar niveles en orden específico
    for (final level in _levelOrder) {
      if (_lessonsByLevel.containsKey(level)) {
        orderedLevels.add(MapEntry(level, _lessonsByLevel[level]!));
      }
    }
    
    // Agregar cualquier nivel adicional que no esté en el orden predefinido
    for (final entry in _lessonsByLevel.entries) {
      if (!_levelOrder.contains(entry.key)) {
        orderedLevels.add(entry);
      }
    }
    
    return orderedLevels;
  }
  
  // Private methods
  void _setState(LessonsState newState) {
    _state = newState;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}