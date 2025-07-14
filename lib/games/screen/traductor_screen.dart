import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TraductorScreen extends StatefulWidget {
  const TraductorScreen({super.key});

  @override
  State<TraductorScreen> createState() => _TraductorScreenState();
}

class _TraductorScreenState extends State<TraductorScreen> 
    with SingleTickerProviderStateMixin {
  
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  
  // Language options
  final List<Language> _languages = [
    Language('Español', 'es', '🇪🇸'),
    Language('Tseltal', 'tseltal', '🌎'),
    Language('Zapoteco', 'zapoteco', '🌎'),
  ];
  
  Language _sourceLanguage = Language('Español', 'es', '🇪🇸');
  Language _targetLanguage = Language('Tseltal', 'tseltal', '🌎');
  
  String _translatedText = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_inputController.text.isNotEmpty) {
      _translateText();
    } else {
      setState(() {
        _translatedText = '';
        _hasError = false;
      });
      _animationController.reverse();
    }
  }

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final translation = await _performTranslation(text);
      
      setState(() {
        _translatedText = translation;
        _isLoading = false;
      });
      
      if (translation.isNotEmpty) {
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error al traducir: ${e.toString()}';
        _translatedText = '';
      });
      _animationController.reverse();
    }
  }

  Future<String> _performTranslation(String text) async {
    const baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/services-translator/traducir';
    
    // Determinar el endpoint según los idiomas seleccionados
    String endpoint = '';
    
    if (_sourceLanguage.code == 'es' && _targetLanguage.code == 'tseltal') {
      endpoint = '$baseUrl/tseltal-inverso?palabra=$text';
    } else if (_sourceLanguage.code == 'tseltal' && _targetLanguage.code == 'es') {
      endpoint = '$baseUrl/tseltal?palabra=$text';
    } else if (_sourceLanguage.code == 'es' && _targetLanguage.code == 'zapoteco') {
      endpoint = '$baseUrl/zapoteco-inverso?palabra=$text';
    } else if (_sourceLanguage.code == 'zapoteco' && _targetLanguage.code == 'es') {
      endpoint = '$baseUrl/zapoteco?palabra=$text';
    } else {
      throw Exception('Combinación de idiomas no disponible');
    }

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Adaptar según la estructura de respuesta de tu API
      if (data is Map<String, dynamic>) {
        return data['traduccion'] ?? data['translation'] ?? data['resultado'] ?? 'Traducción no disponible';
      } else if (data is String) {
        return data;
      } else {
        return data.toString();
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      
      // Intercambiar textos también
      final tempText = _inputController.text;
      _inputController.text = _translatedText;
      _translatedText = tempText;
    });
    
    if (_inputController.text.isNotEmpty) {
      _translateText();
    }
  }

  void _clearText() {
    _inputController.clear();
    setState(() {
      _translatedText = '';
      _hasError = false;
    });
    _animationController.reverse();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showLanguageSelector({required bool isSource}) async {
    final result = await showModalBottomSheet<Language>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLanguageSelector(),
    );

    if (result != null) {
      setState(() {
        if (isSource) {
          _sourceLanguage = result;
        } else {
          _targetLanguage = result;
        }
      });
      
      if (_inputController.text.isNotEmpty) {
        _translateText();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Traductor',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black54),
            onPressed: () {
              // Implementar historial de traducciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial próximamente')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector header
          _buildLanguageHeader(),
          
          // Translation content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Input section
                  _buildInputSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Output section
                  _buildOutputSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Source language
          Expanded(
            child: InkWell(
              onTap: () => _showLanguageSelector(isSource: true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_sourceLanguage.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _sourceLanguage.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Swap button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _swapLanguages,
              icon: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
            ),
          ),
          
          // Target language
          Expanded(
            child: InkWell(
              onTap: () => _showLanguageSelector(isSource: false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_targetLanguage.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _targetLanguage.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(_sourceLanguage.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  _sourceLanguage.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (_inputController.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearText,
                    icon: const Icon(Icons.clear, size: 20),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),
          
          // Text input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Introduce el texto a traducir...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          
          // Actions
          if (_inputController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _copyToClipboard(_inputController.text),
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copiar',
                  ),
                  const Spacer(),
                  Text(
                    '${_inputController.text.length}/500',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(_targetLanguage.flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        _targetLanguage.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (_translatedText.isNotEmpty)
                        IconButton(
                          onPressed: () => _copyToClipboard(_translatedText),
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copiar traducción',
                        ),
                    ],
                  ),
                ),
                
                // Translation content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 80),
                    child: _buildTranslationContent(),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
          ),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_translatedText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          _translatedText,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          const Text(
            'Seleccionar idioma',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language list
          ..._languages.map((language) {
            return ListTile(
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                language.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.of(context).pop(language),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Language model
class Language {
  final String name;
  final String code;
  final String flag;

  Language(this.name, this.code, this.flag);
}