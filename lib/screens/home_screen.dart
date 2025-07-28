import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/games/lecciones/lesson_model.dart';
import 'package:integrador/games/lecciones/lesson_service.dart';
import '../models/user_progress_model.dart';
import '../services/user_progress_service.dart';
import '../widgets/progress_circle_widget.dart';
import '../widgets/lesson_card_widget.dart';
import '../widgets/streak_banner_widget.dart';
import '../widgets/custom_floating_button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  final UserProgressService _userProgressService = UserProgressService();

  List<LessonModel> _lessons = [];
  UserProgressModel? _userProgress;
  bool _isLoading = true;
  int? _totalDays;
  DateTime? _firstUseDate;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // SISTEMA DE COLORES CONSISTENTE
  static const Color _primaryColor = Color(0xFFD4A574);  // Dorado principal
  static const Color _backgroundColor = Color(0xFFF8F6F3); // Fondo cálido
  static const Color _surfaceColor = Color(0xFFFFFFFF);   // Tarjetas
  static const Color _textPrimary = Color(0xFF2C2C2C);    // Texto principal
  static const Color _textSecondary = Color(0xFF666666);  // Texto secundario
  static const Color _borderColor = Color(0xFFE8E1DC);    // Bordes suaves

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar datos cuando la pantalla se vuelve activa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshDataIfNeeded();
      }
    });
  }

  // Método para refrescar datos si es necesario
  Future<void> _refreshDataIfNeeded() async {
    // Solo refrescar si no está cargando y han pasado más de 30 segundos desde la última carga
    if (!_isLoading) {
      await _loadData();
    }
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      await _userProgressService.initStreak();
      final results = await Future.wait([
        _lessonService.getAllLessons(),
        _userProgressService.getUserProgress(),
        _userProgressService.getTotalDays(),
        _userProgressService.getFirstUseDate(),
      ]);

      if (mounted) {
        setState(() {
          _lessons = results[0] as List<LessonModel>;
          _userProgress = results[1] as UserProgressModel;
          _totalDays = results[2] as int;
          _firstUseDate = results[3] as DateTime?;
          _isLoading = false;
        });

        _fadeController.forward();
        await Future.delayed(const Duration(milliseconds: 200));
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar los datos: $e');
      }
    }
  }

  // Nuevo método para obtener estadísticas de progreso detalladas
  Map<String, dynamic> _getDetailedProgressStats() {
    if (_lessons.isEmpty || _userProgress == null) {
      return {
        'completedLessons': 0,
        'totalLessons': 0,
        'completionRate': 0.0,
        'inProgressLessons': 0,
        'lockedLessons': 0,
      };
    }

    final completedLessons = _lessons.where((lesson) => lesson.isCompleted).length;
    final totalLessons = _lessons.length;
    final inProgressLessons = _lessons.where(
      (lesson) => lesson.progress > 0 && lesson.progress < 1.0 && !lesson.isCompleted
    ).length;
    final lockedLessons = _lessons.where((lesson) => lesson.isLocked).length;
    final completionRate = totalLessons > 0 ? (completedLessons / totalLessons * 100).round() : 0;

    return {
      'completedLessons': completedLessons,
      'totalLessons': totalLessons,
      'completionRate': completionRate,
      'inProgressLessons': inProgressLessons,
      'lockedLessons': lockedLessons,
    };
  }

  // Método para obtener mensaje de motivación basado en el progreso
  String _getMotivationalMessage() {
    if (_userProgress == null) return '¡Comienza tu viaje de aprendizaje!';
    
    final progress = _userProgress!.overallProgress;
    
    if (progress >= 0.8) {
      return '¡Excelente! Estás muy cerca de completar todo el curso.';
    } else if (progress >= 0.5) {
      return '¡Gran trabajo! Has completado más de la mitad del curso.';
    } else if (progress >= 0.2) {
      return '¡Buen progreso! Sigue así, cada lección te acerca más a tu meta.';
    } else if (progress > 0) {
      return '¡Bien hecho! Has comenzado tu viaje de aprendizaje.';
    } else {
      return '¡Comienza tu aventura de aprendizaje hoy mismo!';
    }
  }

  // Nuevo método para actualizar progreso cuando se complete una lección
  Future<void> _updateProgressAfterLessonCompletion(String lessonId, int duration) async {
    try {
      // Completar la lección en el servicio de progreso
      await _userProgressService.completeLesson(lessonId, duration);
      
      // Recargar datos para actualizar la UI
      await _loadData();
      
      _showMessage('¡Lección completada! Tu progreso ha sido actualizado.');
    } catch (e) {
      _showError('Error al actualizar el progreso: $e');
    }
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
        duration: const Duration(seconds: 4),
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

  void _onLessonTapped(LessonModel lesson) {
    if (lesson.isLocked) {
      _showMessage('Esta lección está bloqueada. Completa las anteriores primero.');
      return;
    }

    // Navegar a la pantalla de detalles de la lección usando GoRouter
    context.go('/lessons/${lesson.id}');
  }

  void _onFloatingButtonPressed() {
    if (_lessons.isEmpty) return;
    
    final nextLesson = _lessons.firstWhere(
      (lesson) => !lesson.isCompleted && !lesson.isLocked,
      orElse: () => _lessons.first,
    );

    _onLessonTapped(nextLesson);
  }

  void _onStreakBannerTapped() {
    _showMessage('¡Mantén tu racha activa practicando todos los días!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // Fondo consistente
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildMainContent(),
      ),
      floatingActionButton: _userProgress != null && !_isLoading
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
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
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                strokeWidth: 4,
                semanticsLabel: 'Cargando progreso',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando tu progreso...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              semanticsLabel: 'Cargando tu progreso',
            ),
            const SizedBox(height: 8),
            Text(
              'Preparando tu experiencia de aprendizaje',
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
    if (_userProgress == null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: _primaryColor,
          backgroundColor: _surfaceColor,
          strokeWidth: 3,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header Section - MEJORADO
              SliverToBoxAdapter(
                child: _buildHeaderSection(),
              ),
              
              // Streak Banner - ESPACIADO CONSISTENTE
              SliverToBoxAdapter(
                child: _buildStreakSection(),
              ),
              
              // Progress Section - REDISEÑADO
              SliverToBoxAdapter(
                child: _buildProgressSection(),
              ),
              
              // Next Step Banner - NUEVO COMPONENTE
              SliverToBoxAdapter(
                child: _buildNextStepBanner(),
              ),
              
              // Lessons Section
              SliverToBoxAdapter(
                child: _buildLessonsHeader(),
              ),
              
              // Lessons Grid - ESPACIADO MEJORADO
              _buildLessonsGrid(),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Espacio para FAB
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    // Obtener el tamaño de la pantalla para hacer el widget responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24, 
        vertical: isSmallScreen ? 24 : 32
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
      child: Column(
        children: [
          Text(
            'Nativox',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Preservando nuestras raíces',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreakBannerWidget(
        streakDays: _userProgress!.streakDays,
        isActive: _userProgress!.isStreakActive,
        onTap: _onStreakBannerTapped,
        totalDays: _totalDays,
      ),
    );
  }

  Widget _buildProgressSection() {
    // Obtener el tamaño de la pantalla para hacer el widget responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
          // Header consistente
          Row(
            children: [
              Container(
                width: isSmallScreen ? 40 : 48,
                height: isSmallScreen ? 40 : 48,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: _primaryColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Progreso',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 1 : 2),
                    Text(
                      _getMotivationalMessage(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          // Círculo de progreso CENTRADO
          Center(
            child: SizedBox(
              width: isSmallScreen ? 120 : 160,
              height: isSmallScreen ? 120 : 160,
              child: ProgressCircleWidget(
                progress: _userProgress!.overallProgress,
                percentage: _userProgress!.progressPercentage,
                level: _userProgress!.currentLevel,
                size: isSmallScreen ? 120 : 160,
              ),
            ),
          ),
          // Información adicional de progreso
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildProgressDetails(),
        ],
      ),
    );
  }

  // Nuevo widget para mostrar detalles del progreso
  Widget _buildProgressDetails() {
    // Obtener estadísticas detalladas de progreso
    final stats = _getDetailedProgressStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                icon: Icons.check_circle_outline,
                label: 'Completadas',
                value: '${stats['completedLessons']}',
                color: _primaryColor,
              ),
              _buildProgressStat(
                icon: Icons.library_books_outlined,
                label: 'Total',
                value: '${stats['totalLessons']}',
                color: _textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                icon: Icons.percent,
                label: 'Progreso',
                value: '${stats['completionRate']}%',
                color: _primaryColor,
              ),
              _buildProgressStat(
                icon: Icons.timer_outlined,
                label: 'Tiempo',
                value: '${_userProgress?.totalTimeSpent ?? 0} min',
                color: _textSecondary,
              ),
            ],
          ),
          if (stats['inProgressLessons'] > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressStat(
                  icon: Icons.pending_outlined,
                  label: 'En Progreso',
                  value: '${stats['inProgressLessons']}',
                  color: Colors.orange,
                ),
                _buildProgressStat(
                  icon: Icons.lock_outline,
                  label: 'Bloqueadas',
                  value: '${stats['lockedLessons']}',
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Banner "Siguiente" separado y consistente
  Widget _buildNextStepBanner() {
    if (_userProgress?.nextLesson == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _onFloatingButtonPressed,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siguiente: ${_userProgress!.nextLesson}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Continúa tu aprendizaje',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _primaryColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.library_books_rounded,
              color: _primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lecciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_lessons.length} lecciones disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  RenderObjectWidget _buildLessonsGrid() {
    if (_lessons.isEmpty) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildEmptyLessonsState(),
          childCount: 1,
        ),
      );
    }

    // Obtener el tamaño de la pantalla para hacer el grid responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 1 : 2, // 1 columna en pantallas muy pequeñas
          childAspectRatio: isSmallScreen ? 1.2 : 0.9, // Proporción ajustada para pantallas pequeñas
          crossAxisSpacing: isSmallScreen ? 12 : 16, // Espaciado ajustado
          mainAxisSpacing: isSmallScreen ? 12 : 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = _lessons[index];
            return LessonCardWidget(
              lesson: lesson,
              onTap: () => _onLessonTapped(lesson),
              shouldAnimate: true,
            );
          },
          childCount: _lessons.length,
        ),
      ),
    );
  }

  Widget _buildEmptyLessonsState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: _primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            'No hay lecciones disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Las lecciones se cargarán pronto',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar los datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Hubo un problema al cargar tu progreso.\nPor favor, intenta de nuevo.',
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
                      'Reintentar',
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
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomFloatingButtonWidget(
        onPressed: _onFloatingButtonPressed,
        tooltip: 'Continuar aprendiendo',
      ),
    );
  }
}