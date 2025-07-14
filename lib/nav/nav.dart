// core/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = currentIndex == index;
          
          return _NavBarItemWidget(
            item: item,
            isActive: isActive,
            activeColor: activeColor ?? const Color(0xFFD4A574),
            inactiveColor: inactiveColor ?? const Color(0xFF888888),
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================
// MODELO PARA ITEMS DEL NAVBAR
// ============================================

class NavBarItem {
  final String icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const NavBarItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });
}

// ============================================
// WIDGET INTERNO PARA CADA ITEM
// ============================================

class _NavBarItemWidget extends StatelessWidget {
  final NavBarItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? activeColor.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con animación de escala
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  item.icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Label con animación de color
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// CONFIGURACIONES PREDEFINIDAS
// ============================================

class NavBarConfigs {
  // Configuración para la app Yoloxóchitl
  static List<NavBarItem> get yoloxochitlItems => [
    const NavBarItem(
      icon: '🏠',
      label: 'Inicio',
      route: '/home',
    ),
    const NavBarItem(
      icon: '📚',
      label: 'Lecciones',
      route: '/lessons',
    ),
    const NavBarItem(
      icon: '🎯',
      label: 'Práctica',
      route: '/practice',
    ),
    const NavBarItem(
      icon: '👤',
      label: 'Perfil',
      route: '/profile',
    ),
  ];

  // Configuración alternativa con diferentes iconos
  static List<NavBarItem> get alternativeItems => [
    const NavBarItem(
      icon: '🌟',
      label: 'Inicio',
      route: '/home',
    ),
    const NavBarItem(
      icon: '📖',
      label: 'Estudiar',
      route: '/study',
    ),
    const NavBarItem(
      icon: '🏆',
      label: 'Logros',
      route: '/achievements',
    ),
    const NavBarItem(
      icon: '⚙️',
      label: 'Ajustes',
      route: '/settings',
    ),
  ];

  // Colores predefinidos
  static const Color primaryColor = Color(0xFFD4A574);
  static const Color secondaryColor = Color(0xFFB8956A);
  static const Color inactiveColor = Color(0xFF888888);
}

// ============================================
// VERSIÓN CON NAVEGACIÓN AUTOMÁTICA
// ============================================

class SmartBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<NavBarItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final bool useRouteNavigation;

  const SmartBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height = 80,
    this.useRouteNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      items: items,
      backgroundColor: backgroundColor,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      height: height,
      onTap: (index) => _handleNavigation(context, index),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return; // Ya estamos en esa pantalla

    final item = items[index];
    
    if (useRouteNavigation && item.route != null) {
      // Navegar usando rutas
      Navigator.of(context).pushReplacementNamed(item.route!);
    } else if (item.onTap != null) {
      // Usar callback personalizado
      item.onTap!();
    }
  }
}

// ============================================
// VERSIÓN CON NOTIFICACIONES (BADGES)
// ============================================

class BadgeNavBarItem extends NavBarItem {
  final int? badgeCount;
  final bool showBadge;
  final Color badgeColor;

  const BadgeNavBarItem({
    required super.icon,
    required super.label,
    super.route,
    super.onTap,
    this.badgeCount,
    this.showBadge = false,
    this.badgeColor = Colors.red,
  });
}

class BadgeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BadgeNavBarItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const BadgeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = currentIndex == index;
          
          return _BadgeNavItemWidget(
            item: item,
            isActive: isActive,
            activeColor: activeColor ?? const Color(0xFFD4A574),
            inactiveColor: inactiveColor ?? const Color(0xFF888888),
            onTap: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }
}

class _BadgeNavItemWidget extends StatelessWidget {
  final BadgeNavBarItem item;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _BadgeNavItemWidget({
    required this.item,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? activeColor.withOpacity(0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con badge
              Stack(
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      item.icon,
                      style: TextStyle(
                        fontSize: 20,
                        color: isActive ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                  // Badge
                  if (item.showBadge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: item.badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          item.badgeCount != null && item.badgeCount! > 0 
                              ? item.badgeCount.toString() 
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// EJEMPLOS DE USO
// ============================================

/*
// 1. USO BÁSICO
CustomBottomNavBar(
  currentIndex: _currentIndex,
  items: NavBarConfigs.yoloxochitlItems,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
)

// 2. USO CON NAVEGACIÓN AUTOMÁTICA
SmartBottomNavBar(
  currentIndex: _currentIndex,
  items: NavBarConfigs.yoloxochitlItems,
)

// 3. USO CON BADGES
BadgeBottomNavBar(
  currentIndex: _currentIndex,
  items: [
    BadgeNavBarItem(
      icon: '🏠',
      label: 'Inicio',
      route: '/home',
    ),
    BadgeNavBarItem(
      icon: '📚',
      label: 'Lecciones',
      route: '/lessons',
      showBadge: true,
      badgeCount: 3,
    ),
    BadgeNavBarItem(
      icon: '👤',
      label: 'Perfil',
      route: '/profile',
      showBadge: true,
    ),
  ],
  onTap: (index) => _handleNavigation(index),
)

// 4. USO PERSONALIZADO
CustomBottomNavBar(
  currentIndex: _currentIndex,
  items: [
    NavBarItem(
      icon: '🌟',
      label: 'Custom',
      onTap: () => print('Custom action'),
    ),
  ],
  backgroundColor: Colors.blue[50],
  activeColor: Colors.blue,
  inactiveColor: Colors.grey,
  height: 90,
  onTap: (index) => _customHandler(index),
)
*/