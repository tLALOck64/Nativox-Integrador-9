import 'package:flutter/material.dart';
import 'package:integrador/games/lecciones/lesson_model.dart';

class LessonCardWidget extends StatefulWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;
  final bool shouldAnimate;

  const LessonCardWidget({
    super.key,
    required this.lesson,
    this.onTap,
    this.shouldAnimate = false,
  });

  @override
  State<LessonCardWidget> createState() => _LessonCardWidgetState();
}

class _LessonCardWidgetState extends State<LessonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.shouldAnimate) {
      _pulseController.repeat(reverse: true);
    }
  }

  // Validación del progreso para asegurar que esté entre 0.0 y 1.0
  double get validatedProgress => widget.lesson.progress.clamp(0.0, 1.0);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return AnimatedBuilder(
        animation: widget.shouldAnimate ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Opacity(
            // Aseguramos que la opacidad esté siempre en rango válido y nunca sea NaN
            opacity: widget.shouldAnimate
                ? (_pulseAnimation.value.isNaN ? 1.0 : _pulseAnimation.value.clamp(0.0, 1.0))
                : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: widget.lesson.isLocked 
                      ? Border.all(color: Colors.grey.withOpacity(0.3))
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.lesson.isLocked ? null : widget.onTap,
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    child: Stack(
                      children: [
                        // Progress indicator line at top
                        if (validatedProgress > 0)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              width: double.infinity,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: validatedProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: widget.lesson.isLocked
                                      ? LinearGradient(
                                          colors: [
                                            Colors.grey.withOpacity(0.5),
                                            Colors.grey.withOpacity(0.3),
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                        ),
                                ),
                                child: Center(
                                  child: widget.lesson.isLocked
                                      ? const Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : Text(
                                          widget.lesson.icon,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 15),
                              
                              // Title
                              Text(
                                widget.lesson.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.lesson.isLocked 
                                      ? Colors.grey 
                                      : const Color(0xFF2C2C2C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Subtitle
                              Text(
                                widget.lesson.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.lesson.isLocked 
                                      ? Colors.grey.withOpacity(0.7)
                                      : const Color(0xFF888888),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 15),
                              
                              // Progress bar
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: validatedProgress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: widget.lesson.isLocked
                                          ? LinearGradient(
                                              colors: [
                                                Colors.grey.withOpacity(0.5),
                                                Colors.grey.withOpacity(0.3),
                                              ],
                                            )
                                          : const LinearGradient(
                                              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                            ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Completion indicator
                              if (widget.lesson.isCompleted)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error rendering LessonCard: $e');
      // Widget de respaldo en caso de error
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
         
            )
          ],
        ),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }
  }
}