import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/translation_model.dart';
import '../services/translation_service.dart';

class TraductorScreen extends StatefulWidget {
  const TraductorScreen({super.key});

  @override
  State<TraductorScreen> createState() => _TraductorScreenState();
}

class _TraductorScreenState extends State<TraductorScreen> 
    with SingleTickerProviderStateMixin {
  
  final TranslationService _translationService = TranslationService();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  
  List<LanguageModel> _languages = [];
  LanguageModel? _sourceLanguage;
  LanguageModel? _targetLanguage;
  
  TranslationModel? _currentTranslation;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadLanguages();
    _inputController.addListener(_onTextChanged);
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _loadLanguages() {
    _languages = _translationService.getAvailableLanguages();
    setState(() {
      _sourceLanguage = _languages.firstWhere((lang) => lang.code == 'es');
      _targetLanguage = _languages.firstWhere((lang) => lang.code == 'tseltal');
    });
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
        _currentTranslation = null;
        _hasError = false;
      });
      _animationController.reverse();
    }
  }

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sourceLanguage == null || _targetLanguage == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final translation = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguage!.code,
        targetLanguage: _targetLanguage!.code,
      );
      
      setState(() {
        _currentTranslation = translation;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('TranslationException: ', '');
        _currentTranslation = null;
      });
      _animationController.forward();
    }
  }

  void _swapLanguages() {
    if (_sourceLanguage == null || _targetLanguage == null) return;
    
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      
      // Intercambiar textos si hay traducción
      if (_currentTranslation != null) {
        _inputController.text = _currentTranslation!.traduccion;
      }
    });
    
    if (_inputController.text.isNotEmpty) {
      _translateText();
    }
  }

  void _clearText() {
    _inputController.clear();
    setState(() {
      _currentTranslation = null;
      _hasError = false;
    });
    _animationController.reverse();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showMessage('Texto copiado al portapapeles');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFD4A574),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showLanguageSelector({required bool isSource}) async {
    final result = await showModalBottomSheet<LanguageModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildLanguageSelectorModal(),
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

  // Función para obtener el ícono según el idioma
  IconData _getLanguageIcon(String? languageCode) {
    switch (languageCode) {
      case 'es':
        return Icons.language;
      case 'tseltal':
        return Icons.nature_people;
      case 'zapoteco':
        return Icons.forest;
      case 'maya':
        return Icons.temple_hindu;
      case 'nahuatl':
        return Icons.landscape;
      default:
        return Icons.translate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final maxContentWidth = 1200.0;
    
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
          child: Column(
            children: [
              _buildHeader(isWide),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 40 : 20,
                        vertical: 20,
                      ),
                      child: isLandscape && isWide
                          ? _buildLandscapeLayout(isWide)
                          : _buildPortraitLayout(isWide),
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

  Widget _buildLandscapeLayout(bool isWide) {
    return Column(
      children: [
        _buildLanguageSelector(isWide),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInputCard(isWide)),
            const SizedBox(width: 20),
            Expanded(child: _buildOutputCard(isWide)),
          ],
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(bool isWide) {
    return Column(
      children: [
        _buildLanguageSelector(isWide),
        const SizedBox(height: 24),
        _buildInputCard(isWide),
        const SizedBox(height: 20),
        _buildOutputCard(isWide),
      ],
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 20, 
        vertical: isWide ? 20 : 15,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isWide ? 48 : 40,
            height: isWide ? 48 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go('/practice'),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: isWide ? 24 : 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Traductor',
                  style: TextStyle(
                    fontSize: isWide ? 24 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: isWide ? 6 : 4),
                Text(
                  'Traduce entre idiomas nativos',
                  style: TextStyle(
                    fontSize: isWide ? 16 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isWide ? 48 : 40),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageButton(
              language: _sourceLanguage,
              onTap: () => _showLanguageSelector(isSource: true),
              isWide: isWide,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _swapLanguages,
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 14 : 12),
                  child: Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: isWide ? 24 : 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildLanguageButton(
              language: _targetLanguage,
              onTap: () => _showLanguageSelector(isSource: false),
              isWide: isWide,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required LanguageModel? language,
    required VoidCallback onTap,
    required bool isWide,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isWide ? 18 : 16, 
            horizontal: isWide ? 16 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getLanguageIcon(language?.code),
                color: const Color(0xFFB8956A),
                size: isWide ? 22 : 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  language?.name ?? 'Seleccionar',
                  style: TextStyle(
                    fontSize: isWide ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C2C2C),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: isWide ? 18 : 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isWide ? 24 : 20),
            child: Row(
              children: [
                Icon(
                  _getLanguageIcon(_sourceLanguage?.code),
                  color: const Color(0xFFB8956A),
                  size: isWide ? 24 : 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _sourceLanguage?.name ?? 'Idioma origen',
                  style: TextStyle(
                    fontSize: isWide ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF666666),
                  ),
                ),
                const Spacer(),
                if (_inputController.text.isNotEmpty)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _clearText,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.clear,
                          size: isWide ? 22 : 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 20),
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              maxLines: isWide ? 5 : 4,
              minLines: isWide ? 4 : 3,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Escribe aquí para traducir...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: const Color(0xFF999999),
                  fontSize: isWide ? 18 : 16,
                ),
                counterText: '',
              ),
              style: TextStyle(
                fontSize: isWide ? 18 : 16,
                height: 1.5,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
          if (_inputController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(isWide ? 24 : 20),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _copyToClipboard(_inputController.text),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.copy,
                          size: isWide ? 22 : 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_inputController.text.length}/100',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isWide ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutputCard(bool isWide) {
    if (_inputController.text.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(isWide ? 24 : 20),
                    child: Row(
                      children: [
                        Icon(
                          _getLanguageIcon(_targetLanguage?.code),
                          color: const Color(0xFFB8956A),
                          size: isWide ? 24 : 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _targetLanguage?.name ?? 'Idioma destino',
                          style: TextStyle(
                            fontSize: isWide ? 16 : 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        const Spacer(),
                        if (_currentTranslation != null)
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _copyToClipboard(_currentTranslation!.traduccion),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.copy,
                                  size: isWide ? 22 : 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 20),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: isWide ? 100 : 80),
                      child: _buildTranslationContent(isWide),
                    ),
                  ),
                  SizedBox(height: isWide ? 24 : 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslationContent(bool isWide) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isWide ? 24 : 20),
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
            strokeWidth: isWide ? 3 : 2,
          ),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: EdgeInsets.all(isWide ? 24 : 20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: isWide ? 48 : 40,
            ),
            SizedBox(height: isWide ? 16 : 12),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: isWide ? 16 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_currentTranslation != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentTranslation!.traduccion,
            style: TextStyle(
              fontSize: isWide ? 20 : 18,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2C2C2C),
            ),
          ),
          if (_currentTranslation!.match != _currentTranslation!.entrada)
            Padding(
              padding: EdgeInsets.only(top: isWide ? 12 : 8),
              child: Text(
                'Coincidencia: ${_currentTranslation!.match}',
                style: TextStyle(
                  fontSize: isWide ? 14 : 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLanguageSelectorModal() {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(
              top: isWide ? 16 : 12, 
              bottom: isWide ? 24 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: Text(
              'Seleccionar idioma',
              style: TextStyle(
                fontSize: isWide ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
          
          SizedBox(height: isWide ? 24 : 20),
          
          // Language list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                return Container(
                  margin: EdgeInsets.only(bottom: isWide ? 12 : 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(language),
                      child: Padding(
                        padding: EdgeInsets.all(isWide ? 20 : 16),
                        child: Row(
                          children: [
                            Icon(
                              _getLanguageIcon(language.code),
                              color: const Color(0xFFB8956A),
                              size: isWide ? 28 : 24,
                            ),
                            SizedBox(width: isWide ? 20 : 16),
                            Text(
                              language.name,
                              style: TextStyle(
                                fontSize: isWide ? 18 : 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const Spacer(),
                            if (language.isAvailable)
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: isWide ? 24 : 20,
                              )
                            else
                              Icon(
                                Icons.schedule,
                                color: Colors.orange[600],
                                size: isWide ? 24 : 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: isWide ? 24 : 20),
        ],
      ),
    );
  }
}