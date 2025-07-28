// games/screens/lesson_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/games/lecciones/lesson_service.dart';
import 'package:integrador/games/lecciones/models/lesson_detail_model.dart';
import 'package:integrador/games/lecciones/screens/completion_exercise_screen.dart';
import 'package:integrador/games/lecciones/screens/selection_exercis_screen.dart';
import 'package:integrador/games/lecciones/services/lesson_detail_service.dart';
import 'package:integrador/core/services/secure_storage_service.dart';

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
  
  // ✅ NUEVA VARIABLE PARA FORZAR RESET DE EJERCICIOS
  Key _exerciseKey = UniqueKey();
  
  String? _usuarioId;

  @override
  void initState() {
    super.initState();
    _initUserAndLoadLesson();
    print("llego a lesson detail screen con id: ${widget.lessonId}");
  }

  Future<void> _initUserAndLoadLesson() async {
    // Obtener el usuarioId desde SecureStorageService
    final userData = await SecureStorageService().getUserData();
    setState(() {
      _usuarioId = userData?['id'] ?? userData?['uid'] ?? '';
      print('🔑 Usuario ID: $_usuarioId');
    });
    await _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);
    
    try {
      print('🔄 Loading lesson: ${widget.lessonId}');
      
      final lesson = await _service.getLessonById(widget.lessonId);
      if (lesson != null) {
        // ✅ OBTENER PROGRESO AL ENTRAR A LA LECCIÓN
        final progress = await _service.getProgressForCurrentUser(widget.lessonId);
        
        setState(() {
          _lesson = lesson;
          _progress = progress ?? LessonProgressModel.empty(widget.lessonId);
          _isLoading = false;
        });
        
        // ✅ VERIFICAR SI LA LECCIÓN ESTÁ COMPLETADA (100%)
        if (_progress != null && _progress!.completionPercentage >= 100.0) {
          print('🎉 Lección completada al 100% - Mostrando opción de reiniciar');
          _showLessonCompletedDialog();
          return;
        }
        
        // ✅ CONFIGURAR EL ÍNDICE DEL EJERCICIO ACTUAL BASADO EN EL PROGRESO
        if (_progress != null) {
          // ✅ NUEVA LÓGICA: CALCULAR EJERCICIO ACTUAL BASADO EN PORCENTAJE DE PROGRESO
          final totalExercises = lesson.ejercicios.length;
          final progressPercentage = _progress!.completionPercentage;
          
          // Calcular cuántos ejercicios están completados basado en el porcentaje
          final completedExercises = (progressPercentage / 100.0 * totalExercises).round();
          
          print('📊 Progreso encontrado: ${progressPercentage}%');
          print('📊 Ejercicios totales: $totalExercises');
          print('📊 Ejercicios completados (calculado): $completedExercises');
          
          // ✅ El ejercicio actual es el siguiente al último completado
          int nextExerciseIndex = completedExercises;
          
          // Asegurar que no exceda el rango de ejercicios
          if (nextExerciseIndex >= totalExercises) {
            nextExerciseIndex = totalExercises - 1;
            print('📊 Todos los ejercicios completados - Mostrando último ejercicio');
          }
          
          _currentExerciseIndex = nextExerciseIndex;
          
          print('📊 Ejercicio actual asignado: $_currentExerciseIndex');
          
          // ✅ DEBUG: VERIFICAR CON RESULTADOS EXISTENTES SI HAY
          if (_progress!.results.isNotEmpty) {
            final completedIndices = _progress!.results
                .map((result) => result.exerciseIndex)
                .toSet()
                .toList()
                ..sort();
            
            print('📝 Ejercicios completados (según resultados): $completedIndices');
            print('📝 Total de resultados: ${_progress!.results.length}');
            
            // Verificar si hay discrepancia entre porcentaje y resultados
            if (completedIndices.length != completedExercises) {
              print('⚠️ Discrepancia detectada: ${completedIndices.length} resultados vs $completedExercises calculados');
              // Usar los resultados reales si hay discrepancia
              if (completedIndices.isNotEmpty) {
                final maxCompletedIndex = completedIndices.reduce((a, b) => a > b ? a : b);
                _currentExerciseIndex = maxCompletedIndex + 1;
                if (_currentExerciseIndex >= totalExercises) {
                  _currentExerciseIndex = totalExercises - 1;
                }
                print('📊 Corregido ejercicio actual a: $_currentExerciseIndex');
              }
            }
          }
        } else {
          print('📊 Sin progreso previo - Comenzando desde el primer ejercicio');
          _currentExerciseIndex = 0;
        }
        
        // ✅ DEBUG: VERIFICAR POSICIONAMIENTO
        _debugExercisePositioning();
        
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

  // ✅ NUEVO MÉTODO PARA MOSTRAR DIALOG DE LECCIÓN COMPLETADA
  void _showLessonCompletedDialog() {
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
                  colors: [Colors.green, Colors.green.shade700],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 ¡Lección Completada!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Puntuación: ${_progress!.score}%',
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
                widthFactor: 1.0, // 100%
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade700],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Excelente trabajo! Has completado esta lección.',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Te gustaría reiniciar la lección para practicar nuevamente?',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/lessons');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetLessonProgress();
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
                    'Reiniciar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO MÉTODO PARA REINICIAR PROGRESO DE LA LECCIÓN
  Future<void> _resetLessonProgress() async {
    try {
      print('🔄 Reiniciando progreso de la lección...');
      
      // ✅ ENVIAR UPDATE PROGRESS PARA REINICIAR
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      
      if (userId.isNotEmpty) {
        print('🔄 Enviando updateProgress con progreso 0%...');
        print('🔄 userId: $userId');
        print('🔄 lessonId: ${widget.lessonId}');
        
        // ✅ REINICIAR PROGRESO EN EL SERVIDOR
        final success = await LessonService().updateLessonProgressForUser(
          userId: userId,
          lessonId: widget.lessonId,
          progress: 0.0, // Reiniciar a 0%
        );
        
        if (success) {
          print('✅ Progreso reiniciado en servidor exitosamente');
          
          // ✅ REINICIAR ESTADO LOCAL INMEDIATAMENTE
          setState(() {
            _progress = LessonProgressModel.empty(widget.lessonId);
            _currentExerciseIndex = 0;
            _results.clear();
            _exerciseKey = UniqueKey(); // ✅ RESETEAR KEY PARA REINICIO COMPLETO
          });
          
          print('✅ Progreso reiniciado localmente');
          
          // ✅ REFRESCAR PROGRESO DESDE SERVIDOR PARA CONFIRMAR
          try {
            await _refreshProgress();
            print('✅ Progreso refrescado desde servidor');
          } catch (e) {
            print('⚠️ Error refrescando progreso, pero el reinicio local fue exitoso: $e');
          }
          
          // ✅ MOSTRAR MENSAJE DE CONFIRMACIÓN
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Progreso reiniciado. ¡Comienza de nuevo!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          
          // ✅ DEBUG: VERIFICAR QUE EL PROGRESO SE REINICIÓ
          print('🔍 === DEBUG REINICIO ===');
          print('📊 Progreso después del reinicio: ${_progress?.completionPercentage}%');
          print('📊 Ejercicio actual: $_currentExerciseIndex');
          print('📊 Resultados: ${_results.length}');
          print('📊 Progreso esperado: 0%');
          print('🔍 === FIN DEBUG ===');
          
        } else {
          print('❌ Error al reiniciar progreso en servidor');
          _showError('Error al reiniciar el progreso en el servidor. Intenta nuevamente.');
        }
      } else {
        print('❌ No se pudo obtener el ID del usuario');
        _showError('Error al reiniciar el progreso: Usuario no identificado');
      }
    } catch (e) {
      print('❌ Error reiniciando progreso: $e');
      _showError('Error al reiniciar el progreso: ${e.toString()}');
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

  // ✅ MÉTODO CORREGIDO - SOLO ACTUALIZA PROGRESO SI LA RESPUESTA ES CORRECTA
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
      print('📤 Procesando respuesta...');
      print('📤 Respuesta: $answer');
      print('📤 Ejercicio: ${exercise.id}');
      
      // ✅ PRIMERO VALIDAR SI LA RESPUESTA ES CORRECTA (LOCALMENTE)
      final isCorrect = _service.validateAnswer(exercise, answer);
      print('✅ Validación local: ${isCorrect ? "CORRECTA" : "INCORRECTA"}');
      
      // ✅ DEBUGGING DEL FLUJO
      _debugResponseFlow(answer, isCorrect);
      
      // ✅ SOLO ENVIAR AL SERVIDOR SI LA RESPUESTA ES CORRECTA
      if (isCorrect) {
        print('✅ Respuesta correcta - Enviando al servidor...');
        
        // ✅ POST a tu API para actualizar progreso SOLO SI ES CORRECTA
        final success = await _service.resolverEjercicio(
          lessonId: widget.lessonId,
          ejercicioId: exercise.id,
          usuarioId: _usuarioId ?? '',
          respuesta: answer,
        );

        // ✅ VERIFICAR SI EL SERVIDOR ACEPTÓ LA RESPUESTA
        if (!success) {
          print('❌ El servidor no aceptó la respuesta del ejercicio');
          setState(() {
            _isSubmittingAnswer = false;
          });
          
          // ✅ MOSTRAR DIALOG DE ERROR CON OPCIÓN DE REINTENTAR
          _showRetryDialog(answer);
          return;
        }

        print('✅ Servidor aceptó la respuesta correcta');
        
        // ✅ CREAR RESULTADO CORRECTO
        final result = ExerciseResultModel(
          exerciseIndex: _currentExerciseIndex,
          userAnswer: answer,
          isCorrect: true, // Sabemos que es correcta
          timestamp: DateTime.now(),
        );

        setState(() {
          _results.add(result);
          _isSubmittingAnswer = false;
        });

        // ✅ ACTUALIZAR PROGRESO LOCAL
        await _updateLocalProgress(result);
        
        // ✅ MOSTRAR RESULTADO EXITOSO
        _showResult(true);
        
      } else {
        // ✅ RESPUESTA INCORRECTA - NO ENVIAR AL SERVIDOR
        print('❌ Respuesta incorrecta - No se envía al servidor');
        
        setState(() {
          _isSubmittingAnswer = false;
        });
        
        // ✅ MOSTRAR RESULTADO INCORRECTO DIRECTAMENTE
        _showResult(false);
      }
      
    } catch (e) {
      print('❌ Error en el procesamiento: $e');
      setState(() {
        _isSubmittingAnswer = false;
      });
      
      // ✅ MOSTRAR DIALOG DE ERROR
      _showErrorDialog('Error al procesar la respuesta: ${e.toString()}');
    }
  }

  // ✅ MÉTODO MEJORADO PARA ACTUALIZAR PROGRESO LOCAL CON ANIMACIONES
  Future<void> _updateLocalProgress(ExerciseResultModel result) async {
    try {
      print('📊 Iniciando actualización de progreso local...');
      print('📊 Resultado correcto: ${result.isCorrect}');
      
      // ✅ ESTA FUNCIÓN SOLO SE LLAMA CON RESPUESTAS CORRECTAS
      if (!result.isCorrect) {
        print('⚠️ ADVERTENCIA: Se intentó actualizar progreso con respuesta incorrecta');
        return;
      }
      
      // Actualizar la lista de resultados
      if (_progress != null) {
        // Verificar si ya existe un resultado para este ejercicio
        final existingIndex = _progress!.results.indexWhere(
          (r) => r.exerciseIndex == result.exerciseIndex
        );
        
        List<ExerciseResultModel> updatedResults;
        
        if (existingIndex != -1) {
          // Actualizar resultado existente
          updatedResults = List<ExerciseResultModel>.from(_progress!.results);
          updatedResults[existingIndex] = result;
          print('📝 Actualizado resultado existente para ejercicio ${result.exerciseIndex}');
        } else {
          // Agregar nuevo resultado
          updatedResults = List<ExerciseResultModel>.from(_progress!.results);
          updatedResults.add(result);
          print('➕ Agregado nuevo resultado para ejercicio ${result.exerciseIndex}');
        }
        
        // Calcular nuevo porcentaje de completado SOLO CON RESPUESTAS CORRECTAS
        final totalExercises = _lesson!.ejercicios.length;
        final correctResults = updatedResults.where((r) => r.isCorrect).length;
        final newCompletionPercentage = (correctResults / totalExercises) * 100.0;
        final newScore = _service.calculateScore(updatedResults.where((r) => r.isCorrect).toList());
        
        // ✅ ACTUALIZAR PROGRESO CON ANIMACIÓN
        final oldPercentage = _progress!.completionPercentage;
        
        setState(() {
          _progress = _progress!.copyWith(
            results: updatedResults,
            completionPercentage: newCompletionPercentage,
            isCompleted: newCompletionPercentage >= 100.0,
            score: newScore,
          );
        });
        
        print('📊 Progreso actualizado exitosamente: ${oldPercentage.toStringAsFixed(1)}% → ${newCompletionPercentage.toStringAsFixed(1)}%');
        print('📊 Ejercicios correctos: $correctResults/$totalExercises');
        print('📊 Puntuación actual: $newScore%');
        
        // ✅ ENVIAR PROGRESO ACTUALIZADO AL SERVIDOR (GLOBAL)
        try {
          final userData = await SecureStorageService().getUserData();
          final userId = userData?['id'] ?? userData?['uid'] ?? '';
          
          if (userId.isNotEmpty) {
            print('🌐 Actualizando progreso global en servidor...');
            
            final success = await LessonService().updateLessonProgressForUser(
              userId: userId,
              lessonId: widget.lessonId,
              progress: newCompletionPercentage / 100.0, // Convertir a decimal
            );
            
            if (success) {
              print('✅ Progreso global actualizado en servidor');
            } else {
              print('⚠️ No se pudo actualizar progreso global en servidor');
            }
          }
        } catch (e) {
          print('❌ Error actualizando progreso global: $e');
          // No bloquear la UI por errores de servidor
        }
        
        // ✅ MOSTRAR NOTIFICACIÓN DE PROGRESO SI ES SIGNIFICATIVO
        if (newCompletionPercentage >= 100.0) {
          _showProgressNotification(
            '🎉 ¡Lección completada!', 
            'Has terminado todos los ejercicios con ${newScore}% de puntuación.'
          );
        } else if (newCompletionPercentage % 25 == 0 && newCompletionPercentage > oldPercentage) { 
          _showProgressNotification(
            '🚀 ¡Excelente progreso!', 
            'Has completado ${newCompletionPercentage.toStringAsFixed(0)}% de la lección.'
          );
        } else if (correctResults % 3 == 0 && correctResults > 0) {
          // Notificación cada 3 ejercicios correctos
          _showProgressNotification(
            '💪 ¡Sigue así!', 
            '$correctResults ejercicios completados correctamente.'
          );
        }
        
        // ✅ TRIGGER REBUILD DEL HEADER PARA ANIMACIÓN
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {});
          }
        });
        
      } else {
        print('⚠️ No hay progreso disponible para actualizar');
      }
    } catch (e) {
      print('❌ Error actualizando progreso local: $e');
    }
  }

  // ✅ NUEVO MÉTODO PARA MOSTRAR NOTIFICACIONES DE PROGRESO
  void _showProgressNotification(String title, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: _getProgressColor(_progress?.completionPercentage ?? 0.0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ NUEVO MÉTODO PARA REFRESCAR PROGRESO DESDE SERVIDOR
  Future<void> _refreshProgress() async {
    try {
      print('🔄 Refrescando progreso desde servidor...');
      final updatedProgress = await _service.getProgressForCurrentUser(widget.lessonId);
      
      if (updatedProgress != null) {
        setState(() {
          _progress = updatedProgress;
        });
        
        print('📊 Progreso refrescado desde servidor: ${updatedProgress.completionPercentage}%');
        
        // ✅ ACTUALIZAR ÍNDICE DEL EJERCICIO ACTUAL CON LA MISMA LÓGICA
        if (_progress != null && _lesson != null) {
          // ✅ NUEVA LÓGICA: CALCULAR EJERCICIO ACTUAL BASADO EN PORCENTAJE DE PROGRESO
          final totalExercises = _lesson!.ejercicios.length;
          final progressPercentage = _progress!.completionPercentage;
          
          // Calcular cuántos ejercicios están completados basado en el porcentaje
          final completedExercises = (progressPercentage / 100.0 * totalExercises).round();
          
          print('📊 Progreso refrescado: ${progressPercentage}%');
          print('📊 Ejercicios totales: $totalExercises');
          print('📊 Ejercicios completados (calculado): $completedExercises');
          
          // El ejercicio actual es el siguiente al último completado
          int nextExerciseIndex = completedExercises;
          
          // Asegurar que no exceda el rango de ejercicios
          if (nextExerciseIndex >= totalExercises) {
            nextExerciseIndex = totalExercises - 1;
            print('📊 Todos los ejercicios completados (refresh) - Mostrando último ejercicio');
          }
          
          _currentExerciseIndex = nextExerciseIndex;
          
          print('📊 Próximo ejercicio: $_currentExerciseIndex');
          
          // ✅ DEBUG: VERIFICAR CON RESULTADOS EXISTENTES SI HAY
          if (_progress!.results.isNotEmpty) {
            final completedIndices = _progress!.results
                .map((result) => result.exerciseIndex)
                .toSet()
                .toList()
                ..sort();
            
            print('📝 Ejercicios completados (según resultados): $completedIndices');
            print('📝 Total de resultados: ${_progress!.results.length}');
            
            // Verificar si hay discrepancia entre porcentaje y resultados
            if (completedIndices.length != completedExercises) {
              print('⚠️ Discrepancia detectada: ${completedIndices.length} resultados vs $completedExercises calculados');
              // Usar los resultados reales si hay discrepancia
              if (completedIndices.isNotEmpty) {
                final maxCompletedIndex = completedIndices.reduce((a, b) => a > b ? a : b);
                _currentExerciseIndex = maxCompletedIndex + 1;
                if (_currentExerciseIndex >= totalExercises) {
                  _currentExerciseIndex = totalExercises - 1;
                }
                print('📊 Corregido ejercicio actual a: $_currentExerciseIndex');
              }
            }
          }
        }
        
        print('✅ Progreso refrescado exitosamente: ${_progress!.completionPercentage}%');
      } else {
        print('⚠️ No se pudo obtener progreso actualizado del servidor');
      }
    } catch (e) {
      print('❌ Error refrescando progreso: $e');
      // No mostrar error al usuario si es solo un refresh
    }
  }

  // ✅ MÉTODO MEJORADO PARA OBTENER COLOR DE PROGRESO CON MÁS GRANULARIDAD
  Color _getProgressColor(double percentage) {
    if (percentage >= 100) {
      return Colors.green; // Completado
    } else if (percentage >= 80) {
      return Colors.green.shade400; // Casi completado
    } else if (percentage >= 60) {
      return Colors.blue; // Buen progreso
    } else if (percentage >= 40) {
      return Colors.orange; // Progreso moderado
    } else if (percentage >= 20) {
      return Colors.orange.shade300; // Progreso inicial
    } else if (percentage > 0) {
      return Colors.amber; // Comenzado
    } else {
      return Colors.grey; // Sin comenzar
    }
  }

  // ✅ MÉTODO DE DEBUG PARA VERIFICAR POSICIONAMIENTO
  void _debugExercisePositioning() {
    if (_progress != null && _lesson != null) {
      print('🔍 === DEBUG POSICIONAMIENTO ===');
      print('📊 Progreso total: ${_progress!.completionPercentage}%');
      print('📊 Ejercicios totales: ${_lesson!.ejercicios.length}');
      print('📊 Ejercicio actual: $_currentExerciseIndex');
      
      // ✅ NUEVA LÓGICA DE DEBUG
      final totalExercises = _lesson!.ejercicios.length;
      final progressPercentage = _progress!.completionPercentage;
      final completedExercises = (progressPercentage / 100.0 * totalExercises).round();
      
      print('📊 Ejercicios completados (calculado): $completedExercises');
      print('📊 Ejercicio esperado: $completedExercises');
      
      if (_progress!.results.isNotEmpty) {
        final completedIndices = _progress!.results
            .map((result) => result.exerciseIndex)
            .toSet()
            .toList()
            ..sort();
        
        print('📝 Ejercicios completados (según resultados): $completedIndices');
        print('📝 Total de resultados: ${_progress!.results.length}');
        
        // Verificar si el ejercicio actual está completado
        final isCurrentCompleted = completedIndices.contains(_currentExerciseIndex);
        print('❓ ¿Ejercicio actual completado?: $isCurrentCompleted');
        
        // Verificar si hay discrepancia
        if (completedIndices.length != completedExercises) {
          print('⚠️ Discrepancia detectada: ${completedIndices.length} resultados vs $completedExercises calculados');
        }
        
        // Mostrar próximos ejercicios no completados
        final nextUncompleted = <int>[];
        for (int i = 0; i < _lesson!.ejercicios.length; i++) {
          if (!completedIndices.contains(i)) {
            nextUncompleted.add(i);
          }
        }
        print('📋 Próximos ejercicios no completados: $nextUncompleted');
      } else {
        print('📝 Sin resultados de ejercicios');
      }
      print('🔍 === FIN DEBUG ===');
    }
  }

  // ✅ NUEVO MÉTODO PARA MOSTRAR DIALOG DE REINTENTAR
  void _showRetryDialog(dynamic answer) {
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
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Error de Conexión',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'No se pudo enviar tu respuesta al servidor. Verifica tu conexión a internet e intenta nuevamente.',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Volver al ejercicio sin hacer nada
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // ✅ RESETEAR SELECCIÓN Y PERMITIR NUEVA RESPUESTA
                    _resetExerciseSelection();
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
                    'Elegir otra respuesta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO MEJORADO PARA RESETEAR LA SELECCIÓN DEL EJERCICIO
  void _resetExerciseSelection() {
    print('🔄 Reseteando selección del ejercicio...');
    
    // ✅ GENERAR NUEVA KEY PARA FORZAR RECONSTRUCCIÓN COMPLETA DEL WIDGET
    setState(() {
      _exerciseKey = UniqueKey();
    });
    
    print('✅ Selección reseteada - Widget de ejercicio reconstruido con nueva key');
  }

  // ✅ NUEVO MÉTODO PARA MOSTRAR ERRORES GENERALES
  void _showErrorDialog(String message) {
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
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
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
            message,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO CORREGIDO PARA MOSTRAR RESULTADO
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
              onPressed: () {
                // ✅ CERRAR EL DIALOG PRIMERO
                Navigator.of(context).pop();
                
                if (isCorrect) {
                  // ✅ Respuesta correcta - Avanzar al siguiente ejercicio
                  print('✅ Respuesta correcta - Avanzando al siguiente ejercicio');
                  _nextExercise();
                } else {
                  // ✅ Respuesta incorrecta - Reseteando selección para intentar de nuevo
                  print('⚠️ Respuesta incorrecta - Reseteando selección para nuevo intento');
                  _resetExerciseSelection();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? const Color(0xFFD4A574) : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCorrect ? 'Continuar' : 'Elegir otra respuesta',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO CORREGIDO PARA AVANZAR AL SIGUIENTE EJERCICIO
  void _nextExercise() {
    // ✅ NO CERRAR DIALOG AQUÍ - YA SE CERRÓ EN _showResult()
    
    // ✅ SOLO AVANZAR SI LA ÚLTIMA RESPUESTA FUE CORRECTA
    if (_results.isNotEmpty) {
      final lastResult = _results.last;
      if (!lastResult.isCorrect) {
        print('⚠️ Respuesta incorrecta - No se avanza al siguiente ejercicio');
        return;
      }
    }
    
    // ✅ DEBUGGING DE TRANSICIÓN
    _debugExerciseTransition();
    
    // ✅ AVANZAR AL SIGUIENTE EJERCICIO
    if (_currentExerciseIndex < _lesson!.ejercicios.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _exerciseKey = UniqueKey(); // ✅ RESETEAR KEY PARA NUEVO EJERCICIO
      });
      print('📊 Avanzando al siguiente ejercicio: $_currentExerciseIndex');
      
      // ✅ OPTIONAL: MOSTRAR FEEDBACK DE PROGRESO
      final progressPercentage = ((_currentExerciseIndex + 1) / _lesson!.ejercicios.length) * 100;
      print('📊 Progreso del ejercicio: ${progressPercentage.toStringAsFixed(1)}%');
      
    } else {
      // ✅ ÚLTIMO EJERCICIO COMPLETADO - FINALIZAR LECCIÓN
      print('🎉 Último ejercicio completado - Finalizando lección');
      _finishLesson();
    }
  }

  void _finishLesson() async {
    final score = _service.calculateScore(_results);
    
    // ✅ ACTUALIZAR PROGRESO FINAL
    final finalProgress = LessonProgressModel(
      lessonId: widget.lessonId,
      results: _results,
      completionPercentage: 100.0,
      isCompleted: true,
      score: score,
    );

    try {
      // ✅ GUARDAR PROGRESO FINAL
      await _service.saveProgress(finalProgress);
      
      // ✅ ACTUALIZAR PROGRESO LOCAL
      setState(() {
        _progress = finalProgress;
      });
      
      // ✅ ACTUALIZAR PROGRESO GLOBAL Y DESBLOQUEAR SIGUIENTE LECCIÓN
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      if (userId != null && userId.toString().isNotEmpty) {
        // Llama al método global de LessonService
        await LessonService().updateLessonProgressForUser(
          userId: userId,
          lessonId: widget.lessonId,
          progress: 1.0,
        );
      }
      
      print('🎉 Lección completada con éxito - Puntuación: $score%');
      
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

  // ✅ MÉTODO PARA DEBUG DEL FLUJO DE RESPUESTAS
  void _debugResponseFlow(dynamic answer, bool isCorrect) {
    print('🔍 === DEBUG FLUJO DE RESPUESTA ===');
    print('📤 Respuesta del usuario: $answer');
    print('✅ Es correcta: $isCorrect');
    print('📊 Ejercicio actual: $_currentExerciseIndex');
    print('📊 Total resultados hasta ahora: ${_results.length}');
    print('📊 Progreso actual: ${_progress?.completionPercentage ?? 0}%');
    
    if (isCorrect) {
      print('➡️ FLUJO: Respuesta correcta → Enviar al servidor → Actualizar progreso → Siguiente ejercicio');
    } else {
      print('➡️ FLUJO: Respuesta incorrecta → NO enviar al servidor → Resetear selección → Intentar otra vez');
    }
    print('🔍 === FIN DEBUG ===');
  }

  // ✅ MÉTODO ADICIONAL PARA DEBUGGING - VERIFICAR ESTADO ANTES DE AVANZAR
  void _debugExerciseTransition() {
    print('🔍 === DEBUG TRANSICIÓN DE EJERCICIO ===');
    print('📊 Ejercicio actual: $_currentExerciseIndex');
    print('📊 Total ejercicios: ${_lesson!.ejercicios.length}');
    print('📊 Resultados totales: ${_results.length}');
    
    if (_results.isNotEmpty) {
      final lastResult = _results.last;
      print('📊 Última respuesta correcta: ${lastResult.isCorrect}');
      print('📊 Índice último resultado: ${lastResult.exerciseIndex}');
    }
    
    print('📊 ¿Puede avanzar?: ${_currentExerciseIndex < _lesson!.ejercicios.length - 1}');
    print('🔍 === FIN DEBUG ===');
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

  // ✅ HEADER MEJORADO CON BARRA DE PROGRESO ANIMADA
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
              // ✅ BOTÓN DE REFRESCAR PROGRESO
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _refreshProgress,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refrescar progreso',
                ),
              ),
            ],
          ),
          // ✅ INDICADOR DE PROGRESO MEJORADO Y ACTUALIZADO
          if (_progress != null) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_progress!.completionPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // ✅ INDICADOR VISUAL DEL ESTADO
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getProgressColor(_progress!.completionPercentage),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getProgressColor(_progress!.completionPercentage).withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ✅ BARRA DE PROGRESO ANIMADA
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      width: MediaQuery.of(context).size.width * (_progress!.completionPercentage / 100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getProgressColor(_progress!.completionPercentage),
                            _getProgressColor(_progress!.completionPercentage).withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ejercicio ${_currentExerciseIndex + 1} de ${_lesson!.ejercicios.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    if (_progress!.results.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_progress!.results.where((r) => r.isCorrect).length} correctos',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // ✅ INDICADOR DE ESTADO DE COMPLETADO MEJORADO
                if (_progress!.isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Lección Completada - ${_progress!.score}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_progress!.completionPercentage > 0) ...[
                  // ✅ INDICADOR DE PROGRESO PARCIAL
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getProgressColor(_progress!.completionPercentage).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getProgressColor(_progress!.completionPercentage).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: _getProgressColor(_progress!.completionPercentage),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'En progreso',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getProgressColor(_progress!.completionPercentage),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
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
          key: _exerciseKey, // ✅ USAR KEY PARA FORZAR RECONSTRUCCIÓN
          exercise: exercise,
          currentIndex: _currentExerciseIndex,
          totalExercises: _lesson!.ejercicios.length,
          onAnswerSelected: _submitAnswer,
          isSubmitting: _isSubmittingAnswer,
        );
        
      case 'completar':
        return CompletionExerciseScreen(
          key: _exerciseKey, // ✅ USAR KEY PARA FORZAR RECONSTRUCCIÓN
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