// lib/core/widgets/notification_badge_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/services/notifications_service.dart';

class NotificationBadgeWidget extends StatefulWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final VoidCallback? onTap;
  final bool showCount;
  
  const NotificationBadgeWidget({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
    this.onTap,
    this.showCount = true,
  });

  @override
  State<NotificationBadgeWidget> createState() => _NotificationBadgeWidgetState();
}

class _NotificationBadgeWidgetState extends State<NotificationBadgeWidget> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (_isLoading) return;
    
    try {
      setState(() => _isLoading = true);
      
      final count = await _notificationService.getUnreadCount();
      
      if (mounted) {
        setState(() {
          _unreadCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading unread count: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Navegación por defecto a la pantalla de notificaciones
      context.push('/notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_rounded,
              color: widget.iconColor ?? Colors.grey[600],
              size: widget.iconSize,
            ),
            
            // Badge de contador
            if (_unreadCount > 0 && widget.showCount)
              Positioned(
                top: -4,
                right: -4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: widget.badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.badgeColor ?? Colors.red).withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            
            // Indicador de carga
            if (_isLoading)
              Positioned(
                top: -2,
                right: -2,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.badgeColor ?? Colors.blue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método público para refrescar el contador
  Future<void> refresh() async {
    await _loadUnreadCount();
  }
}

// ============================================
// WIDGET SIMPLIFICADO PARA USAR EN APP BAR
// ============================================

class AppBarNotificationIcon extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback? onTap;
  
  const AppBarNotificationIcon({
    super.key,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: NotificationBadgeWidget(
        iconColor: iconColor ?? Colors.white,
        badgeColor: Colors.red,
        iconSize: 24,
        onTap: onTap,
      ),
    );
  }
}

// ============================================
// WIDGET PARA USAR EN BOTTOM NAVIGATION
// ============================================

class BottomNavNotificationIcon extends StatelessWidget {
  final Color? iconColor;
  final Color? activeColor;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const BottomNavNotificationIcon({
    super.key,
    this.iconColor,
    this.activeColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadgeWidget(
      iconColor: isSelected 
          ? (activeColor ?? const Color(0xFFD4A574))
          : (iconColor ?? Colors.grey[600]),
      badgeColor: Colors.red,
      iconSize: 26,
      onTap: onTap,
    );
  }
}

// ============================================
// WIDGET FLOATING ACTION BUTTON CON NOTIFICACIONES
// ============================================

class NotificationFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const NotificationFloatingButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: onPressed ?? () => context.push('/notifications'),
          backgroundColor: backgroundColor ?? const Color(0xFFD4A574),
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 8,
          child: const Icon(Icons.notifications_rounded),
        ),
        
        // Badge en la esquina
        Positioned(
          top: -4,
          right: -4,
          child: FutureBuilder<int>(
            future: NotificationService().getUnreadCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              
              return Container(
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}