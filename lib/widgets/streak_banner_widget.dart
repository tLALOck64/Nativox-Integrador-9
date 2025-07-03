import 'package:flutter/material.dart';

class StreakBannerWidget extends StatefulWidget {
  final int streakDays;
  final bool isActive;
  final VoidCallback? onTap;

  const StreakBannerWidget({
    super.key,
    required this.streakDays,
    this.isActive = true,
    this.onTap,
  });

  @override
  State<StreakBannerWidget> createState() => _StreakBannerWidgetState();
}

class _StreakBannerWidgetState extends State<StreakBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getStreakMessage() {
    if (!widget.isActive) {
      return '💔 Racha perdida • ¡Comienza de nuevo!';
    }
    
    if (widget.streakDays == 1) {
      return '🔥 ¡Primer día! • ¡Sigue así!';
    } else if (widget.streakDays < 7) {
      return '🔥 Racha de ${widget.streakDays} días • ¡Sigue así!';
    } else if (widget.streakDays < 30) {
      return '🔥 ¡${widget.streakDays} días seguidos! • ¡Increíble!';
    } else {
      return '🏆 ¡${widget.streakDays} días! • ¡Eres imparable!';
    }
  }

  Color _getStreakColor() {
    if (!widget.isActive) {
      return Colors.grey;
    }
    
    if (widget.streakDays < 7) {
      return const Color(0xFFD4A574);
    } else if (widget.streakDays < 30) {
      return Colors.orange;
    } else {
      return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStreakColor().withOpacity(0.1),
                  _getStreakColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _getStreakColor().withOpacity(0.2),
                width: 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: _getStreakColor().withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Streak icon with animation
                      if (widget.isActive)
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween(begin: 0.8, end: 1.2),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: const Text(
                                '🔥',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          },
                        )
                      else
                        const Text(
                          '💔',
                          style: TextStyle(fontSize: 18),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // Streak text
                      Expanded(
                        child: Text(
                          _getStreakMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStreakColor(),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      // Achievement indicator for milestones
                      if (widget.isActive && (widget.streakDays % 7 == 0 || widget.streakDays >= 30))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStreakColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.streakDays >= 30 ? '🏆' : '⭐',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
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