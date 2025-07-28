import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/games/practicas/services/audio_translate_service.dart';

class AudioTranslatorScreen extends StatefulWidget {
  const AudioTranslatorScreen({super.key});

  @override
  State<AudioTranslatorScreen> createState() => _AudioTranslatorScreenState();
}

class _AudioTranslatorScreenState extends State<AudioTranslatorScreen>
    with TickerProviderStateMixin {
  final AudioTranslatorService _audioService = AudioTranslatorService();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _zapotecoText = '';
  String _spanishTranslation = '';
  String _statusMessage = 'Toca el micrófono para comenzar';
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudioService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeAudioService() async {
    setState(() {
      _statusMessage = 'Inicializando servicios de audio...';
    });

    try {
      print('🔄 Inicializando AudioTranslatorService...');
      bool success = await _audioService.initialize();
      
      if (success) {
        setState(() {
          _isInitialized = true;
          _statusMessage = 'Listo para traducir';
        });
        _showSuccess('Servicios de audio inicializados correctamente');
        
        // Mostrar información de diagnóstico
        final capabilities = await _audioService.getDeviceCapabilities();
        print('📊 Capacidades del dispositivo: $capabilities');
        
      } else {
        setState(() {
          _isInitialized = false;
          _statusMessage = 'Error al inicializar servicios';
        });
        
        // Obtener información de diagnóstico
        final capabilities = await _audioService.getDeviceCapabilities();
        print('❌ Capacidades (con error): $capabilities');
        
        _showDetailedError();
      }
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _statusMessage = 'Error de inicialización';
      });
      print('💥 Excepción durante inicialización: $e');
      _showDetailedError();
    }
  }

  void _showDetailedError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error de Audio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se pudieron inicializar los servicios de audio. Posibles causas:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text('• Permisos de micrófono denegados'),
            const Text('• Dispositivo sin micrófono'),
            const Text('• Navegador no compatible (Web)'),
            const Text('• Conexión no segura (Web - necesita HTTPS)'),
            const SizedBox(height: 16),
            const Text(
              'Soluciones:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text('1. Permitir acceso al micrófono'),
            const Text('2. Verificar que el micrófono funcione'),
            const Text('3. En web: usar HTTPS o localhost'),
            const Text('4. Reiniciar la aplicación'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeAudioService(); // Reintentar
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      _showError('Servicios no inicializados');
      return;
    }

    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = true;
        _statusMessage = 'Escuchando... Habla en zapoteco';
        _zapotecoText = '';
        _spanishTranslation = '';
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat();

      await _audioService.startListening(
        onResult: (zapotecoText) {
          setState(() {
            _zapotecoText = zapotecoText;
          });
        },
        onTranslation: (spanishText) async {
          setState(() {
            _spanishTranslation = spanishText;
            _statusMessage = 'Traducción completada';
          });
          
          // Reproducir automáticamente la traducción
          await _speakTranslation(spanishText);
        },
        onError: (error) {
          setState(() {
            _statusMessage = 'Error: $error';
          });
          _showError(error);
          _stopListening();
        },
      );
      
    } catch (e) {
      setState(() {
        _isListening = false;
        _statusMessage = 'Error al iniciar grabación';
      });
      _pulseController.stop();
      _waveController.stop();
      _showError('Error: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _audioService.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = _zapotecoText.isEmpty 
            ? 'Toca el micrófono para intentar de nuevo'
            : 'Grabación completada';
      });
      
      _pulseController.stop();
      _waveController.stop();
      _pulseController.reset();
      _waveController.reset();
      
    } catch (e) {
      _showError('Error al detener grabación: $e');
    }
  }

  Future<void> _speakTranslation([String? text]) async {
    final textToSpeak = text ?? _spanishTranslation;
    if (textToSpeak.isEmpty) {
      _showError('No hay traducción para reproducir');
      return;
    }

    try {
      setState(() {
        _isSpeaking = true;
        _statusMessage = 'Reproduciendo traducción...';
      });

      await _audioService.speakText(textToSpeak);
      
      setState(() {
        _isSpeaking = false;
        _statusMessage = 'Reproducción completada';
      });
      
    } catch (e) {
      setState(() {
        _isSpeaking = false;
        _statusMessage = 'Error en reproducción';
      });
      _showError('Error al reproducir: $e');
    }
  }

  void _clearResults() {
    setState(() {
      _zapotecoText = '';
      _spanishTranslation = '';
      _statusMessage = 'Resultados borrados. Listo para traducir';
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _audioService.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isInitialized 
                    ? _buildMainContent()
                    : _buildLoadingState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/practice'),
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Traductor de Audio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Zapoteco → Español',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Inicializando servicios de audio...',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildStatusCard(),
          const SizedBox(height: 30),
          _buildMicrophoneButton(),
          const SizedBox(height: 30),
          if (_zapotecoText.isNotEmpty || _spanishTranslation.isNotEmpty) ...[
            _buildResultsSection(),
            const SizedBox(height: 20),
          ],
          _buildControlButtons(),
          const SizedBox(height: 20),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 32,
            color: _isListening ? Colors.red : const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _isListening ? Colors.red : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isListening
                      ? [Colors.red, Colors.red.shade700]
                      : [const Color(0xFF4CAF50), const Color(0xFF45A049)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : const Color(0xFF4CAF50))
                        .withOpacity(0.3),
                    blurRadius: _isListening ? 20 : 15,
                    spreadRadius: _isListening ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 50,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        if (_zapotecoText.isNotEmpty) _buildTextCard(
          title: 'Zapoteco (Original)',
          text: _zapotecoText,
          icon: Icons.record_voice_over,
          color: const Color(0xFF2196F3),
        ),
        if (_zapotecoText.isNotEmpty && _spanishTranslation.isNotEmpty)
          const SizedBox(height: 15),
        if (_spanishTranslation.isNotEmpty) _buildTextCard(
          title: 'Español (Traducción)',
          text: _spanishTranslation,
          icon: Icons.translate,
          color: const Color(0xFF4CAF50),
          hasPlayButton: true,
        ),
      ],
    );
  }

  Widget _buildTextCard({
    required String title,
    required String text,
    required IconData icon,
    required Color color,
    bool hasPlayButton = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (hasPlayButton)
                IconButton(
                  onPressed: _isSpeaking ? null : () => _speakTranslation(),
                  icon: Icon(
                    _isSpeaking ? Icons.volume_up : Icons.play_arrow,
                    color: _isSpeaking ? Colors.orange : color,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        // Botón de diagnóstico (temporal)
        if (!_isInitialized)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final capabilities = await _audioService.getDeviceCapabilities();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Diagnóstico'),
                    content: SingleChildScrollView(
                      child: Text(capabilities.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Diagnóstico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        // Botones originales
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (_zapotecoText.isNotEmpty || _spanishTranslation.isNotEmpty)
                    ? _clearResults
                    : null,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _spanishTranslation.isNotEmpty && !_isSpeaking
                    ? () => _speakTranslation()
                    : null,
                icon: Icon(_isSpeaking ? Icons.volume_up : Icons.play_arrow),
                label: Text(_isSpeaking ? 'Reproduciendo...' : 'Reproducir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Toca el micrófono verde para comenzar a grabar\n'
            '2. Habla claramente en zapoteco\n'
            '3. Toca el botón rojo para detener\n'
            '4. Escucha la traducción automática en español\n'
            '5. Usa "Reproducir" para escuchar de nuevo',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 12),
          if (identical(0, 0.0)) // Solo para web
            const Text(
              'En la versión web, el navegador solicitará permiso para usar el micrófono cuando presiones el botón de grabar.\n'
              'Por favor, acepta el permiso en la notificación del navegador para poder grabar tu voz.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}