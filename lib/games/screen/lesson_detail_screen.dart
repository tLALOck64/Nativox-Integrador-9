import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/games/models/exercise_detail_model.dart';
import 'package:integrador/games/models/lesson_detail_model.dart';
import 'package:integrador/games/services/lesson_detail_service.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonDetailService _service = LessonDetailService();
  
  LessonDetailModel? _lesson;
  LessonProgressModel? _progress;
  bool _isLoading = true;
  int _currentExerciseIndex = 0;
  List<ExerciseResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);
    
    try {
      final lesson = await _service.getLessonById(widget.lessonId);
      if (lesson != null) {
        setState(() {
          _lesson = lesson;
          _progress = LessonProgressModel.empty(widget.lessonId);
          _isLoading = false;
        });
      } else {
        _showError('Lección no encontrada');
      }
    } catch (e) {
      _showError('Error al cargar la lección');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() => _isLoading = false);
  }

  void _submitAnswer(dynamic answer) {
    if (_lesson == null || _currentExerciseIndex >= _lesson!.ejercicios.length) {
      return;
    }

    final exercise = _lesson!.ejercicios[_currentExerciseIndex];
    final isCorrect = _service.validateAnswer(exercise, answer);
    
    final result = ExerciseResultModel(
      exerciseIndex: _currentExerciseIndex,
      userAnswer: answer,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    setState(() {
      _results.add(result);
    });

    _showResult(isCorrect);
  }

  void _showResult(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isCorrect ? '¡Correcto!' : 'Incorrecto'),
          ],
        ),
        content: Text(
          isCorrect 
            ? '¡Bien hecho! Continúa con el siguiente ejercicio.'
            : 'No te preocupes, sigue practicando.',
        ),
        actions: [
          ElevatedButton(
            onPressed: _nextExercise,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    Navigator.of(context).pop(); // Cerrar dialog
    
    if (_currentExerciseIndex < _lesson!.ejercicios.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    final score = _service.calculateScore(_results);
    final progress = LessonProgressModel(
      lessonId: widget.lessonId,
      results: _results,
      completionPercentage: 100.0,
      isCompleted: true,
      score: score,
    );

    _service.saveProgress(progress);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Lección completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Puntuación: $score%'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                score >= 70 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/lessons'); // Volver a lecciones
            },
            child: const Text('Volver a lecciones'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
            ),
          ),
        ),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudo cargar la lección'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: _buildCurrentExercise(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  _lesson!.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _lesson!.contenidoJson.descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentExerciseIndex + 1) / _lesson!.ejercicios.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ejercicio ${_currentExerciseIndex + 1} de ${_lesson!.ejercicios.length}'),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    final exercise = _lesson!.ejercicios[_currentExerciseIndex];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de ejercicio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              exercise.tipo.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Enunciado
          Text(
            exercise.enunciado,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Widget del ejercicio según tipo
          Expanded(
            child: _buildExerciseWidget(exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWidget(ExerciseModel exercise) {
    switch (exercise.tipo) {
      case 'selección':
      case 'completar':
        return _buildSelectionExercise(exercise);
      case 'traducción':
        return _buildTranslationExercise(exercise);
      case 'emparejamiento':
        return _buildMatchingExercise(exercise);
      default:
        return const Text('Tipo de ejercicio no soportado');
    }
  }

  Widget _buildSelectionExercise(ExerciseModel exercise) {
    return Column(
      children: [
        ...exercise.opcionesString.map((option) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => _submitAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C2C2C),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTranslationExercise(ExerciseModel exercise) {
    final controller = TextEditingController();
    
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe tu respuesta aquí...',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitAnswer(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Enviar respuesta'),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingExercise(ExerciseModel exercise) {
    // Implementación simplificada para emparejamiento
    return Column(
      children: [
        Text(
          'Toca para emparejar (implementación simplificada)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _submitAnswer(exercise.respuestaCorrecta),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Continuar (Auto-correcto)'),
          ),
        ),
      ],
    );
  }
}
