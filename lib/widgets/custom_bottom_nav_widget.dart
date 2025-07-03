import 'package:flutter/material.dart';

class CustomBottomNavWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavWidget> createState() => _CustomBottomNavWidgetState();
}

class _CustomBottomNavWidgetState extends State<CustomBottomNavWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  final List<NavItem> _navItems = [
    NavItem(icon: '🏠', label: 'Inicio'),
    NavItem(icon: '📚', label: 'Lecciones'),
    NavItem(icon: '🎯', label: 'Práctica'),
    NavItem(icon: '👤', label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.2,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            )))
        .toList();

    // Animar el item seleccionado inicialmente
    _controllers[widget.selectedIndex].forward();
  }

  @override
  void didUpdateWidget(CustomBottomNavWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Animar hacia atrás el item anterior
      _controllers[oldWidget.selectedIndex].reverse();
      // Animar hacia adelante el nuevo item
      _controllers[widget.selectedIndex].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = widget.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onItemTapped(index);
          // Crear efecto de rebote
          _controllers[index].forward().then((_) {
            _controllers[index].reverse();
          });
        },
        child: AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container con animación
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4A574).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimations[index].value,
                      child: Text(
                        item.icon,
                        style: TextStyle(
                          fontSize: isSelected ? 22 : 20,
                          color: isSelected 
                              ? const Color(0xFFD4A574)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Label con animación de color
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFD4A574)
                          : const Color(0xFF888888),
                    ),
                    child: Text(item.label),
                  ),
                  
                  // Indicador de selección
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 4),
                    height: 2,
                    width: isSelected ? 20 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavItem {
  final String icon;
  final String label;

  NavItem({
    required this.icon,
    required this.label,
  });
}