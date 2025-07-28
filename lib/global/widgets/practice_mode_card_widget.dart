import 'package:flutter/material.dart';
import '../models/practice_mode_model.dart';

class PracticeModeCardWidget extends StatefulWidget {
  final PracticeModeModel practiceMode;
  final VoidCallback? onTap;
  final bool shouldAnimate;

  const PracticeModeCardWidget({
    super.key,
    required this.practiceMode,
    this.onTap,
    this.shouldAnimate = false,
  });

  @override
  State<PracticeModeCardWidget> createState() => _PracticeModeCardWidgetState();
}

class _PracticeModeCardWidgetState extends State<PracticeModeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.shouldAnimate) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor() {
    switch (widget.practiceMode.difficulty) {
      case PracticeDifficulty.easy:
        return const Color(0x1A4CAF50);
      case PracticeDifficulty.medium:
        return const Color(0x1AFF9800);
      case PracticeDifficulty.hard:
        return const Color(0x1AF44336);
    }
  }

  Color _getDifficultyTextColor() {
    switch (widget.practiceMode.difficulty) {
      case PracticeDifficulty.easy:
        return const Color(0xFF4CAF50);
      case PracticeDifficulty.medium:
        return const Color(0xFFFF9800);
      case PracticeDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.shouldAnimate ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.shouldAnimate ? _pulseAnimation.value : 1.0,
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
                border: widget.practiceMode.isUnlocked 
                    ? null
                    : Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.practiceMode.isUnlocked ? widget.onTap : null,
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: Stack(
                    children: [
                      // Progress indicator line at top
                      if (widget.practiceMode.progress > 0)
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
                              widthFactor: widget.practiceMode.progress,
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
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: widget.practiceMode.isUnlocked
                                    ? const LinearGradient(
                                        colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.withOpacity(0.5),
                                          Colors.grey.withOpacity(0.3),
                                        ],
                                      ),
                              ),
                              child: Center(
                                child: widget.practiceMode.isUnlocked
                                    ? Text(
                                        widget.practiceMode.icon,
                                        style: const TextStyle(fontSize: 28),
                                      )
                                    : const Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // Title
                            Text(
                              widget.practiceMode.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.practiceMode.isUnlocked 
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Subtitle
                            Text(
                              widget.practiceMode.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.practiceMode.isUnlocked 
                                    ? const Color(0xFF888888)
                                    : Colors.grey.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // Difficulty badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.practiceMode.isUnlocked
                                    ? _getDifficultyColor()
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.practiceMode.difficultyText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.practiceMode.isUnlocked
                                      ? _getDifficultyTextColor()
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Sessions completed indicator
                      if (widget.practiceMode.completedSessions > 0)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A574),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.practiceMode.completedSessions}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
  }
}