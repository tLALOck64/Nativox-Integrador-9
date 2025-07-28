import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'memorama_game.dart';

class MemoramaMenuScreen extends StatelessWidget {
  const MemoramaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/practice'),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFD4A574),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Memorama Zapoteco',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Para balancear el botón atrás
                  ],
                ),
                
                const SizedBox(height: 32),
                
                const SizedBox(height: 32),
                
                // Título de dificultades
                const Text(
                  'Selecciona la dificultad',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Opciones de dificultad
                Expanded(
                  child: ListView(
                    children: [
                      _buildDifficultyCard(
                        context,
                        title: 'Fácil',
                        subtitle: '4 pares • 8 cartas',
                        description: 'Perfecto para principiantes',
                        icon: '🌱',
                        color: Colors.green,
                        difficulty: 'Fácil',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDifficultyCard(
                        context,
                        title: 'Medio',
                        subtitle: '6 pares • 12 cartas',
                        description: 'Un desafío equilibrado',
                        icon: '🌿',
                        color: Colors.orange,
                        difficulty: 'Medio',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDifficultyCard(
                        context,
                        title: 'Difícil',
                        subtitle: '8 pares • 16 cartas',
                        description: 'Para expertos en memoria',
                        icon: '🌳',
                        color: Colors.red,
                        difficulty: 'Difícil',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String icon,
    required Color color,
    required String difficulty,
  }) {
    return GestureDetector(
      onTap: () => _startGame(context, difficulty),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icono de dificultad
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información de la dificultad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Flecha
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String difficulty) {
    // Navegar a la pantalla del juego
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoramaGameScreen(difficulty: difficulty),
      ),
    );
  }
}