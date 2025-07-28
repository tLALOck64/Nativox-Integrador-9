import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/services/secure_storage_service.dart';
import './lesson_model.dart';
import './lesson_service.dart';
import '../../widgets/lesson_stats_widget.dart';
import '../../widgets/level_section_widget.dart';
import 'package:integrador/core/config/app_theme.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> with TickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  
  Map<String, List<LessonModel>> _lessonsByLevel = {};
  Map<String, int> _lessonStats = {};
  bool _isLoading = true;

  // SISTEMA DE COLORES CONSISTENTE - Mismo que HomeScreen
  static const Color _primaryColor = Color(0xFFD4A574);    // Dorado principal
  static const Color _backgroundColor = Color(0xFFF8F6F3); // Fondo cálido
  static const Color _surfaceColor = Color(0xFFFFFFFF);    // Tarjetas
  static const Color _textPrimary = Color(0xFF2C2C2C);     // Texto principal
  static const Color _textSecondary = Color(0xFF666666);   // Texto secundario
  static const Color _borderColor = Color(0xFFE8E1DC);     // Bordes suaves
  
  // Colores de progreso consistentes
  static const Color _progressGreen = Color(0xFF4CAF50);   // Completado
  static const Color _progressBlue = Color(0xFF2196F3);    // En progreso
  static const Color _progressGray = Color(0xFF9E9E9E);    // Bloqueado

  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerAnimation;

  // Orden de niveles para mostrar
  final List<String> _levelOrder = ['Básico', 'Intermedio', 'Avanzado'];

  // Configuración de niveles con colores consistentes
  final Map<String, Map<String, dynamic>> _levelConfig = {
    'Básico': {
      'icon': Icons.lightbulb_outline_rounded,
      'color': _progressGreen,
      'description': 'Fundamentos esenciales',
    },
    'Intermedio': {
      'icon': Icons.star_outline_rounded,
      'color': _primaryColor,
      'description': 'Construye tu conocimiento',
    },
    'Avanzado': {
      'icon': Icons.emoji_events_outlined,
      'color': _progressBlue,
      'description': 'Domina el idioma',
    },
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  // ✅ NUEVO: Listener para detectar cuando regresa de una lección
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Refrescar datos cuando regresa de una lección
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isLoading) {
        _refreshProgressData();
      }
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    ));

    _headerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO MEJORADO PARA CARGAR DATOS CON PROGRESO ACTUALIZADO
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      print('🔄 Cargando datos de lecciones...');
      
      // ✅ Obtener ID del usuario actual
      final userId = await _getCurrentUserId();
      print('👤 Usuario ID: $userId');

      // ✅ Cargar todas las lecciones primero
      final allLessons = await _lessonService.getAllLessons();
      print('📚 Lecciones cargadas: ${allLessons.length}');

      // ✅ CRUCIAL: Actualizar progreso de cada lección desde el servidor
      final updatedLessons = <LessonModel>[];
      for (final lesson in allLessons) {
        try {
          print('📊 Actualizando progreso para lección: ${lesson.id}');
          
          // ✅ Obtener progreso actualizado del servidor
          final progress = await _lessonService.getLessonProgressForUser(
            userId: userId, 
            lessonId: lesson.id
          );
          
          print('📊 Progreso obtenido: ${(progress * 100).toStringAsFixed(1)}%');
          
          // ✅ Crear lección actualizada con progreso real
          final updatedLesson = lesson.copyWith(
            progress: progress,
            isCompleted: progress >= 1.0,
          );
          
          updatedLessons.add(updatedLesson);
          
        } catch (e) {
          print('⚠️ Error actualizando progreso para ${lesson.id}: $e');
          // Si falla, usar la lección original
          updatedLessons.add(lesson);
        }
      }

      // ✅ Agrupar lecciones por nivel con progreso actualizado
      final Map<String, List<LessonModel>> groupedLessons = {};
      for (final lesson in updatedLessons) {
        if (!groupedLessons.containsKey(lesson.level)) {
          groupedLessons[lesson.level] = [];
        }
        groupedLessons[lesson.level]!.add(lesson);
      }
      
      // ✅ Ordenar lecciones por número dentro de cada nivel
      groupedLessons.forEach((level, lessons) {
        lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
      });

      // ✅ Calcular estadísticas actualizadas
      final completedLessons = updatedLessons.where((lesson) => lesson.isCompleted).length;
      final inProgressLessons = updatedLessons.where(
        (lesson) => lesson.progress > 0 && lesson.progress < 1.0
      ).length;
      final totalWords = updatedLessons.fold<int>(
        0,
        (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
      );

      final updatedStats = {
        'completed': completedLessons,
        'inProgress': inProgressLessons,
        'totalWords': totalWords,
        'total': updatedLessons.length,
      };

      if (mounted) {
        setState(() {
          _lessonsByLevel = groupedLessons;
          _lessonStats = updatedStats;
          _isLoading = false;
        });

        print('✅ Datos actualizados exitosamente');
        print('📊 Lecciones completadas: $completedLessons');
        print('📊 Lecciones en progreso: $inProgressLessons');

        // ✅ Animar entrada
        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _slideController.forward();
        }
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar las lecciones: ${e.toString()}');
      }
    }
  }

  // ✅ NUEVO MÉTODO PARA REFRESCAR SOLO EL PROGRESO (MÁS RÁPIDO)
  Future<void> _refreshProgressData() async {
    if (_isLoading || _lessonsByLevel.isEmpty) return;
    
    try {
      print('🔄 Refrescando progreso de lecciones...');
      
      final userId = await _getCurrentUserId();
      bool hasChanges = false;
      
      // ✅ Actualizar progreso de todas las lecciones
      final updatedLessonsByLevel = <String, List<LessonModel>>{};
      
      for (final entry in _lessonsByLevel.entries) {
        final level = entry.key;
        final lessons = entry.value;
        final updatedLessons = <LessonModel>[];
        
        for (final lesson in lessons) {
          try {
            // ✅ Obtener progreso actualizado
            final newProgress = await _lessonService.getLessonProgressForUser(
              userId: userId, 
              lessonId: lesson.id
            );
            
            // ✅ Verificar si hay cambios
            if ((newProgress - lesson.progress).abs() > 0.01) {
              hasChanges = true;
              print('📊 Progreso actualizado para ${lesson.title}: ${(lesson.progress * 100).toStringAsFixed(1)}% → ${(newProgress * 100).toStringAsFixed(1)}%');
            }
            
            // ✅ Crear lección actualizada
            final updatedLesson = lesson.copyWith(
              progress: newProgress,
              isCompleted: newProgress >= 1.0,
            );
            
            updatedLessons.add(updatedLesson);
            
          } catch (e) {
            print('⚠️ Error refrescando progreso para ${lesson.id}: $e');
            updatedLessons.add(lesson);
          }
        }
        
        updatedLessonsByLevel[level] = updatedLessons;
      }
      
      // ✅ Solo actualizar UI si hay cambios
      if (hasChanges && mounted) {
        // ✅ Recalcular estadísticas
        final allLessons = updatedLessonsByLevel.values.expand((lessons) => lessons).toList();
        final completedLessons = allLessons.where((lesson) => lesson.isCompleted).length;
        final inProgressLessons = allLessons.where(
          (lesson) => lesson.progress > 0 && lesson.progress < 1.0
        ).length;
        final totalWords = allLessons.fold<int>(
          0,
          (sum, lesson) => sum + (lesson.wordCount * lesson.progress).round(),
        );

        final updatedStats = {
          'completed': completedLessons,
          'inProgress': inProgressLessons,
          'totalWords': totalWords,
          'total': allLessons.length,
        };
        
        setState(() {
          _lessonsByLevel = updatedLessonsByLevel;
          _lessonStats = updatedStats;
        });
        
        print('✅ Progreso refrescado exitosamente');
      } else {
        print('📊 No hay cambios en el progreso');
      }
      
    } catch (e) {
      print('❌ Error refrescando progreso: $e');
      // No mostrar error al usuario para el refresh silencioso
    }
  }

  Future<String> _getCurrentUserId() async {
    final userData = await SecureStorageService().getUserData();
    return userData?['id'] ?? userData?['uid'] ?? '';
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }

  // ✅ MÉTODO MEJORADO PARA MANEJAR TAP EN LECCIÓN
  void _onLessonTapped(LessonModel lesson) {
    if (lesson.isLocked) {
      _showMessage('Esta lección está bloqueada. Completa las anteriores primero.');
      return;
    }
    
    if (lesson.isCompleted) {
      _showMessage('Ya completaste esta lección. ¡Puedes repetirla!');
    } else if (lesson.progress > 0) {
      _showMessage('Continuando lección: ${lesson.title}');
    } else {
      _showMessage('Iniciando lección: ${lesson.title}');
    }
    
    _startLesson(lesson);
  }

  // ✅ MÉTODO MEJORADO PARA INICIAR LECCIÓN
  Future<void> _startLesson(LessonModel lesson) async {
    final progressText = lesson.progress > 0 
        ? ' (${(lesson.progress * 100).toStringAsFixed(0)}% completada)'
        : '';
    
    _showMessage('Cargando "${lesson.title}"$progressText...');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // ✅ Navegar a la lección
      final result = await context.push('/lessons/${lesson.id}');
      
      // ✅ Cuando regresa de la lección, refrescar progreso
      if (mounted) {
        print('🔄 Regresó de la lección, refrescando progreso...');
        await _refreshProgressData();
      }
    }
  }

  void _onStatsBoxTapped() {
    _showMessage('Aquí podrías ver estadísticas detalladas');
  }

  // ✅ MÉTODO MEJORADO PARA RefreshIndicator
  Future<void> _handleRefresh() async {
    // ✅ Limpiar cache y recargar todo
    _lessonService.clearCache();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Fondo consistente
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando lecciones...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparando tu contenido educativo',
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header rediseñado
            _buildHeader(),
            
            // Stats section mejorado
            if (_lessonStats.isNotEmpty) _buildStatsSection(),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh, // ✅ Usar método mejorado
                color: _primaryColor,
                backgroundColor: _surfaceColor,
                strokeWidth: 3,
                child: _buildLevelSections(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 24, 
        vertical: isSmallScreen ? 16 : 20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _primaryColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button consistente
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go('/home'),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 12 : 16),
          
          // Icono del libro
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.library_books_rounded,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 12 : 16),
          
          // Texto del header
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lecciones',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Aprende paso a paso',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO MEJORADO PARA STATS SECTION CON PROGRESO ACTUALIZADO
  Widget _buildStatsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20, 
        vertical: 8
      ),
      child: LessonStatsWidget(
        stats: _lessonStats,
        onTap: _onStatsBoxTapped,
      ),
    );
  }

  Widget _buildLevelSections() {
    if (_lessonsByLevel.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        
        // Mostrar niveles en orden específico
        ..._levelOrder.map((level) {
          if (_lessonsByLevel.containsKey(level)) {
            return _buildLevelSliver(level, _lessonsByLevel[level]!);
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }).toList(),
        
        // Mostrar cualquier nivel adicional
        ..._lessonsByLevel.entries
            .where((entry) => !_levelOrder.contains(entry.key))
            .map((entry) {
          return _buildLevelSliver(entry.key, entry.value);
        }).toList(),
        
        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  SliverToBoxAdapter _buildLevelSliver(String level, List<LessonModel> lessons) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    final config = _levelConfig[level];
    final levelColor = config?['color'] ?? _primaryColor;
    final completedCount = lessons.where((l) => l.isCompleted).length;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del nivel rediseñado
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: levelColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Icono del nivel
                  Container(
                    width: isSmallScreen ? 44 : 52,
                    height: isSmallScreen ? 44 : 52,
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: levelColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      config?['icon'] ?? Icons.school_rounded,
                      color: levelColor,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                  
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  
                  // Información del nivel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nivel $level',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config?['description'] ?? '${lessons.length} lecciones disponibles',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Progreso badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12, 
                      vertical: isSmallScreen ? 4 : 6
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: levelColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$completedCount/${lessons.length}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: levelColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Widget de lecciones con padding consistente
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: LevelSectionWidget(
                level: level,
                lessons: lessons,
                onLessonTap: _onLessonTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.library_books_rounded,
                  size: 40,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay lecciones disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Las lecciones se cargarán cuando estén listas.\nVuelve a intentar más tarde.',
                style: TextStyle(
                  fontSize: 16,
                  color: _textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Actualizar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}