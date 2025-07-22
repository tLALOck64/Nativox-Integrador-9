import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/lesson_detail_model.dart';

class SelectionExerciseScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final int currentIndex;
  final int totalExercises;
  final Function(dynamic answer) onAnswerSelected;
  final bool isSubmitting;

  const SelectionExerciseScreen({
    super.key,
    required this.exercise,
    required this.currentIndex,
    required this.totalExercises,
    required this.onAnswerSelected,
    required this.isSubmitting,
  });

  @override
  State<SelectionExerciseScreen> createState() => _SelectionExerciseScreenState();
}

class _SelectionExerciseScreenState extends State<SelectionExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (widget.isSubmitting) return;
    
    setState(() {
      _selectedAnswer = answer;
    });

    // Pequeña pausa para mostrar la selección
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onAnswerSelected(answer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de ejercicio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'SELECCIÓN MÚLTIPLE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progreso
            _buildProgressIndicator(),

            const SizedBox(height: 32),

            // Imagen si existe
            if (widget.exercise.contenido.imagenes.isNotEmpty)
              _buildExerciseImage(),

            const SizedBox(height: 24),

            // Pregunta
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.exercise.enunciado,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Opciones
            Expanded(
              child: _buildAnswerOptions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (widget.currentIndex + 1) / widget.totalExercises;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta ${widget.currentIndex + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              '${widget.currentIndex + 1} de ${widget.totalExercises}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: widget.exercise.contenido.imagenes.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported, 
                           color: Colors.grey, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.exercise.contenido.opciones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final option = widget.exercise.contenido.opciones[index];
        final isSelected = _selectedAnswer == option;
        final isDisabled = widget.isSubmitting || _selectedAnswer != null;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: isDisabled ? null : () => _selectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF4A90E2).withOpacity(0.1)
                  : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                    ? const Color(0xFF4A90E2)
                    : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? const Color(0xFF4A90E2).withOpacity(0.2)
                      : Colors.black.withOpacity(0.03),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                          ? const Color(0xFF4A90E2)
                          : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: isSelected 
                        ? const Color(0xFF4A90E2)
                        : Colors.transparent,
                    ),
                    child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected 
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  if (widget.isSubmitting && isSelected)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
