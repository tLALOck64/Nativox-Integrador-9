import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isSubmittingAnswer = false; // Para mostrar loading al enviar respuesta
  int _currentExerciseIndex = 0;
  List<ExerciseResultModel> _results = [];
  
  // ✅ NUEVO: ID de usuario (en una app real vendría del authentication)
  final String _usuarioId = 'e62539c6-bdcb-4ef2-bd93-9d7cc85fa630'; // Hardcoded por ahora

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔄 Loading lesson: ${widget.lessonId}');
      
      final lesson = await _service.getLessonById(widget.lessonId);
      if (lesson != null) {
        final progress = await _service.getProgress(widget.lessonId);
        
        setState(() {
          _lesson = lesson;
          _progress = progress ?? LessonProgressModel.empty(widget.lessonId);
          _isLoading = false;
        });
        
        print('✅ Lesson loaded: ${lesson.titulo}');
      } else {
        _showError('Lección no encontrada');
      }
    } on LessonDetailException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error al cargar la lección: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: _loadLesson,
        ),
      ),
    );
    setState(() => _isLoading = false);
  }

  void _submitAnswer(dynamic answer) async {
    if (_lesson == null || 
        _currentExerciseIndex >= _lesson!.ejercicios.length ||
        _isSubmittingAnswer) {
      return;
    }

    final exercise = _lesson!.ejercicios[_currentExerciseIndex];
    
    setState(() {
      _isSubmittingAnswer = true;
    });

    try {
      // ✅ NUEVO: Enviar respuesta a la API
      final success = await _service.resolverEjercicio(
        lessonId: widget.lessonId,
        ejercicioId: exercise.id,
        usuarioId: _usuarioId,
        respuesta: answer,
      );

      if (!success) {
        _showError('Error al enviar la respuesta. Intenta nuevamente.');
        setState(() {
          _isSubmittingAnswer = false;
        });
        return;
      }

      // Validar respuesta localmente también
      final isCorrect = _service.validateAnswer(exercise, answer);
      
      final result = ExerciseResultModel(
        exerciseIndex: _currentExerciseIndex,
        userAnswer: answer,
        isCorrect: isCorrect,
        timestamp: DateTime.now(),
      );

      setState(() {
        _results.add(result);
        _isSubmittingAnswer = false;
      });

      _showResult(isCorrect);
      
    } catch (e) {
      setState(() {
        _isSubmittingAnswer = false;
      });
      _showError('Error al procesar la respuesta: ${e.toString()}');
    }
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
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              isCorrect ? '¡Correcto!' : 'Incorrecto',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          isCorrect 
            ? '¡Excelente! Has respondido correctamente.'
            : 'No te preocupes, sigue practicando para mejorar.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: _nextExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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

  void _finishLesson() async {
    final score = _service.calculateScore(_results);
    final progress = LessonProgressModel(
      lessonId: widget.lessonId,
      results: _results,
      completionPercentage: 100.0,
      isCompleted: true,
      score: score,
    );

    try {
      await _service.saveProgress(progress);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              '🎉 ¡Lección completada!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puntuación: $score%',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 70 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  score >= 70 ? '¡Excelente trabajo!' : 
                  score >= 50 ? 'Buen trabajo, sigue practicando' : 
                  'Intenta nuevamente para mejorar',
                  style: TextStyle(
                    color: score >= 70 ? Colors.green : 
                           score >= 50 ? Colors.orange : Colors.red,
                    fontWeight: FontWeight.w500,
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
    } catch (e) {
      _showError('Error al guardar el progreso: ${e.toString()}');
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
                ),
                SizedBox(height: 16),
                Text(
                  'Cargando lección...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No se pudo cargar la lección',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
              Text(
                'Ejercicio ${_currentExerciseIndex + 1} de ${_lesson!.ejercicios.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
        return _buildSelectionExercise(exercise);
      case 'completar':
        return _buildSelectionExercise(exercise); // Similar a selección
      case 'traducción':
        return _buildTranslationExercise(exercise);
      case 'emparejamiento':
        return _buildMatchingExercise(exercise);
      default:
        return Center(
          child: Text(
            'Tipo de ejercicio "${exercise.tipo}" no soportado',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
    }
  }

  Widget _buildSelectionExercise(ExerciseModel exercise) {
    return Column(
      children: [
        ...exercise.contenido.opciones.map((option) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _isSubmittingAnswer ? null : () => _submitAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C2C2C),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: _isSubmittingAnswer 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
                    ),
                  )
                : Text(
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
          enabled: !_isSubmittingAnswer,
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta aquí...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: _isSubmittingAnswer ? Colors.grey[100] : Colors.white,
          ),
          style: const TextStyle(fontSize: 16),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmittingAnswer ? null : () => _submitAnswer(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            child: _isSubmittingAnswer
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Enviando...'),
                  ],
                )
              : const Text('Enviar respuesta'),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingExercise(ExerciseModel exercise) {
    // Implementación simplificada para emparejamiento
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            'Ejercicio de emparejamiento - Implementación simplificada',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Mostrar opciones de emparejamiento si las hay
        if (exercise.contenido.opciones.isNotEmpty) ...[
          ...exercise.contenido.opciones.map((option) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                option,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmittingAnswer ? null : () => _submitAnswer(exercise.respuestaCorrecta),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            child: _isSubmittingAnswer
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Enviando...'),
                  ],
                )
              : const Text('Continuar (Auto-correcto)'),
          ),
        ),
      ],
    );
  }
}