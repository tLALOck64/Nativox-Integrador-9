import 'package:flutter/material.dart';

class CustomFloatingButtonWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final String icon;
  final String? tooltip;
  final bool isVisible;

  const CustomFloatingButtonWidget({
    super.key,
    this.onPressed,
    this.icon = '▶️',
    this.tooltip,
    this.isVisible = true,
  });

  @override
  State<CustomFloatingButtonWidget> createState() => _CustomFloatingButtonWidgetState();
}

class _CustomFloatingButtonWidgetState extends State<CustomFloatingButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _visibilityController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Controlador para el efecto de pulso
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Controlador para el efecto de escala al presionar
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Controlador para visibilidad
    _visibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animaciones
    _pulseController.repeat(reverse: true);
    
    if (widget.isVisible) {
      _visibilityController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomFloatingButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _visibilityController.forward();
      } else {
        _visibilityController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _visibilityController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Transform.scale(
            scale: _slideAnimation.value * _scaleAnimation.value,
            child: Opacity(
              opacity: _slideAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A574).withOpacity(0.4),
                      blurRadius: 25 * _pulseAnimation.value,
                      spreadRadius: 2 * _pulseAnimation.value,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onPressed,
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          transform: Matrix4.rotationZ(_isPressed ? 0.1 : 0.0),
                          child: Text(
                            widget.icon,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
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