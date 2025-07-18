import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
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

  final List<Map<String, String>> _idiomas = [
    {'value': 'zapoteco', 'label': 'Zapoteco'},
    {'value': 'tzeltal', 'label': 'Tzeltal'},
    {'value': 'maya', 'label': 'Maya'},
    {'value': 'nahuatl', 'label': 'Náhuatl'},
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
                if (viewModel.state.status == RegistrationStatus.success && mounted) {
                  print('✅ Registration successful in UI, navigating to home...');
                }
              });

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                               MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Status Bar simulada
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('9:41', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('••• ○○', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text('100%', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Header
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Crear Cuenta',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Únete a la comunidad Nativox',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Formulario
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                  // Estados de loading/success/error
                                  _buildStatusIndicator(viewModel),
                                  
                                  // ✅ CAMPOS ACTUALIZADOS SEGÚN TU API
                                  // Nombre
                                  _buildTextField(
                                    controller: _nombreController,
                                    label: 'Nombre',
                                    icon: Icons.person_outline,
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Apellido
                                  _buildTextField(
                                    controller: _apellidoController,
                                    label: 'Apellido',
                                    icon: Icons.person_outline,
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Email con verificación
                                  _buildEmailField(viewModel),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Teléfono (requerido)
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Teléfono',
                                    icon: Icons.phone_outlined,
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Idioma preferido
                                  _buildIdiomaDropdown(),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Contraseña
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFFD4A574),
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Confirmar contraseña
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirmar contraseña',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                        color: const Color(0xFFD4A574),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Botón de registro
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: viewModel.state.status == RegistrationStatus.loading
                                          ? null
                                          : () => _handleRegistration(viewModel),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD4A574),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: viewModel.state.status == RegistrationStatus.loading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Crear cuenta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Footer
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(
                                onPressed: () => context.go(RouteNames.login),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: '¿Ya tienes cuenta? ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
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

  Widget _buildIdiomaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Idioma preferido',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedIdioma,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.language,
              color: Color(0xFFD4A574),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4A574), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: _idiomas.map((idioma) {
            return DropdownMenuItem<String>(
              value: idioma['value'],
              child: Text(idioma['label']!),
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

  // Resto de métodos helper (sin cambios importantes)
  Widget _buildStatusIndicator(RegistrationViewModel viewModel) {
    // ... mismo código que antes
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
      