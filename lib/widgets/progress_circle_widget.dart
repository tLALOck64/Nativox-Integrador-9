import 'package:flutter/material.dart';

class ProgressCircleWidget extends StatefulWidget {
  final double progress;
  final String percentage;
  final String level;
  final double size;
  final Color progressColor;
  final Color backgroundColor;

  const ProgressCircleWidget({
    super.key,
    required this.progress,
    required this.percentage,
    required this.level,
    this.size = 120,
    this.progressColor = const Color(0xFFD4A574),
    this.backgroundColor = const Color(0xFFF0F0F0),
  });

  @override
  State<ProgressCircleWidget> createState() => _ProgressCircleWidgetState();
}

class _ProgressCircleWidgetState extends State<ProgressCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Validación del progreso para asegurar que esté entre 0.0 y 1.0
  double get validatedProgress => widget.progress.clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: validatedProgress, // Usamos el progreso validado
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressCircleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress.clamp(0.0, 1.0), // Validamos el valor inicial
        end: validatedProgress, // Usamos el progreso validado
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
            ),
          ),
          
          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 10,
                  backgroundColor: widget.backgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
                ),
              );
            },
          ),
          
          // Inner content
          Container(
            width: widget.size - 20,
            height: widget.size - 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    // Aseguramos que el porcentaje no exceda 100%
                    final percentageValue = (_progressAnimation.value * 100).toInt();
                    return Text(
                      '${percentageValue.clamp(0, 100)}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.26,
                        fontWeight: FontWeight.w700,
                        color: widget.progressColor,
                      ),
                    );
                  },
                ),
                Text(
                  widget.level,
                  style: TextStyle(
                    fontSize: widget.size * 0.1,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}