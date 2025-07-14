import 'package:integrador/perfil/domain/entities/achievement.dart';
import 'package:integrador/perfil/domain/entities/sentting_item.dart';
import 'package:integrador/perfil/domain/entities/user_profile.dart';

enum ProfileStatus { loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? userProfile;
  final List<Achievement> achievements;
  final List<SettingItem> settings;
  final String? errorMessage;

  const ProfileState({
    required this.status,
    this.userProfile,
    this.achievements = const [],
    this.settings = const [],
    this.errorMessage,
  });

  factory ProfileState.loading() {
    return const ProfileState(status: ProfileStatus.loading);
  }

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? userProfile,
    List<Achievement>? achievements,
    List<SettingItem>? settings,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userProfile: userProfile ?? this.userProfile,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
