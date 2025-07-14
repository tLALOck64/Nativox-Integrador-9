// core/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? height;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      height: (height ?? 70) + bottomPadding,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = currentIndex == index;
              
              return Expanded(
                child: _NavBarItemWidget(
                  item: item,
                  isActive: isActive,
                  activeColor: activeColor ?? const Color(0xFFD4A574),
                  inactiveColor: inactiveColor ?? const Color(0xFF888888),
                  onTap: () => onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================
// MODELO PARA ITEMS DEL NAVBAR
// ============================================

class NavBarItem {
  final IconData icon;
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
// WIDGET INTERNO PARA CADA ITEM - CORREGIDO
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
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive 
                      ? activeColor.withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// CONFIGURACIONES PREDEFINIDAS - CORREGIDAS
// ============================================

class NavBarConfigs {
  // Configuración para la app Yoloxóchitl
  static List<NavBarItem> get yoloxochitlItems => [
    const NavBarItem(
      icon: Icons.home_outlined,
      label: 'Inicio',
      route: '/home',
    ),
    const NavBarItem(
      icon: Icons.menu_book_outlined,
      label: 'Lecciones',
      route: '/lessons',
    ),
    const NavBarItem(
      icon: Icons.sports_esports_outlined,
      label: 'Práctica',
      route: '/practice',
    ),
    const NavBarItem(
      icon: Icons.person_outline,
      label: 'Perfil',
      route: '/profile',
    ),
  ];

  // Colores predefinidos
  static const Color primaryColor = Color(0xFFD4A574);
  static const Color secondaryColor = Color(0xFFB8956A);
  static const Color inactiveColor = Color(0xFF888888);
}

// ============================================
// VERSIÓN SIMPLIFICADA Y OPTIMIZADA - CORREGIDA
// ============================================

class SimpleBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SimpleBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Inicio'},
      {'icon': Icons.menu_book_outlined, 'label': 'Lecciones'},
      {'icon': Icons.sports_esports_outlined, 'label': 'Práctica'},
      {'icon': Icons.person_outline, 'label': 'Perfil'},
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = currentIndex == index;
              
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 56,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: isActive 
                              ? const Color(0xFFD4A574) 
                              : const Color(0xFF888888),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive 
                                ? const Color(0xFFD4A574) 
                                : const Color(0xFF888888),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}