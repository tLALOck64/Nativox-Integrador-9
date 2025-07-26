import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/lesson_detail_model.dart';

class CompletionExerciseScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final int currentIndex;
  final int totalExercises;
  final Function(dynamic answer) onAnswerSelected;
  final bool isSubmitting;

  const CompletionExerciseScreen({
    super.key,
    required this.exercise,
    required this.currentIndex,
    required this.totalExercises,
    required this.onAnswerSelected,
    required this.isSubmitting,
  });

  @override
  State<CompletionExerciseScreen> createState() => _CompletionExerciseScreenState();
}

class _CompletionExerciseScreenState extends State<CompletionExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  String? _selectedAnswer;
  List<String> _shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shuffledOptions = List.from(widget.exercise.contenido.opciones)..shuffle();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    if (widget.isSubmitting) return;
    
    setState(() {
      _selectedAnswer = answer;
    });

    _pulseController.stop();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onAnswerSelected(answer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de ejercicio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF50C878), Color(0xFF228B22)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'COMPLETAR FRASE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progreso
            _buildProgressIndicator(),

            const SizedBox(height: 32),

            // Imagen si existe
            if (widget.exercise.contenido.imagenes.isNotEmpty)
              _buildExerciseImage(),

            const SizedBox(height: 24),

            // Instrucción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF50C878).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF50C878).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF50C878),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selecciona la palabra correcta para completar la frase',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF50C878),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Frase con espacio en blanco
            _buildCompletionSentence(),

            const SizedBox(height: 32),

            // Opciones como chips
            _buildWordOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (widget.currentIndex + 1) / widget.totalExercises;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completar ${widget.currentIndex + 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              '${widget.currentIndex + 1} de ${widget.totalExercises}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFF50C878), Color(0xFF228B22)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: widget.exercise.contenido.imagenes.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF50C878)),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported, 
                           color: Colors.grey, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionSentence() {
    // Parsear la frase para encontrar el espacio en blanco
    final sentence = widget.exercise.enunciado;
    final parts = sentence.split('______');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
            height: 1.5,
          ),
          children: [
            if (parts.isNotEmpty) TextSpan(text: parts[0]),
            WidgetSpan(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _selectedAnswer != null ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 100),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedAnswer != null 
                          ? const Color(0xFF50C878).withOpacity(0.2)
                          : const Color(0xFF50C878).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF50C878),
                          width: _selectedAnswer != null ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        _selectedAnswer ?? '______',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedAnswer != null 
                            ? const Color(0xFF50C878)
                            : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      ),
    );
  }

  Widget _buildWordOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la palabra correcta:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _shuffledOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == option;
            final isDisabled = widget.isSubmitting || _selectedAnswer != null;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 150)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: isDisabled ? null : () => _selectAnswer(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF50C878), Color(0xFF228B22)],
                        )
                      : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.transparent
                        : const Color(0xFF50C878),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                          ? const Color(0xFF50C878).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF50C878),
                        ),
                      ),
                      if (widget.isSubmitting && isSelected) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}