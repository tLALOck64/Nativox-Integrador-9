import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../states/registration_state.dart';

class RegistrationActivity extends StatefulWidget {
  const RegistrationActivity({super.key});

  @override
  State<RegistrationActivity> createState() => _RegistrationActivityState();
}

class _RegistrationActivityState extends State<RegistrationActivity> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedIdioma = 'zapoteco'; // Default
  bool _acceptedTerms = false; // Checkbox para términos y condiciones

  final List<Map<String, String>> _idiomas = [
    {'value': 'zapoteco', 'label': 'Zapoteco'},
    {'value': 'tzeltal', 'label': 'Tzeltal'},
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          child: Consumer<RegistrationViewModel>(
            builder: (context, viewModel, child) {
              // Listener para navegación automática
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (viewModel.state.status == RegistrationStatus.success &&
                    mounted) {
                  print(
                    '✅ Registration successful in UI, navigating to home...',
                  );
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

                            // Header responsivo con logo
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
                                    ? 24
                                    : isMediumScreen
                                    ? 32
                                    : 40,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD4A574),
                                    Color(0xFFB8956A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 20 : 24,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Logo de Nativox
                                  Container(
                                    width:
                                        isSmallScreen
                                            ? 60
                                            : isMediumScreen
                                            ? 80
                                            : 100,
                                    height:
                                        isSmallScreen
                                            ? 60
                                            : isMediumScreen
                                            ? 80
                                            : 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        isSmallScreen ? 12 : 16,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        isSmallScreen ? 12 : 16,
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
                                            padding: const EdgeInsets.all(12),
                                            child: const Text(
                                              'nativox',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
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
                                    'Crear Cuenta',
                                    style: TextStyle(
                                      fontSize:
                                          isSmallScreen
                                              ? 24
                                              : isMediumScreen
                                              ? 26
                                              : 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Únete a la comunidad Nativox',
                                    style: TextStyle(
                                      fontSize:
                                          isSmallScreen
                                              ? 12
                                              : isMediumScreen
                                              ? 13
                                              : 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 24 : 32),

                            // Formulario responsivo
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
                                  _buildStatusIndicator(viewModel),

                                  _buildResponsiveTextField(
                                    controller: _nombreController,
                                    label: 'Nombre',
                                    icon: Icons.person_outline,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu nombre';
                                      }
                                      if (value.length < 2) {
                                        return 'Mínimo 2 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  // Apellido
                                  _buildResponsiveTextField(
                                    controller: _apellidoController,
                                    label: 'Apellido',
                                    icon: Icons.person_outline,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu apellido';
                                      }
                                      if (value.length < 2) {
                                        return 'Mínimo 2 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  // Email con verificación
                                  _buildResponsiveEmailField(
                                    viewModel,
                                    isSmallScreen,
                                    isMediumScreen,
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  // Teléfono (requerido)
                                  _buildResponsiveTextField(
                                    controller: _phoneController,
                                    label: 'Teléfono',
                                    icon: Icons.phone_outlined,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu teléfono';
                                      }
                                      if (value.length < 10) {
                                        return 'Mínimo 10 dígitos';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  _buildResponsiveIdiomaDropdown(
                                    isSmallScreen,
                                    isMediumScreen,
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  _buildResponsiveTextField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFFD4A574),
                                        size: isSmallScreen ? 18 : 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa una contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  _buildResponsiveTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirmar contraseña',
                                    icon: Icons.lock_outline,
                                    isSmallScreen: isSmallScreen,
                                    isMediumScreen: isMediumScreen,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color(0xFFD4A574),
                                        size: isSmallScreen ? 18 : 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirma tu contraseña';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),

                                  SizedBox(height: isSmallScreen ? 24 : 32),

                                  // Checkbox de términos y condiciones
                                  Container(
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: isSmallScreen ? 20 : 24,
                                          height: isSmallScreen ? 20 : 24,
                                          child: Checkbox(
                                            value: _acceptedTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _acceptedTerms = value ?? false;
                                              });
                                            },
                                            activeColor: const Color(
                                              0xFFD4A574,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 8 : 12),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize:
                                                    isSmallScreen ? 12 : 13,
                                                color: Colors.grey[700],
                                                height: 1.4,
                                              ),
                                              children: [
                                                TextSpan(text: 'Acepto los '),
                                                TextSpan(
                                                  text:
                                                      'Términos y Condiciones',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFD4A574,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _launchTermsAndConditions();
                                                        },
                                                ),
                                                TextSpan(text: ' y el '),
                                                TextSpan(
                                                  text: 'Aviso de Privacidad',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFD4A574,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _launchPrivacyPolicy();
                                                        },
                                                ),
                                                TextSpan(text: ' de Nativox'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: isSmallScreen ? 16 : 20),

                                  SizedBox(
                                    width: double.infinity,
                                    height: isSmallScreen ? 48 : 56,
                                    child: ElevatedButton(
                                      onPressed:
                                          viewModel.state.status ==
                                                  RegistrationStatus.loading
                                              ? null
                                              : () => _handleRegistration(
                                                viewModel,
                                              ),
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
                                                  RegistrationStatus.loading
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
                                                'Crear cuenta',
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
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Footer responsivo
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 16 : 20,
                              ),
                              child: TextButton(
                                onPressed: () => context.go(RouteNames.login),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: '¿Ya tienes cuenta? ',
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
                                        text: 'Iniciar sesión',
                                        style: TextStyle(
                                          color: const Color(0xFFD4A574),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  Widget _buildResponsiveIdiomaDropdown(
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Idioma preferido',
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
        DropdownButtonFormField<String>(
          value: _selectedIdioma,
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
              Icons.language,
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
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
          items:
              _idiomas.map((idioma) {
                return DropdownMenuItem<String>(
                  value: idioma['value'],
                  child: Text(
                    idioma['label']!,
                    style: TextStyle(
                      fontSize:
                          isSmallScreen
                              ? 14
                              : isMediumScreen
                              ? 15
                              : 16,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedIdioma = value!;
            });
          },
        ),
      ],
    );
  }

  // Métodos helper
  Widget _buildStatusIndicator(RegistrationViewModel viewModel) {
    if (viewModel.state.status == RegistrationStatus.loading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4A574).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Creando tu cuenta...',
              style: TextStyle(
                color: Color(0xFFD4A574),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.state.status == RegistrationStatus.success) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Text(
              '¡Cuenta creada exitosamente!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.state.status == RegistrationStatus.error) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.state.errorMessage ?? 'Error desconocido',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
    required bool isMediumScreen,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
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
            suffixIcon: suffixIcon,
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

  Widget _buildResponsiveEmailField(
    RegistrationViewModel viewModel,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
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
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize:
                isSmallScreen
                    ? 14
                    : isMediumScreen
                    ? 15
                    : 16,
            color: const Color(0xFF2C2C2C),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              viewModel.checkEmailAvailability(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Ingresa un email válido';
            }
            if (!viewModel.state.isEmailAvailable &&
                viewModel.state.isEmailChecked) {
              return 'Este email ya está registrado';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: const Color(0xFFD4A574),
              size: isSmallScreen ? 18 : 20,
            ),
            suffixIcon:
                viewModel.state.status == RegistrationStatus.checkingEmail
                    ? SizedBox(
                      width: isSmallScreen ? 18 : 20,
                      height: isSmallScreen ? 18 : 20,
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4A574),
                          ),
                        ),
                      ),
                    )
                    : viewModel.state.isEmailChecked
                    ? Icon(
                      viewModel.state.isEmailAvailable
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          viewModel.state.isEmailAvailable
                              ? Colors.green
                              : Colors.red,
                      size: isSmallScreen ? 18 : 20,
                    )
                    : null,
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

  void _handleRegistration(RegistrationViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      // Verificar que se aceptaron los términos
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes aceptar los términos y condiciones para continuar',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      viewModel.registerWithEmail(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        contrasena: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        idiomaPreferido: _selectedIdioma,
      );
    }
  }

  void _launchPrivacyPolicy() async {
    const url = 'https://nativox.lat/privacidad';

    try {
      // Usar un enfoque más simple
      final Uri uri = Uri.parse(url);

      // Intentar abrir sin verificar primero
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      print('🔗 Privacy policy opened successfully');
    } catch (e) {
      print('❌ Error launching privacy policy: $e');

      // Mostrar mensaje de error más amigable
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
                // Aquí podrías implementar copiar al portapapeles
                print('URL to copy: $url');
              },
            ),
          ),
        );
      }
    }
  }

  void _launchTermsAndConditions() async {
    const url = 'https://nativox.lat/privacidad'; // Por ahora usa la misma URL

    try {
      // Usar un enfoque más simple
      final Uri uri = Uri.parse(url);

      // Intentar abrir sin verificar primero
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      print('🔗 Terms and conditions opened successfully');
    } catch (e) {
      print('❌ Error launching terms and conditions: $e');

      // Mostrar mensaje de error más amigable
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
                // Aquí podrías implementar copiar al portapapeles
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
