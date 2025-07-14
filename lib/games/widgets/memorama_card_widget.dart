import 'package:flutter/material.dart';
import '../models/memorama_model.dart';

class MemoramaCardWidget extends StatefulWidget {
  final MemoramaCard card;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;

  const MemoramaCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  State<MemoramaCardWidget> createState() => _MemoramaCardWidgetState();
}

class _MemoramaCardWidgetState extends State<MemoramaCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Si la carta ya está revelada, mostrarla inmediatamente
    if (widget.card.isFlipped) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(MemoramaCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar cuando cambia el estado de la carta
    if (oldWidget.card.isFlipped != widget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: isShowingFront 
                ? _buildCardBack() 
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildCardFront(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.isSelected 
            ? Border.all(color: Colors.white, width: 3)
            : null,
      ),
      child: Stack(
        children: [
          // Patrón decorativo de fondo
          Positioned.fill(
            child: CustomPaint(
              painter: _CardPatternPainter(),
            ),
          ),
          // Logo o símbolo central
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🏛️',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(height: 8),
                Text(
                  'Nativox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    final isZapotecoCard = widget.card.id.contains('zapoteco');
    final displayText = isZapotecoCard 
        ? widget.card.zapotecoWord 
        : widget.card.spanishWord;
    
    Color cardColor;
    Color borderColor = Colors.transparent;
    
    switch (widget.card.state) {
      case CardState.matched:
        cardColor = Colors.green;
        break;
      case CardState.revealed:
        cardColor = Colors.green; // Verde para pares correctos
        break;
      case CardState.error:
        cardColor = Colors.red;
        borderColor = Colors.red.shade700;
        break;
      case CardState.flipped:
        // Estado neutral - color básico sin indicar correcto/incorrecto
        cardColor = isZapotecoCard ? const Color(0xFF4CAF50) : const Color(0xFF2196F3);
        break;
      default:
        cardColor = Colors.grey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: widget.card.state == CardState.error 
                ? Colors.red.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: widget.card.state == CardState.error ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.isSelected 
            ? Border.all(color: Colors.white, width: 3)
            : widget.card.state == CardState.error
                ? Border.all(color: borderColor, width: 2)
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji/Imagen con animación de error
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: widget.card.state == CardState.error 
                  ? (Matrix4.identity()..scale(1.1))
                  : Matrix4.identity(),
              child: Text(
                widget.card.imageUrl,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 12),
            
            // Texto principal
            Text(
              displayText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Indicador de idioma
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isZapotecoCard ? 'Zapoteco' : 'Español',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Dibujar un patrón geométrico simple
    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        path.moveTo(i, j);
        path.lineTo(i + step * 0.5, j + step * 0.5);
        path.moveTo(i + step, j);
        path.lineTo(i + step * 0.5, j + step * 0.5);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}