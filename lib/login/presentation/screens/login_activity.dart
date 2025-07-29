import 'package:flutter/material.dart';
import 'package:integrador/login/presentation/states/login_state.dart';
import 'package:integrador/login/presentation/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;

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
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.state.status == LoginStatus.success && mounted) {
                  print('✅ Login successful in UI, navigating to home...');

                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      context.go(RouteNames.home);
                    }
                  });
                }
              });

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        screenSize.height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isSmallScreen
                                ? 16
                                : isMediumScreen
                                ? 32
                                : 48,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: isSmallScreen ? 20 : 40),

                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    isSmallScreen
                                        ? 8
                                        : isMediumScreen
                                        ? 16
                                        : 24,
                              ),
                              padding: EdgeInsets.all(
                                isSmallScreen
                                    ? 20
                                    : isMediumScreen
                                    ? 24
                                    : 32,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 16 : 20,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width:
                                              isSmallScreen
                                                  ? 100
                                                  : isMediumScreen
                                                  ? 120
                                                  : 140,
                                          height:
                                              isSmallScreen
                                                  ? 100
                                                  : isMediumScreen
                                                  ? 120
                                                  : 140,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              isSmallScreen ? 12 : 16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              isSmallScreen ? 16 : 18,
                                            ),
                                            child: Image.asset(
                                              'assets/icon/logo.png',
                                              fit: BoxFit.contain,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: const Text(
                                                    'nativox',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFFD4A574),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Bienvenido',
                                          style: TextStyle(
                                            fontSize:
                                                isSmallScreen
                                                    ? 20
                                                    : isMediumScreen
                                                    ? 22
                                                    : 24,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2C2C2C),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Inicia sesión para continuar tu aprendizaje',
                                          style: TextStyle(
                                            fontSize:
                                                isSmallScreen
                                                    ? 12
                                                    : isMediumScreen
                                                    ? 13
                                                    : 14,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 24 : 32),

                                  if (viewModel.state.status ==
                                      LoginStatus.loading)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFD4A574,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFD4A574,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color(0xFFD4A574),
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Iniciando sesión...',
                                            style: TextStyle(
                                              color: Color(0xFFD4A574),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (viewModel.state.status ==
                                      LoginStatus.success)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            '¡Login exitoso! Redirigiendo...',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (viewModel.state.status ==
                                      LoginStatus.error)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red[200]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              viewModel.state.errorMessage ??
                                                  'Error desconocido',
                                              style: TextStyle(
                                                color: Colors.red[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  _buildResponsiveTextField(
                                    controller: _emailController,
                                    label: 'Correo electrónico',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu correo electrónico';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Correo electrónico inválido';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),
                                  _buildResponsivePasswordField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 24 : 32),
                                  SizedBox(
                                    width: double.infinity,
                                    height: isSmallScreen ? 48 : 56,
                                    child: ElevatedButton(
                                      onPressed:
                                          viewModel.state.status ==
                                                  LoginStatus.loading
                                              ? null
                                              : () =>
                                                  _handleEmailLogin(viewModel),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFD4A574,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen ? 12 : 16,
                                          ),
                                        ),
                                      ),
                                      child:
                                          viewModel.state.status ==
                                                  LoginStatus.loading
                                              ? SizedBox(
                                                width: isSmallScreen ? 20 : 24,
                                                height: isSmallScreen ? 20 : 24,
                                                child:
                                                    const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                              : Text(
                                                'Continuar',
                                                style: TextStyle(
                                                  fontSize:
                                                      isSmallScreen
                                                          ? 14
                                                          : isMediumScreen
                                                          ? 15
                                                          : 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 20 : 24),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(color: Colors.grey[300]),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 16 : 20,
                                        ),
                                        child: Text(
                                          'o',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(color: Colors.grey[300]),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: isSmallScreen ? 20 : 24),

                                  SizedBox(
                                    width: double.infinity,
                                    height: isSmallScreen ? 48 : 56,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          viewModel.state.status ==
                                                  LoginStatus.loading
                                              ? null
                                              : () {
                                                print(
                                                  '🔄 Google button pressed',
                                                );
                                                viewModel.signInWithGoogle();
                                              },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen ? 12 : 16,
                                          ),
                                        ),
                                      ),
                                      icon: Container(
                                        width: isSmallScreen ? 20 : 24,
                                        height: isSmallScreen ? 20 : 24,
                                        decoration: BoxDecoration(
                                          color: Colors.red[400],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.g_mobiledata,
                                          color: Colors.white,
                                          size: isSmallScreen ? 16 : 18,
                                        ),
                                      ),
                                      label: Text(
                                        'Continuar con Google',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize:
                                              isSmallScreen
                                                  ? 14
                                                  : isMediumScreen
                                                  ? 15
                                                  : 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 16 : 20,
                              ),
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      context.go(RouteNames.register);
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: '¿No tienes cuenta? ',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize:
                                              isSmallScreen
                                                  ? 16
                                                  : isMediumScreen
                                                  ? 17
                                                  : 18,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Crear cuenta',
                                            style: TextStyle(
                                              color: const Color(0xFFD4A574),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  TextButton(
                                    onPressed: () {
                                      _launchPrivacyPolicy();
                                    },
                                    child: Text(
                                      'Aviso de Privacidad',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: isSmallScreen ? 15 : 16,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
    required bool isMediumScreen,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 12
                    : isMediumScreen
                    ? 13
                    : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enableSuggestions: false,    
          autocorrect: false, 
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 14
                    : isMediumScreen
                    ? 15
                    : 16,
            color: const Color(0xFF2C2C2C),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFD4A574),
              size: isSmallScreen ? 18 : 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: const BorderSide(color: Color(0xFFD4A574), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsivePasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
    required bool isMediumScreen,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 12
                    : isMediumScreen
                    ? 13
                    : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2C2C2C),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          validator: validator,
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 14
                    : isMediumScreen
                    ? 15
                    : 16,
            color: const Color(0xFF2C2C2C),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFD4A574),
              size: isSmallScreen ? 18 : 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
                size: isSmallScreen ? 18 : 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: const BorderSide(color: Color(0xFFD4A574), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
        ),
      ],
    );
  }

  void _handleEmailLogin(LoginViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      print('🔄 Email login button pressed');
      viewModel.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _launchPrivacyPolicy() async {
    const url = 'https://nativox.lat/privacidad';

    try {
      final Uri uri = Uri.parse(url);

      await launchUrl(uri, mode: LaunchMode.externalApplication);

      print('🔗 Privacy policy opened successfully');
    } catch (e) {
      print('❌ Error launching privacy policy: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No se pudo abrir el enlace. Intenta copiar y pegar la URL en tu navegador.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Copiar URL',
              onPressed: () {
                print('URL to copy: $url');
              },
            ),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class CulturalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const double spacing = 15;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      20,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.8),
      15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HardwareSecureStorageService {
  static final HardwareSecureStorageService _instance = const HardwareSecureStorageService._internal();

  factory HardwareSecureStorageService() => _instance;

  HardwareSecureStorageService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEP_SHA256,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES256,
      requireKeyAuthorization: true,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device,
    requireAuthorization: true,
    ),
  );
  final LocalAuthNotifier _localAuth = LocalAuthNotifier();
}