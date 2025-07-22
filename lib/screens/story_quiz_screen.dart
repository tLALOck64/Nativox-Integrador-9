import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/services/secure_storage_service.dart'
    as secure_storage;

class QuestionModel {
  final String id;
  final String storyId;
  final String question;
  final String answer;
  final String type;
  final String difficulty;
  final int points;
  final bool isActive;
  final List<String>? options;

  QuestionModel({
    required this.id,
    required this.storyId,
    required this.question,
    required this.answer,
    required this.type,
    required this.difficulty,
    required this.points,
    required this.isActive,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['ID'] ?? '',
      storyId: json['StoryID'] ?? '',
      question: json['Question'] ?? '',
      answer: json['Answer'] ?? '',
      type: json['Type'] ?? '',
      difficulty: json['Difficulty'] ?? '',
      points: json['Points'] ?? 0,
      isActive: json['IsActive'] ?? false,
      options: json['Options'] != null 
          ? List<String>.from(json['Options']) 
          : null,
    );
  }
}

class StoryQuizScreen extends StatefulWidget {
  final String storyId;
  final String storyTitle;
  
  const StoryQuizScreen({
    super.key, 
    required this.storyId,
    required this.storyTitle,
  });

  @override
  State<StoryQuizScreen> createState() => _StoryQuizScreenState();
}

class _StoryQuizScreenState extends State<StoryQuizScreen> {
  bool _isLoading = true;
  String? _error;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  int _score = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final storage = secure_storage.SecureStorageService();
      final token = await storage.getToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(
          'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-story/question/story/${widget.storyId}',
        ),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Success'] == true && data['Data'] is List) {
          _questions = (data['Data'] as List)
              .map((e) => QuestionModel.fromJson(e))
              .toList();
        } else {
          _error = 'No se pudieron cargar las preguntas.';
        }
      } else if (response.statusCode == 401) {
        _error = 'No autorizado. Inicia sesión nuevamente.';
      } else {
        _error = 'Error de red: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _completeQuiz() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].answer) {
        score += _questions[i].points;
      }
    }
    
    setState(() {
      _score = score;
      _quizCompleted = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _score = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8956A),
        foregroundColor: Colors.white,
        title: Text('Cuestionario: ${widget.storyTitle}'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFB8956A)),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8956A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _questions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Por el momento este cuento no contiene un cuestionario',
                                style: TextStyle(
                                  fontSize: isWide ? 20 : 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Vuelve más tarde para encontrar preguntas sobre esta historia.',
                                style: TextStyle(
                                  fontSize: isWide ? 16 : 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _quizCompleted
                        ? _buildQuizResults(isWide)
                        : _buildQuizContent(isWide),
      ),
    );
  }

  Widget _buildQuizContent(bool isWide) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB8956A),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Question counter
          Text(
            'Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}',
            style: TextStyle(
              fontSize: isWide ? 16 : 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question.question,
              style: TextStyle(
                fontSize: isWide ? 20 : 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB8956A),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Answer options
          if (question.type == 'multiple_choice' && question.options != null)
            ...question.options!.map((option) => _buildOptionButton(option, isWide))
          else
            _buildOpenEndedInput(isWide),
          
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: _previousQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Anterior'),
                )
              else
                const SizedBox(),
              
              ElevatedButton(
                onPressed: _userAnswers.containsKey(_currentQuestionIndex)
                    ? _nextQuestion
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8956A),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _currentQuestionIndex == _questions.length - 1
                      ? 'Finalizar'
                      : 'Siguiente',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, bool isWide) {
    final isSelected = _userAnswers[_currentQuestionIndex] == option;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _selectAnswer(option),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected 
                ? const Color(0xFFB8956A) 
                : Colors.white,
            foregroundColor: isSelected 
                ? Colors.white 
                : const Color(0xFFB8956A),
            side: BorderSide(
              color: const Color(0xFFB8956A),
              width: 2,
            ),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            option,
            style: TextStyle(
              fontSize: isWide ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenEndedInput(bool isWide) {
    return TextField(
      onChanged: (value) => _selectAnswer(value),
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta aquí...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB8956A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB8956A), width: 2),
        ),
      ),
      style: TextStyle(fontSize: isWide ? 16 : 14),
      maxLines: 3,
    );
  }

  Widget _buildQuizResults(bool isWide) {
    final totalPoints = _questions.fold(0, (sum, q) => sum + q.points);
    final percentage = ((_score / totalPoints) * 100).round();
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 16,
        vertical: 32,
      ),
      child: Column(
        children: [
          // Header con puntuación
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  percentage >= 70 ? Icons.celebration : Icons.sentiment_neutral,
                  size: 60,
                  color: percentage >= 70 
                      ? Colors.green 
                      : Colors.orange,
                ),
                const SizedBox(height: 16),
                
                Text(
                  '¡Cuestionario Completado!',
                  style: TextStyle(
                    fontSize: isWide ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB8956A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Tu puntuación: $_score de $totalPoints puntos',
                  style: TextStyle(
                    fontSize: isWide ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: isWide ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 70 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Título del resumen
          Text(
            'Resumen de Respuestas',
            style: TextStyle(
              fontSize: isWide ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB8956A),
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de preguntas con respuestas
          ...List.generate(
            _questions.length,
            (index) => _buildQuestionSummary(index, isWide),
          ),
          
          const SizedBox(height: 32),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8956A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Reintentar'),
              ),
              
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSummary(int index, bool isWide) {
    final question = _questions[index];
    final userAnswer = _userAnswers[index] ?? 'Sin respuesta';
    final correctAnswer = question.answer;
    final isCorrect = userAnswer == correctAnswer;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número de pregunta e ícono de resultado
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Pregunta ${index + 1}',
                style: TextStyle(
                  fontSize: isWide ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB8956A),
                ),
              ),
              const Spacer(),
              Text(
                '${question.points} pts',
                style: TextStyle(
                  fontSize: isWide ? 14 : 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Pregunta
          Text(
            question.question,
            style: TextStyle(
              fontSize: isWide ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          // Respuesta del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu respuesta:',
                  style: TextStyle(
                    fontSize: isWide ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userAnswer,
                  style: TextStyle(
                    fontSize: isWide ? 15 : 13,
                    fontWeight: FontWeight.w600,
                    color: isCorrect ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Respuesta correcta (solo si la respuesta del usuario es incorrecta)
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Respuesta correcta:',
                    style: TextStyle(
                      fontSize: isWide ? 14 : 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswer,
                    style: TextStyle(
                      fontSize: isWide ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}