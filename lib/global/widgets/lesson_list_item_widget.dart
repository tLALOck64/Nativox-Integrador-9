import 'package:flutter/material.dart';
import 'package:integrador/games/lecciones/lesson_model.dart';

class LessonListItemWidget extends StatefulWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;

  const LessonListItemWidget({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  State<LessonListItemWidget> createState() => _LessonListItemWidgetState();
}

class _LessonListItemWidgetState extends State<LessonListItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.lesson.isLocked) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  Color _getLessonNumberColor() {
    if (widget.lesson.isCompleted) {
      return const Color(0xFF4CAF50);
    } else if (widget.lesson.isLocked) {
      return const Color(0xFFE0E0E0);
    } else {
      return const Color(0xFFD4A574);
    }
  }

  Color _getLessonNumberTextColor() {
    if (widget.lesson.isLocked) {
      return const Color(0xFF999999);
    } else {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: widget.lesson.isCompleted
                  ? const Color(0xFFD4A574).withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: widget.lesson.isCompleted
                    ? const Color(0xFFD4A574).withOpacity(0.2)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.lesson.isLocked ? null : widget.onTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Stack(
                  children: [
                    // Progress indicator line at top
                    if (widget.lesson.progress > 0 && !widget.lesson.isCompleted)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          width: double.infinity,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.lesson.progress,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Main content
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Row(
                        children: [
                          // Lesson Number
                          Container(
                            width: isSmallScreen ? 40 : 48,
                            height: isSmallScreen ? 40 : 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.lesson.isLocked
                                  ? null
                                  : LinearGradient(
                                      colors: widget.lesson.isCompleted
                                          ? [const Color(0xFF4CAF50), const Color(0xFF4CAF50)]
                                          : [const Color(0xFFD4A574), const Color(0xFFB8956A)],
                                    ),
                              color: widget.lesson.isLocked ? const Color(0xFFE0E0E0) : null,
                            ),
                            child: Center(
                              child: Text(
                                widget.lesson.lessonNumber.toString(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getLessonNumberTextColor(),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: isSmallScreen ? 12 : 15),
                          
                          // Lesson Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  widget.lesson.title,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: widget.lesson.isLocked
                                        ? Colors.grey
                                        : const Color(0xFF2C2C2C),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Meta (duration and word count) - Responsive
                                if (isSmallScreen)
                                  // Layout vertical para pantallas pequeñas
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.lesson.durationText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: widget.lesson.isLocked
                                              ? Colors.grey
                                              : const Color(0xFF888888),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.lesson.wordCountText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: widget.lesson.isLocked
                                              ? Colors.grey
                                              : const Color(0xFF888888),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  // Layout horizontal para pantallas normales
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.lesson.durationText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.lesson.isLocked
                                                ? Colors.grey
                                                : const Color(0xFF888888),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Flexible(
                                        child: Text(
                                          widget.lesson.wordCountText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.lesson.isLocked
                                                ? Colors.grey
                                                : const Color(0xFF888888),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                
                                const SizedBox(height: 8),
                                
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
                                    widthFactor: widget.lesson.progress.clamp(0.0, 1.0),
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
                              ],
                            ),
                          ),
                          
                          SizedBox(width: isSmallScreen ? 12 : 15),
                          
                          // Status Icon
                          Container(
                            width: isSmallScreen ? 28 : 32,
                            height: isSmallScreen ? 28 : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.lesson.isLocked
                                  ? Colors.grey.withOpacity(0.1)
                                  : widget.lesson.isCompleted
                                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                                      : const Color(0xFFD4A574).withOpacity(0.1),
                            ),
                            child: Center(
                              child: Text(
                                widget.lesson.statusIcon,
                                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Locked overlay
                    if (widget.lesson.isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}