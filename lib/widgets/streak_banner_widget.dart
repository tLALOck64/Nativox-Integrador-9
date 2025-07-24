import 'package:flutter/material.dart';

class StreakBannerWidget extends StatefulWidget {
  final int streakDays;
  final bool isActive;
  final VoidCallback? onTap;
  final int? totalDays;
  final bool showProgressBar;
  final int? nextMilestone;

  const StreakBannerWidget({
    super.key,
    required this.streakDays,
    this.isActive = true,
    this.onTap,
    this.totalDays,
    this.showProgressBar = true,
    this.nextMilestone,
  });

  @override
  State<StreakBannerWidget> createState() => _StreakBannerWidgetState();
}

class _StreakBannerWidgetState extends State<StreakBannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _progressAnimation;

  // PALETA DE COLORES CONSISTENTE - Basada en tonos tierra/ancestrales
  static const Color _primaryBrown = Color(0xFFB8860B); // Dorado ancestral base
  static const Color _lightBrown = Color(0xFFDEB887);   // Variante clara
  static const Color _mediumBrown = Color(0xFFCD853F);  // Variante media
  static const Color _darkBrown = Color(0xFF8B7355);    // Variante oscura
  static const Color _inactiveBrown = Color(0xFF9C8B7A); // Para estados inactivos

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    }
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01, // Reducido para ser más sutil
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6, // Reducido para ser menos intrusivo
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(StreakBannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
        _shimmerController.repeat();
      } else {
        _pulseController.stop();
        _shimmerController.stop();
        _pulseController.reset();
      }
    }
    
    if (widget.streakDays != oldWidget.streakDays) {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  StreakData _getStreakData() {
    if (!widget.isActive) {
      return StreakData(
        emoji: '💔',
        title: 'Racha perdida',
        subtitle: '¡Comienza de nuevo hoy!',
        color: _inactiveBrown,
        gradientColors: [
          _inactiveBrown.withOpacity(0.08),
          _inactiveBrown.withOpacity(0.03),
        ],
        backgroundColor: const Color(0xFFF5F4F2), // Fondo neutro consistente
      );
    }
    
    if (widget.streakDays == 1) {
      return StreakData(
        emoji: '🌟',
        title: '¡Primer día!',
        subtitle: 'El inicio de algo grande',
        color: _lightBrown,
        gradientColors: [
          _lightBrown.withOpacity(0.12),
          _lightBrown.withOpacity(0.04),
        ],
        backgroundColor: const Color(0xFFF8F6F3),
      );
    } else if (widget.streakDays < 7) {
      return StreakData(
        emoji: '🔥',
        title: 'Racha de ${widget.streakDays} días',
        subtitle: '¡Mantén el momentum!',
        color: _mediumBrown,
        gradientColors: [
          _mediumBrown.withOpacity(0.12),
          _mediumBrown.withOpacity(0.04),
        ],
        backgroundColor: const Color(0xFFF8F6F3),
      );
    } else if (widget.streakDays < 30) {
      return StreakData(
        emoji: '⚡',
        title: '${widget.streakDays} días seguidos',
        subtitle: '¡Estás en racha!',
        color: _primaryBrown,
        gradientColors: [
          _primaryBrown.withOpacity(0.12),
          _primaryBrown.withOpacity(0.04),
        ],
        backgroundColor: const Color(0xFFF8F6F3),
      );
    } else if (widget.streakDays < 100) {
      return StreakData(
        emoji: '👑',
        title: '${widget.streakDays} días',
        subtitle: '¡Eres una leyenda!',
        color: _darkBrown,
        gradientColors: [
          _darkBrown.withOpacity(0.12),
          _darkBrown.withOpacity(0.04),
        ],
        backgroundColor: const Color(0xFFF8F6F3),
      );
    } else {
      return StreakData(
        emoji: '🏆',
        title: '${widget.streakDays} días',
        subtitle: '¡Imparable y legendario!',
        color: _primaryBrown,
        gradientColors: [
          _primaryBrown.withOpacity(0.15),
          _primaryBrown.withOpacity(0.05),
        ],
        backgroundColor: const Color(0xFFF8F6F3),
      );
    }
  }

  double _getProgressValue() {
    if (!widget.isActive) return 0.0;
    
    final nextMilestone = widget.nextMilestone ?? _getNextMilestone();
    final previousMilestone = _getPreviousMilestone();
    
    if (widget.streakDays >= nextMilestone) return 1.0;
    
    final progress = (widget.streakDays - previousMilestone) / 
                    (nextMilestone - previousMilestone);
    return progress.clamp(0.0, 1.0);
  }

  int _getNextMilestone() {
    if (widget.streakDays < 7) return 7;
    if (widget.streakDays < 30) return 30;
    if (widget.streakDays < 100) return 100;
    if (widget.streakDays < 365) return 365;
    return ((widget.streakDays ~/ 100) + 1) * 100;
  }

  int _getPreviousMilestone() {
    if (widget.streakDays < 7) return 0;
    if (widget.streakDays < 30) return 7;
    if (widget.streakDays < 100) return 30;
    if (widget.streakDays < 365) return 100;
    return (widget.streakDays ~/ 100) * 100;
  }

  Widget _buildShimmerEffect({required Widget child}) {
    if (!widget.isActive) return child;
    
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }

  Widget _buildProgressBar(StreakData streakData) {
    if (!widget.showProgressBar || !widget.isActive) {
      return const SizedBox.shrink();
    }

    final progress = _getProgressValue();
    final nextMilestone = widget.nextMilestone ?? _getNextMilestone();

    return Column(
      children: [
        const SizedBox(height: 16), // Espaciado consistente
        Row(
          children: [
            Text(
              'Progreso hacia $nextMilestone días',
              style: TextStyle(
                fontSize: 12, // Ligeramente más grande para legibilidad
                color: streakData.color.withOpacity(0.75),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.streakDays}/$nextMilestone',
              style: TextStyle(
                fontSize: 12,
                color: streakData.color.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Espaciado consistente
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 8, // Ligeramente más alto para mejor visibilidad
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: streakData.color.withOpacity(0.15),
                border: Border.all(
                  color: streakData.color.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          streakData.color,
                          streakData.color.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(StreakData streakData) {
    if (!widget.isActive) return const SizedBox.shrink();
    
    bool showBadge = false;
    String badgeText = '';
    
    if (widget.streakDays >= 100) {
      showBadge = true;
      badgeText = 'ELITE';
    } else if (widget.streakDays >= 30) {
      showBadge = true;
      badgeText = 'PRO';
    } else if (widget.streakDays % 7 == 0 && widget.streakDays >= 7) {
      showBadge = true;
      badgeText = 'WEEK';
    }
    
    if (!showBadge) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            streakData.color,
            streakData.color.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: streakData.color.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streakData = _getStreakData();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // Fondo sólido más consistente con el diseño
              color: streakData.backgroundColor,
              borderRadius: BorderRadius.circular(20), // Radio más redondeado
              border: Border.all(
                color: streakData.color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                if (widget.isActive)
                  BoxShadow(
                    color: streakData.color.withOpacity(_glowAnimation.value * 0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                splashColor: streakData.color.withOpacity(0.1),
                highlightColor: streakData.color.withOpacity(0.05),
                child: _buildShimmerEffect(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Icono con mejor consistencia visual
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: streakData.color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: streakData.color.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  streakData.emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          streakData.title,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: streakData.color,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      _buildAchievementBadge(streakData),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    streakData.subtitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: streakData.color.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _buildProgressBar(streakData),
                        if (widget.totalDays != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: streakData.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: streakData.color.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              'Total de días activos: ${widget.totalDays}',
                              style: TextStyle(
                                fontSize: 13,
                                color: streakData.color.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class StreakData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradientColors;
  final Color backgroundColor; // Nuevo campo para consistencia

  StreakData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColors,
    required this.backgroundColor,
  });
}