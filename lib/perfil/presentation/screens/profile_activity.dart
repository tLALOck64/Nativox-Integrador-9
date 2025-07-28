// profile/presentation/screens/profile_activity.dart
import 'package:flutter/material.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/presentation/states/profile_state.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:provider/provider.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:integrador/core/config/app_theme.dart';

class ProfileActivity extends StatefulWidget {
  const ProfileActivity({super.key});

  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> with TickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // SISTEMA DE COLORES CONSISTENTE - Mismo que otras pantallas
  static const Color _primaryColor = Color(0xFFD4A574);    // Dorado principal
  static const Color _backgroundColor = Color(0xFFF8F6F3); // Fondo cálido
  static const Color _surfaceColor = Color(0xFFFFFFFF);    // Tarjetas
  static const Color _textPrimary = Color(0xFF2C2C2C);     // Texto principal
  static const Color _textSecondary = Color(0xFF666666);   // Texto secundario
  static const Color _borderColor = Color(0xFFE8E1DC);     // Bordes suaves
  
  // Colores de progreso
  static const Color _progressGreen = Color(0xFF4CAF50);   // Completado
  static const Color _progressBlue = Color(0xFF2196F3);    // En progreso

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1200;
    
    return Scaffold(
      backgroundColor: _backgroundColor, // Fondo consistente
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.state.status == ProfileStatus.loading) {
              return _buildLoadingState();
            }

            if (viewModel.state.status == ProfileStatus.error) {
              return _buildErrorState(viewModel, isTablet, isDesktop);
            }

            final profile = viewModel.state.userProfile!;

