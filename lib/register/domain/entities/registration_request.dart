class RegistrationRequest {
  final String nombre;
  final String apellido;
  final String email;
  final String phone;
  final String contrasena;
  final String idiomaPreferido;
  final String? fcmToken;

  const RegistrationRequest({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.phone,
    required this.contrasena,
    required this.idiomaPreferido,
    this.fcmToken,
  });
}
