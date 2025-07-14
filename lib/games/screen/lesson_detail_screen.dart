// games/screens/lesson_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/games/models/lesson_detail_model.dart';
import 'package:integrador/games/screen/completion_exercise_screen.dart';
import 'package:integrador/games/screen/selection_exercis_screen.dart';
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
  bool _isSubmittingAnswer = false;
  int _currentExerciseIndex = 0;
  List<ExerciseResultModel> _results = [];
  
  final String _usuarioId = 'e62539c6-bdcb-4ef2-bd93-9d7cc85fa630';

  @override
  void initState() {
    super.initState();
    _loadLesson();
    print("llego a lesson detail screen con id: ${widget.lessonId}");
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
      // ✅ POST a tu API
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

      // Validar respuesta localmente
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isCorrect ? '¡Correcto!' : 'Incorrecto',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            isCorrect 
              ? '¡Excelente! Has respondido correctamente.'
              : 'No te preocupes, sigue practicando para mejorar.',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: score >= 70 
                        ? [Colors.green, Colors.green.shade700]
                        : score >= 50 
                          ? [Colors.orange, Colors.orange.shade700]
                          : [Colors.red, Colors.red.shade700],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    score >= 70 ? Icons.emoji_events : 
                    score >= 50 ? Icons.thumb_up : Icons.refresh,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎉 ¡Lección completada!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puntuación: $score%',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[200],
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: score / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: score >= 70 
                            ? [Colors.green, Colors.green.shade700]
                            : score >= 50 
                              ? [Colors.orange, Colors.orange.shade700]
                              : [Colors.red, Colors.red.shade700],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  score >= 70 ? '¡Excelente trabajo!' : 
                  score >= 50 ? 'Buen trabajo, sigue practicando' : 
                  'Intenta nuevamente para mejorar',
                  style: TextStyle(
                    color: score >= 70 ? Colors.green : 
                           score >= 50 ? Colors.orange : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/lessons');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A574),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver a lecciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildCurrentExercise(),
                ),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lesson!.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lesson!.contenidoJson.descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    final exercise = _lesson!.ejercicios[_currentExerciseIndex];
    
    // ✅ AQUÍ ES DONDE SE DECIDE QUÉ PANTALLA MOSTRAR
    switch (exercise.tipo.toLowerCase()) {
      case 'selección':
        return SelectionExerciseScreen(
          exercise: exercise,
          currentIndex: _currentExerciseIndex,
          totalExercises: _lesson!.ejercicios.length,
          onAnswerSelected: _submitAnswer,
          isSubmitting: _isSubmittingAnswer,
        );
        
      case 'completar':
        return CompletionExerciseScreen(
          exercise: exercise,
          currentIndex: _currentExerciseIndex,
          totalExercises: _lesson!.ejercicios.length,
          onAnswerSelected: _submitAnswer,
          isSubmitting: _isSubmittingAnswer,
        );
        
      case 'traducción':
        // TODO: Crear TranslationExerciseScreen si lo necesitas
        return _buildUnsupportedExercise(exercise.tipo);
        
      case 'emparejamiento':
        // TODO: Crear MatchingExerciseScreen si lo necesitas  
        return _buildUnsupportedExercise(exercise.tipo);
        
      default:
        return _buildUnsupportedExercise(exercise.tipo);
    }
  }

  Widget _buildUnsupportedExercise(String tipo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: 64,
                  color: Colors.orange[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Ejercicio en desarrollo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipo: "$tipo"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esta pantalla estará disponible pronto.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Simular respuesta correcta para continuar
              _submitAnswer("respuesta_temporal");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Continuar (temporal)'),
          ),
        ],
      ),
    );
  }
}
