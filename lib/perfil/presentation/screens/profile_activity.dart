// profile/presentation/screens/profile_activity.dart
import 'package:flutter/material.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/presentation/states/profile_state.dart';
import 'package:integrador/perfil/presentation/viewmodels/profile_viewmodel.dart';
import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:provider/provider.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';

class ProfileActivity extends StatefulWidget {
  const ProfileActivity({super.key});

  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;
    final isDesktop = screenSize.width > 1200;
    
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
          child: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.state.status == ProfileStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.state.status == ProfileStatus.error) {
                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 400 : double.infinity),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isTablet ? 80 : 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${viewModel.state.errorMessage}',
                          style: TextStyle(
                            color: Colors.red[600], 
                            fontSize: isTablet ? 18 : 16
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => viewModel.loadProfile(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final profile = viewModel.state.userProfile!;

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
      ),
    );
  }

  // Layout para Desktop
  Widget _buildDesktopLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return Row(
      children: [
        // Sidebar con perfil
        Container(
          width: 400,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            ),
          ),
          child: _buildProfileHeader(profile, screenSize, isDesktop: true),
        ),
        // Contenido principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildMainContent(context, viewModel, profile, screenSize, isDesktop: true),
            ),
          ),
        ),
      ],
    );
  }

  // Layout para Tablet
  Widget _buildTabletLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return Column(
      children: [
        // Header más compacto para tablet
        Container(
          height: screenSize.height * 0.4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            ),
          ),
          child: _buildProfileHeader(profile, screenSize, isTablet: true),
        ),
        // Contenido en grid para tablet
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: _buildMainContent(context, viewModel, profile, screenSize, isTablet: true),
          ),
        ),
      ],
    );
  }

  // Layout para Mobile
  Widget _buildMobileLayout(BuildContext context, ProfileViewModel viewModel, dynamic profile, Size screenSize) {
    return Column(
      children: [
        // Status Bar
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('9:41', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('••• ○○', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('100%', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            ),
          ),
          child: _buildProfileHeader(profile, screenSize),
        ),
        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildMainContent(context, viewModel, profile, screenSize),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(dynamic profile, Size screenSize, {bool isDesktop = false, bool isTablet = false}) {
    final avatarSize = isDesktop ? 120.0 : isTablet ? 100.0 : 100.0;
    final levelBadgeSize = isDesktop ? 50.0 : isTablet ? 45.0 : 40.0;
    final nameSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final titleSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return Stack(
      children: [
        // Patrón cultural
        Positioned.fill(
          child: CustomPaint(painter: CulturalPatternPainter()),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : isTablet ? 30 : 20,
            isDesktop ? 40 : isTablet ? 30 : 20,
            isDesktop ? 40 : isTablet ? 30 : 20,
            isDesktop ? 40 : isTablet ? 30 : 40,
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
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F8F8)],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '👤',
                        style: TextStyle(fontSize: avatarSize * 0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Container(
                      width: levelBadgeSize,
                      height: levelBadgeSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
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
              SizedBox(height: isDesktop ? 30 : 20),

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
              Text(
                profile.title,
                style: TextStyle(
                  fontSize: titleSize,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 30 : 20),

              // Estadísticas rápidas
              Container(
                padding: EdgeInsets.all(isDesktop ? 20 : 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isDesktop ? 
                  Column(
                    children: [
                      _QuickStat(
                        value: '${profile.activeDays}',
                        label: 'Días activos',
                        isVertical: true,
                      ),
                      const SizedBox(height: 20),
                      _QuickStat(
                        value: '${profile.totalXP}',
                        label: 'XP total',
                        isVertical: true,
                      ),
                      const SizedBox(height: 20),
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
                      _QuickStat(
                        value: '${profile.totalXP}',
                        label: 'XP total',
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
    final crossAxisCount = isDesktop ? 6 : isTablet ? 5 : 4;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logros
        _SectionTitle(
          icon: '🏆',
          title: 'Logros recientes',
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 20 : 15),
        AchievementGridWidget(
          achievements: viewModel.state.achievements,
          crossAxisCount: crossAxisCount,
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 40 : 30),

        // Progreso
        if (isDesktop || isTablet) ...[
          // Layout en grid para desktop/tablet
          _SectionTitle(
            icon: '📊',
            title: 'Progreso',
            isLarge: true,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 2 : 1,
            childAspectRatio: isDesktop ? 2.5 : 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              ProgressCardWidget(
                title: 'Nivel actual',
                value: 'Nivel ${profile.level}',
                progress: profile.levelProgress,
                subtitle: '${profile.currentXP} / ${profile.nextLevelXP} XP para nivel ${profile.level + 1}',
                isLarge: true,
              ),
              ProgressCardWidget(
                title: 'Vocabulario',
                value: '${profile.vocabularyCount} palabras',
                progress: profile.vocabularyProgress,
                subtitle: 'Meta: ${profile.vocabularyGoal} palabras',
                isLarge: true,
              ),
            ],
          ),
        ] else ...[
          // Layout vertical para móvil
          _SectionTitle(icon: '📊', title: 'Progreso'),
          const SizedBox(height: 15),
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
        
        SizedBox(height: isDesktop ? 40 : 30),

        // Configuración
        _SectionTitle(
          icon: '⚙️',
          title: 'Configuración',
          isLarge: isDesktop || isTablet,
        ),
        SizedBox(height: isDesktop ? 20 : 15),
        Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
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
        SizedBox(height: isDesktop ? 30 : 20),
        
        // Botón de cerrar sesión
        Consumer<LoginViewModel>(
          builder: (context, loginViewModel, _) => Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 300 : double.infinity,
            ),
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Color(0xFFD4A574)),
              label: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: const Color(0xFFD4A574),
                  fontWeight: FontWeight.w600,
                  fontSize: isDesktop || isTablet ? 16 : 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4A574)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop || isTablet ? 20 : 16,
                ),
              ),
              onPressed: () async {
                await loginViewModel.signOut();
              },
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 40 : 100),
      ],
    );
  }
}

// ============================================
// CUSTOM PAINTER PARA PATRÓN CULTURAL
// ============================================

class CulturalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A574).withOpacity(0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double spacing = 20;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// WIDGETS AUXILIARES RESPONSIVOS
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
            fontSize: isVertical ? 24 : 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isVertical ? 13 : 11,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
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
          width: 4,
          height: isLarge ? 24 : 20,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 10),
        Text(icon, style: TextStyle(fontSize: isLarge ? 22 : 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isLarge ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C2C2C),
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
            horizontal: isLarge ? 25 : 20,
            vertical: isLarge ? 22 : 18,
          ),
          decoration: BoxDecoration(
            border: isLast ? null : const Border(
              bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isLarge ? 48 : 40,
                height: isLarge ? 48 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    setting.icon,
                    style: TextStyle(fontSize: isLarge ? 22 : 18),
                  ),
                ),
              ),
              SizedBox(width: isLarge ? 20 : 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.title,
                      style: TextStyle(
                        fontSize: isLarge ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      setting.subtitle,
                      style: TextStyle(
                        fontSize: isLarge ? 14 : 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFFCCCCCC),
                size: isLarge ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS PARA ACHIEVEMENTS Y PROGRESS RESPONSIVOS
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
    // Calcular altura dinámica basada en número de filas
    final rows = (achievements.length / crossAxisCount).ceil();
    final itemHeight = isLarge ? 120.0 : 100.0;
    final spacing = isLarge ? 16.0 : 12.0;
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked ? const Color(0xFFD4A574) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: achievement.isUnlocked ? () {} : null,
          child: Padding(
            padding: EdgeInsets.all(isLarge ? 12 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: isLarge ? 24 : 20,
                        color: achievement.isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  flex: 2,
                  child: Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: isLarge ? 10 : 8,
                      fontWeight: FontWeight.w600,
                      color: achievement.isUnlocked ? const Color(0xFF2C2C2C) : Colors.grey,
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
    return Container(
      margin: EdgeInsets.only(bottom: isLarge ? 0 : 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 25 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLarge ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLarge ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4A574),
                  ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 20 : 15),
            Container(
              width: double.infinity,
              height: isLarge ? 10 : 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(isLarge ? 5 : 4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(isLarge ? 5 : 4),
                  ),
                ),
              ),
            ),
            SizedBox(height: isLarge ? 15 : 10),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isLarge ? 14 : 12,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}