            // Iniciar animaciones cuando los datos estén listos
            if (!_fadeController.isCompleted) {
              _fadeController.forward();
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) _slideController.forward();
              });
            }

            if (isDesktop) {
              return _buildDesktopLayout(context, viewModel, profile, screenSize);
            } else if (isTablet) {
              return _buildTabletLayout(context, viewModel, profile, screenSize);
            } else {
              return _buildMobileLayout(context, viewModel, profile, screenSize);
            }
          },
        ),
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
              'Cargando perfil...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obteniendo tu información',
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

  Widget _buildErrorState(ProfileViewModel viewModel, bool isTablet, bool isDesktop) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktop ? 400 : double.infinity),
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
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE53E3E).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.state.errorMessage ?? 'Ocurrió un error inesperado',
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => viewModel.loadProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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

  // Layout para Desktop
  Widget _buildDesktopLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            // Sidebar con perfil
            Container(
              width: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primaryColor, _primaryColor.withOpacity(0.9)],
                ),
              ),
              child: _buildProfileHeader(profile, screenSize, isDesktop: true),
            ),
            // Contenido principal
            Expanded(
              child: Container(
                color: _backgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: _buildMainContent(context, viewModel, profile, screenSize, isDesktop: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Layout para Tablet
  Widget _buildTabletLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header más compacto para tablet
            Container(
              height: screenSize.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primaryColor, _primaryColor.withOpacity(0.9)],
                ),
              ),
              child: _buildProfileHeader(profile, screenSize, isTablet: true),
            ),
            // Contenido en grid para tablet
            Expanded(
              child: Container(
                color: _backgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: _buildMainContent(context, viewModel, profile, screenSize, isTablet: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Layout para Mobile
  Widget _buildMobileLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_primaryColor, _primaryColor.withOpacity(0.9)],
                ),
              ),
              child: _buildProfileHeader(profile, screenSize),
            ),
            // Contenido scrolleable
            Expanded(
              child: Container(
                color: _backgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildMainContent(context, viewModel, profile, screenSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile, Size screenSize, {bool isDesktop = false, bool isTablet = false}) {
    final avatarSize = isDesktop ? 120.0 : isTablet ? 100.0 : 100.0;
    final levelBadgeSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;
    final nameSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final titleSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return Stack(
      children: [
        // Patrón sutil de fondo - SIMPLIFICADO
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : isTablet ? 32 : 20,
            isDesktop ? 40 : isTablet ? 32 : 40,
            isDesktop ? 40 : isTablet ? 32 : 20,
            isDesktop ? 40 : isTablet ? 32 : 40,
          ),
          child: Column(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // Avatar y nivel
              Stack(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: avatarSize * 0.5,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: levelBadgeSize,
                      height: levelBadgeSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_progressGreen, Color(0xFF2E7D32)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${profile.level}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: levelBadgeSize * 0.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 32 : 24),

              // Nombre y título
              Text(
                profile.name,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  profile.title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isDesktop ? 32 : 24),

              // Estadísticas rápidas - MEJORADAS
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isDesktop ? 
                  Column(
                    children: [
                      _QuickStat(
                        value: '${profile.activeDays}',
                        label: 'Días activos',
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      _QuickStat(
                        value: '${profile.totalXP}',
                        label: 'XP total',
                        isVertical: true,
                      ),
                      const SizedBox(height: 24),
                      _QuickStat(
                        value: '${profile.badges}',
                        label: 'Insignias',
                        isVertical: true,
                      ),
                    ],
                  ) :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                        value: '${profile.activeDays}',
                        label: 'Días activos',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _QuickStat(
                        value: '${profile.totalXP}',
                        label: 'XP total',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _QuickStat(
                        value: '${profile.badges}',
                        label: 'Insignias',
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize, {bool isDesktop = false, bool isTablet = false}) {
    // Calcular crossAxisCount dinámicamente basado en el ancho de pantalla
    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 6;
    } else if (isTablet) {
      crossAxisCount = 5;
    } else {
      // Para móviles, calcular basado en el ancho de pantalla
      if (screenSize.width < 360) {
        crossAxisCount = 2; // Dispositivos muy pequeños
      } else if (screenSize.width < 480) {
        crossAxisCount = 3; // Dispositivos pequeños
      } else {
        crossAxisCount = 4; // Dispositivos medianos
      }
    }
    
    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logros y progreso en una sola fila
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logros
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.emoji_events_rounded,
                      title: 'Logros recientes',
                      isLarge: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: viewModel.state.achievements.map((achievement) =>
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _AchievementItem(
                                achievement: achievement,
                                isLarge: true,
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Progreso
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      icon: Icons.trending_up_rounded,
                      title: 'Progreso',
                      isLarge: true,
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        ProgressCardWidget(
                          title: 'Nivel actual',
                          value: 'Nivel ${profile.level}',
                          progress: profile.levelProgress,
                          subtitle: '${profile.currentXP} / ${profile.nextLevelXP} XP para nivel ${profile.level + 1}',
                          isLarge: true,
                        ),
                        const SizedBox(height: 20),
                        ProgressCardWidget(
                          title: 'Vocabulario',
                          value: '${profile.vocabularyCount} palabras',
                          progress: profile.vocabularyProgress,
                          subtitle: 'Meta: ${profile.vocabularyGoal} palabras',
                          isLarge: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          // Configuración
          _SectionTitle(
            icon: Icons.settings_rounded,
            title: 'Configuración',
            isLarge: true,
          ),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
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
              children: viewModel.state.settings.map((setting) {
                final isLast = setting == viewModel.state.settings.last;
                return _SettingItem(
                  setting: setting,
                  isLast: isLast,
                  isLarge: true,
                  onTap: () => viewModel.onSettingTapped(setting),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          // Botón de cerrar sesión
          _buildLogoutButton(isDesktop: true),
          const SizedBox(height: 40),
        ],
      );
    }

    // Layout vertical para móvil y tablet
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logros
        _SectionTitle(
          icon: Icons.emoji_events_rounded,
          title: 'Logros recientes',
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 24 : 20),
        AchievementGridWidget(
          achievements: viewModel.state.achievements,
          crossAxisCount: crossAxisCount,
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 48 : 32),

        // Progreso
        _SectionTitle(
          icon: Icons.trending_up_rounded,
          title: 'Progreso',
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 24 : 20),
        if (isTablet) ...[
          Row(
            children: [
              Expanded(
                child: ProgressCardWidget(
                  title: 'Nivel actual',
                  value: 'Nivel ${profile.level}',
                  progress: profile.levelProgress,
                  subtitle: '${profile.currentXP} / ${profile.nextLevelXP} XP para nivel ${profile.level + 1}',
                  isLarge: true,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ProgressCardWidget(
                  title: 'Vocabulario',
                  value: '${profile.vocabularyCount} palabras',
                  progress: profile.vocabularyProgress,
                  subtitle: 'Meta: ${profile.vocabularyGoal} palabras',
                  isLarge: true,
                ),
              ),
            ],
          ),
        ] else ...[
          ProgressCardWidget(
            title: 'Nivel actual',
            value: 'Nivel ${profile.level}',
            progress: profile.levelProgress,
            subtitle: '${profile.currentXP} / ${profile.nextLevelXP} XP para nivel ${profile.level + 1}',
          ),
          ProgressCardWidget(
            title: 'Vocabulario',
            value: '${profile.vocabularyCount} palabras',
            progress: profile.vocabularyProgress,
            subtitle: 'Meta: ${profile.vocabularyGoal} palabras',
          ),
        ],
        
        SizedBox(height: isDesktop ? 48 : 32),

        // Configuración
        _SectionTitle(
          icon: Icons.settings_rounded,
          title: 'Configuración',
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 24 : 20),
        Container(
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
            children: viewModel.state.settings.map((setting) {
              final isLast = setting == viewModel.state.settings.last;
              return _SettingItem(
                setting: setting,
                isLast: isLast,
                isLarge: isDesktop || isTablet,
                onTap: () => viewModel.onSettingTapped(setting),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        
        // Botón de cerrar sesión
        _buildLogoutButton(isDesktop: isDesktop, isTablet: isTablet),
        SizedBox(height: isDesktop ? 40 : 100),
      ],
    );
  }

  Widget _buildLogoutButton({bool isDesktop = false, bool isTablet = false}) {
    return Consumer<LoginViewModel>(
      builder: (context, loginViewModel, _) => Container(
        constraints: isDesktop ? const BoxConstraints(maxWidth: 300) : null,
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(Icons.logout_rounded, color: _primaryColor),
          label: Text(
            'Cerrar sesión',
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: isDesktop || isTablet ? 16 : 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isDesktop || isTablet ? 18 : 16,
            ),
          ),
          onPressed: () async {
            await loginViewModel.signOut();
          },
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS AUXILIARES MEJORADOS
// ============================================

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isVertical;

  const _QuickStat({
    required this.value,
    required this.label,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isVertical ? 26 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isVertical ? 13 : 12,
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLarge;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isLarge ? 52 : 48,
          height: isLarge ? 52 : 48,
          decoration: BoxDecoration(
            color: _ProfileActivityState._primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _ProfileActivityState._primaryColor.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: isLarge ? 26 : 24,
            color: _ProfileActivityState._primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: isLarge ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: _ProfileActivityState._textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final SettingItem setting;
  final bool isLast;
  final bool isLarge;
  final VoidCallback onTap;

  const _SettingItem({
    required this.setting,
    required this.isLast,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: setting.id == '1' ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 28 : 24,
            vertical: isLarge ? 24 : 20,
          ),
          decoration: BoxDecoration(
            border: isLast ? null : Border(
              bottom: BorderSide(
                color: _ProfileActivityState._borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isLarge ? 56 : 52,
                height: isLarge ? 56 : 52,
                decoration: BoxDecoration(
                  color: _ProfileActivityState._primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _ProfileActivityState._primaryColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    setting.icon,
                    style: TextStyle(fontSize: isLarge ? 26 : 24),
                  ),
                ),
              ),
              SizedBox(width: isLarge ? 20 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.title,
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: _ProfileActivityState._textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setting.subtitle,
                      style: TextStyle(
                        fontSize: isLarge ? 14 : 13,
                        color: _ProfileActivityState._textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _ProfileActivityState._primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: _ProfileActivityState._primaryColor.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS PARA ACHIEVEMENTS Y PROGRESS MEJORADOS
// ============================================

class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final int crossAxisCount;
  final bool isLarge;

  const AchievementGridWidget({
    super.key,
    required this.achievements,
    this.crossAxisCount = 4,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final rows = (achievements.length / crossAxisCount).ceil();
    final itemHeight = isLarge ? 130.0 : 110.0;
    final spacing = isLarge ? 20.0 : 16.0;
    final totalHeight = (rows * itemHeight) + ((rows - 1) * spacing);

    return SizedBox(
      height: totalHeight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _AchievementItem(
            achievement: achievement,
            isLarge: isLarge,
          );
        },
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;
  final bool isLarge;

  const _AchievementItem({
    required this.achievement,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Calcular tamaños dinámicamente
    final iconSize = isLarge ? 52.0 : (isSmallScreen ? 36.0 : 44.0);
    final fontSize = isLarge ? 13.0 : (isSmallScreen ? 9.0 : 11.0);
    final padding = isLarge ? 16.0 : (isSmallScreen ? 8.0 : 12.0);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _ProfileActivityState._surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: achievement.isUnlocked 
            ? _ProfileActivityState._primaryColor
            : _ProfileActivityState._borderColor,
          width: achievement.isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.isUnlocked
              ? _ProfileActivityState._primaryColor.withOpacity(0.15)
              : Colors.black.withOpacity(0.06),
            blurRadius: achievement.isUnlocked ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: achievement.isUnlocked ? () {} : null,
          child: Container(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del achievement
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                      ? _ProfileActivityState._primaryColor.withOpacity(0.1)
                      : _ProfileActivityState._borderColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement.isUnlocked
                        ? _ProfileActivityState._primaryColor.withOpacity(0.2)
                        : _ProfileActivityState._borderColor,
                      width: 1.5,
                    ),
                    boxShadow: achievement.isUnlocked ? [
                      BoxShadow(
                        color: _ProfileActivityState._primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: iconSize * 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: padding * 0.5),
                // Título
                Flexible(
                  child: Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: achievement.isUnlocked 
                        ? _ProfileActivityState._textPrimary
                        : _ProfileActivityState._textSecondary,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final String subtitle;
  final bool isLarge;

  const ProgressCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    required this.subtitle,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      margin: EdgeInsets.only(bottom: isLarge ? 0 : 16),
      decoration: BoxDecoration(
        color: _ProfileActivityState._surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ProfileActivityState._borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 28 : (isSmallScreen ? 16 : 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y valor - Mejorado para dispositivos pequeños
            if (isSmallScreen) ...[
              // Layout vertical para pantallas muy pequeñas
              Text(
                title,
                style: TextStyle(
                  fontSize: isLarge ? 18 : 15,
                  fontWeight: FontWeight.w600,
                  color: _ProfileActivityState._textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _ProfileActivityState._primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _ProfileActivityState._primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: _ProfileActivityState._primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ] else ...[
              // Layout horizontal para pantallas normales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: _ProfileActivityState._textPrimary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _ProfileActivityState._primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _ProfileActivityState._primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: isLarge ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: _ProfileActivityState._primaryColor,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isLarge ? 20 : 16),
            
            // Barra de progreso
            Container(
              width: double.infinity,
              height: isLarge ? 12 : 10,
              decoration: BoxDecoration(
                color: _ProfileActivityState._borderColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(isLarge ? 6 : 5),
              ),
              child: Stack(
                children: [
                  // Barra de progreso
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _ProfileActivityState._primaryColor,
                            _ProfileActivityState._primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isLarge ? 6 : 5),
                        boxShadow: [
                          BoxShadow(
                            color: _ProfileActivityState._primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isLarge ? 16 : 12),
            
            // Subtítulo con porcentaje - Mejorado para dispositivos pequeños
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isLarge ? 14 : (isSmallScreen ? 11 : 12),
                      color: _ProfileActivityState._textSecondary,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: isSmallScreen ? 2 : 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: isLarge ? 14 : (isSmallScreen ? 11 : 12),
                    fontWeight: FontWeight.w600,
                    color: _ProfileActivityState._primaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}