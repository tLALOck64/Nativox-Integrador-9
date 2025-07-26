import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final String subtitle;
  final bool isLarge;

  const ProgressCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    required this.subtitle,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.only(bottom: isLarge ? 20 : 15),
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
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 24 : (isSmallScreen ? 16 : 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y valor - Mejorado para dispositivos pequeños
            if (isSmallScreen) ...[
              // Layout vertical para pantallas muy pequeñas
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4A574).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A574),
                  ),
                ),
              ),
            ] else ...[
              // Layout horizontal para pantallas normales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4A574).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: isLarge ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD4A574),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isLarge ? 20 : 15),
            
            // Barra de progreso
            Container(
              width: double.infinity,
              height: isLarge ? 12 : 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(isLarge ? 6 : 4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(isLarge ? 6 : 4),
                  ),
                ),
              ),
            ),
            SizedBox(height: isLarge ? 16 : 10),
            
            // Subtítulo con porcentaje - Mejorado para dispositivos pequeños
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isLarge ? 14 : (isSmallScreen ? 11 : 12),
                      color: const Color(0xFF888888),
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: isSmallScreen ? 2 : 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: isLarge ? 14 : (isSmallScreen ? 11 : 12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A574),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
