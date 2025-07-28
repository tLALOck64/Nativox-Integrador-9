import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/services/secure_storage_service.dart'
    as secure_storage;
import 'package:integrador/games/practicas/practice_screen.dart';
import 'package:integrador/games/cuentos/story_quiz_screen.dart';
import 'package:go_router/go_router.dart';

class StoryModel {
  final String id;
  final String title;
  final String description;
  final String language;
  final String category;

  StoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['ID'] ?? '',
      title: json['Title'] ?? '',
      description: json['Description'] ?? '',
      language: json['Language'] ?? '',
      category: json['Category'] ?? '',
    );
  }
}

class CuentosScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CuentosScreen({super.key, this.onBack});

  @override
  State<CuentosScreen> createState() => _CuentosScreenState();
}

class _CuentosScreenState extends State<CuentosScreen> {
  bool _isLoading = true;
  String? _error;
  List<StoryModel> _stories = [];

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  Future<void> _fetchStories() async {
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
          'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-story/story/',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Success'] == true && data['Data'] is List) {
          _stories =
              (data['Data'] as List)
                  .map((e) => StoryModel.fromJson(e))
                  .toList();
        } else {
          _error = 'No se pudieron cargar los cuentos.';
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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8956A),
        foregroundColor: Colors.white,
        title: const Text('Cuentos'),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Navegar a la pantalla de práctica
              context.go('/practice');
            },
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child:
            _isLoading
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
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchStories,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8956A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
                : _stories.isEmpty
                ? const Center(child: Text('No hay cuentos disponibles.'))
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 16,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lee y aprende cuentos en diferentes idiomas',
                        style: TextStyle(
                          fontSize: isWide ? 18 : 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(
                        _stories.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: GestureDetector(
                            onTap: () => _openStoryDetail(_stories[i].id),
                            child: _buildStoryCard(_stories[i], isWide),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  void _openStoryDetail(String storyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(storyId: storyId),
      ),
    );
  }

  Widget _buildStoryCard(StoryModel story, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFB8956A).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isWide ? 48 : 38,
            height: isWide ? 48 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFB8956A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: TextStyle(
                    fontSize: isWide ? 20 : 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB8956A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  story.description,
                  style: TextStyle(
                    fontSize: isWide ? 15 : 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBadge(story.category, const Color(0xFFD4A574)),
                    const SizedBox(width: 8),
                    _buildBadge(story.language, const Color(0xFF6B73FF)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

class StoryDetailScreen extends StatefulWidget {
  final String storyId;
  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _story;

  @override
  void initState() {
    super.initState();
    _fetchStory();
  }

  Future<void> _fetchStory() async {
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
          'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-story/story/${widget.storyId}',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Success'] == true && data['Data'] != null) {
          setState(() {
            _story = data['Data'];
            _isLoading = false;
          });
          return;
        } else {
          _error = 'No se pudo cargar el cuento.';
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

  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryQuizScreen(
          storyId: widget.storyId,
          storyTitle: _story!['Title'] ?? 'Cuento',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8956A),
        foregroundColor: Colors.white,
        title: const Text('Detalle del cuento'),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F3F0), Color(0xFFE8DDD4)],
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFB8956A)),
                  ),
                )
                : _error != null
                ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : _story == null
                ? const Center(child: Text('No se encontró el cuento.'))
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 16,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _story!['Title'] ?? '',
                        style: TextStyle(
                          fontSize: isWide ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB8956A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildBadge(
                            _story!['Category'] ?? '',
                            const Color(0xFFD4A574),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            _story!['Language'] ?? '',
                            const Color(0xFF6B73FF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _story!['Description'] ?? '',
                        style: TextStyle(
                          fontSize: isWide ? 18 : 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_story!['ContentJSON'] != null &&
                          _story!['ContentJSON']['parrafos'] is List)
                        ...List.generate(
                          (_story!['ContentJSON']['parrafos'] as List).length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Text(
                              _story!['ContentJSON']['parrafos'][i],
                              style: TextStyle(
                                fontSize: isWide ? 17 : 15,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      
                      // Botón para ir al cuestionario
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _openQuiz,
                          icon: const Icon(Icons.quiz),
                          label: const Text('Realizar Cuestionario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB8956A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}