// lib/shared/screens/support_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/services/secure_storage_service.dart';
import 'package:integrador/global/services/support_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportService _supportService = SupportService();
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  
  // Variables de estado
  String _selectedCategory = 'general';
  String _selectedPriority = 'media';
  bool _isLoading = false;
  bool _isSending = false;
  
  // Colores
  static const Color _primaryColor = Color(0xFFD4A574);
  static const Color _backgroundColor = Color(0xFFF8F6F3);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF2C2C2C);
  static const Color _textSecondary = Color(0xFF666666);
  static const Color _borderColor = Color(0xFFE8E1DC);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      
      final userData = await SecureStorageService().getUserData();
      
      if (userData != null && mounted) {
        setState(() {
          _nombreController.text = userData['nombre'] ?? userData['name'] ?? '';
          _emailController.text = userData['email'] ?? userData['correo'] ?? '';
        });
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSupportMessage() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      setState(() => _isSending = true);
      
      final message = SupportMessageModel(
        usuarioId: (await SecureStorageService().getUserData())?['id'] ?? '',
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        asunto: _asuntoController.text.trim(),
        mensaje: _mensajeController.text.trim(),
        categoria: _selectedCategory,
        prioridad: _selectedPriority,
        fechaEnvio: DateTime.now(),
      );
      
      final success = await _supportService.sendSupportMessage(message);
      
      setState(() => _isSending = false);
      
      if (success) {
        _showSuccessDialog();
      } else {
        _showError('No se pudo enviar el mensaje. Intenta nuevamente.');
      }
      
    } catch (e) {
      print('❌ Error sending support message: $e');
      setState(() => _isSending = false);
      _showError('Error al enviar el mensaje: ${e.toString()}');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¡Mensaje Enviado!'),
        content: const Text(
          'Tu mensaje ha sido enviado exitosamente a nuestro equipo de soporte. Te responderemos por email lo antes posible.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
              context.go('/support'); // Volver a la pantalla de soporte
            },
            child: const Text('Volver a Soporte'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _asuntoController.clear();
    _mensajeController.clear();
    setState(() {
      _selectedCategory = 'general';
      _selectedPriority = 'media';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Ayuda y Soporte'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, 
          color: Colors.white, size: 20),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildContactCards(),
                    const SizedBox(height: 24),
                    _buildSupportForm(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactCards() {
    return Row(
      children: [
        Expanded(
          child: _buildContactCard(
            icon: Icons.email_rounded,
            title: 'Email',
            subtitle: 'soporte@nativox.com',
            color: Colors.blue,
            onTap: () => _launchEmail('soporte@nativox.com'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildContactCard(
            icon: Icons.phone_rounded,
            title: 'Teléfono',
            subtitle: '+52 961 123 4567',
            color: Colors.green,
            onTap: () => _launchPhone('+529611234567'),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportForm() {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enviar Mensaje',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Campos de información personal
              IntrinsicWidth(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Ingresa tu email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Categoría
              _buildDropdownField(
                label: 'Categoría',
                icon: Icons.category_outlined,
                value: _selectedCategory,
                items: _supportService.getSupportCategories(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Prioridad
              _buildDropdownField(
                label: 'Prioridad',
                icon: Icons.priority_high_outlined,
                value: _selectedPriority,
                items: _supportService.getPriorityLevels(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                isColorful: true,
              ),
              
              const SizedBox(height: 20),
              
              // Asunto
              _buildTextField(
                controller: _asuntoController,
                label: 'Asunto',
                icon: Icons.subject_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Ingresa el asunto';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Mensaje
              _buildTextField(
                controller: _mensajeController,
                label: 'Mensaje',
                icon: Icons.message_outlined,
                maxLines: 6,
                maxLength: 2000,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Ingresa tu mensaje';
                  }
                  if (value!.length < 10) {
                    return 'El mensaje debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botón enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendSupportMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSending
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Enviando...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Enviar Mensaje'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: _backgroundColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    bool isColorful = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: _backgroundColor.withOpacity(0.3),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isColorful) ...[
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(item['color'] ?? 0xFF666666),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Consulta desde Nativox App',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showError('No se pudo abrir el cliente de email');
      }
    } catch (e) {
      _showError('Error al abrir email: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showError('No se pudo realizar la llamada');
      }
    } catch (e) {
      _showError('Error al realizar llamada: $e');
    }
  }
}