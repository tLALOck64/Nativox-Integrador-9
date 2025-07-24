import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:integrador/login/domain/entities/user.dart' as domain;

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 
                   firebaseUser.email?.split('@').first ?? 
                   'Usuario',
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Nuevo: crear UserModel desde la respuesta del API de login
  factory UserModel.fromFirebaseApiJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '', // Puede que no venga, dejar string vacío
    );
  }

  // Convertir a entidad de dominio
  domain.User toEntity() {
    return domain.User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  // Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}
