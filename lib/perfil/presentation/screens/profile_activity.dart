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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${viewModel.state.errorMessage}',
                        style: TextStyle(color: Colors.red[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => viewModel.loadProfile(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final profile = viewModel.state.userProfile!;

              return Column(
                children: [
                  // Status Bar
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:41',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '••• ○○',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '100%',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                    child: Stack(
                      children: [
                        // Patrón cultural
                        Positioned.fill(
                          child: CustomPaint(painter: CulturalPatternPainter()),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                          child: Column(
                            children: [
                              // Avatar y nivel
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFF8F8F8),
                                        ],
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
                                    child: const Center(
                                      child: Text(
                                        '👤',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    right: -5,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4CAF50),
                                            Color(0xFF45A049),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${profile.level}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Nombre y título
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profile.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Estadísticas rápidas
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                    ),
                  ),

                  // Contenido scrolleable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logros
                          const _SectionTitle(
                            icon: '🏆',
                            title: 'Logros recientes',
                          ),
                          const SizedBox(height: 15),
                          AchievementGridWidget(
                            achievements: viewModel.state.achievements,
                          ),
                          const SizedBox(height: 30),

                          // Progreso
                          const _SectionTitle(icon: '📊', title: 'Progreso'),
                          const SizedBox(height: 15),
                          ProgressCardWidget(
                            title: 'Nivel actual',
                            value: 'Nivel ${profile.level}',
                            progress: profile.levelProgress,
                            subtitle:
                                '${profile.currentXP} / ${profile.nextLevelXP} XP para nivel ${profile.level + 1}',
                          ),
                          ProgressCardWidget(
                            title: 'Vocabulario',
                            value: '${profile.vocabularyCount} palabras',
                            progress: profile.vocabularyProgress,
                            subtitle:
                                'Meta: ${profile.vocabularyGoal} palabras',
                          ),
                          const SizedBox(height: 30),

                          // Configuración
                          const _SectionTitle(
                            icon: '⚙️',
                            title: 'Configuración',
                          ),
                          const SizedBox(height: 15),
                          Container(
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
                              children:
                                  viewModel.state.settings.map((setting) {
                                    final isLast =
                                        setting ==
                                        viewModel.state.settings.last;
                                    return _SettingItem(
                                      setting: setting,
                                      isLast: isLast,
                                      onTap:
                                          () => viewModel.onSettingTapped(
                                            setting,
                                          ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Botón de cerrar sesión
                          Consumer<LoginViewModel>(
                            builder:
                                (context, loginViewModel, _) => SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Color(0xFFD4A574),
                                    ),
                                    label: const Text(
                                      'Cerrar sesión',
                                      style: TextStyle(
                                        color: Color(0xFFD4A574),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFD4A574),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await loginViewModel.signOut();
                                    },
                                  ),
                                ),
                          ),
                          const SizedBox(
                            height: 100,
                          ), // Espacio para bottom nav
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // ✅ NAVBAR PERSONALIZADO IMPORTADO
    );
  }
}

// ============================================
// CUSTOM PAINTER PARA PATRÓN CULTURAL
// ============================================

class CulturalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFD4A574).withOpacity(0.05)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    const double spacing = 20;

    // Líneas diagonales para crear patrón cultural
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
// WIDGETS AUXILIARES
// ============================================

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;

  const _QuickStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
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
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final SettingItem setting;
  final bool isLast;
  final VoidCallback onTap;

  const _SettingItem({
    required this.setting,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top:
              setting.id ==
                      '1' // Primer elemento
                  ? const Radius.circular(20)
                  : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border:
                isLast
                    ? null
                    : const Border(
                      bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                    ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A574).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    setting.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      setting.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// WIDGETS PARA ACHIEVEMENTS Y PROGRESS
// ============================================

class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementGridWidget({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementItem(achievement: achievement);
      },
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;

  const _AchievementItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              achievement.isUnlocked
                  ? const Color(0xFFD4A574)
                  : Colors.transparent,
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
          borderRadius: BorderRadius.circular(16),
          onTap: achievement.isUnlocked ? () {} : null,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 24,
                    color: achievement.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color:
                        achievement.isUnlocked
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  const ProgressCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4A574),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}
