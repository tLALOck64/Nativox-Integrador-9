// lib/shared/services/support_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/services/secure_storage_service.dart';

// ============================================
// MODELOS
// ============================================

class SupportMessageModel {
  final String? id;
  final String usuarioId;
  final String nombre;
  final String email;
  final String asunto;
  final String mensaje;
  final String categoria;
  final String prioridad;
  final DateTime fechaEnvio;
  final String estado; // 'enviado', 'en_proceso', 'resuelto'

  SupportMessageModel({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.email,
    required this.asunto,
    required this.mensaje,
    required this.categoria,
    required this.prioridad,
    required this.fechaEnvio,
    this.estado = 'enviado',
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'],
      usuarioId: json['usuarioId'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      asunto: json['asunto'] ?? '',
      mensaje: json['mensaje'] ?? '',
      categoria: json['categoria'] ?? 'general',
      prioridad: json['prioridad'] ?? 'media',
      fechaEnvio: DateTime.parse(json['fechaEnvio'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? 'enviado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'email': email,
      'asunto': asunto,
      'mensaje': mensaje,
      'categoria': categoria,
      'prioridad': prioridad,
      'fechaEnvio': fechaEnvio.toIso8601String(),
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'SupportMessageModel(id: $id, nombre: $nombre, email: $email, asunto: $asunto, categoria: $categoria, prioridad: $prioridad, estado: $estado)';
  }
}

// ============================================
// SERVICIO DE SOPORTE
// ============================================

class SupportService {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  // URL de tu API (ajusta según tu backend)
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-learning/api_learning';
  
  // Email de soporte (puedes configurarlo)
  static const String _supportEmail = 'soporte@nativox.com';

  // Headers dinámicos con token
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService().getToken();
    print('🔑 Token para soporte: $token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ✅ ENVIAR MENSAJE DE SOPORTE
  Future<bool> sendSupportMessage(SupportMessageModel message) async {
    try {
      print('📤 Sending support message...');
      print('📤 Subject: ${message.asunto}');
      print('📤 Category: ${message.categoria}');
      print('📤 Priority: ${message.prioridad}');
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/soporte/mensaje'),
        headers: headers,
        body: json.encode(message.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Support message sent successfully');
        return true;
      } else {
        print('❌ Error sending support message: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error sending support message: $e');
      return false;
    }
  }

  // ✅ ENVIAR EMAIL DIRECTO (ALTERNATIVA)
  Future<bool> sendEmailDirect({
    required String nombre,
    required String email,
    required String asunto,
    required String mensaje,
    required String categoria,
    required String prioridad,
  }) async {
    try {
      print('📧 Sending direct email...');
      
      final headers = await _getHeaders();
      
      // Obtener datos del usuario para contexto
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? 'unknown';
      
      final emailData = {
        'to': _supportEmail,
        'subject': '[$categoria] $asunto',
        'html': _buildEmailTemplate(
          nombre: nombre,
          email: email,
          asunto: asunto,
          mensaje: mensaje,
          categoria: categoria,
          prioridad: prioridad,
          userId: userId,
        ),
        'priority': prioridad,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/email/send'),
        headers: headers,
        body: json.encode(emailData),
      ).timeout(const Duration(seconds: 30));

      print('📊 Email response status: ${response.statusCode}');
      print('📊 Email response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Email sent successfully');
        return true;
      } else {
        print('❌ Error sending email: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  // ✅ OBTENER HISTORIAL DE MENSAJES DEL USUARIO
  Future<List<SupportMessageModel>> getUserSupportHistory() async {
    try {
      print('📱 Loading user support history...');
      
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No user ID found');
        return [];
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/soporte/usuario/$userId/mensajes'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 History response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> jsonList = decoded['data'];
          
          final messages = jsonList
              .map((json) => SupportMessageModel.fromJson(json as Map<String, dynamic>))
              .toList();

          // Ordenar por fecha (más recientes primero)
          messages.sort((a, b) => b.fechaEnvio.compareTo(a.fechaEnvio));

          print('✅ Support history loaded: ${messages.length} messages');
          return messages;
        }
      } else if (response.statusCode == 404) {
        print('📝 No support history found');
        return [];
      }
      
      print('❌ Error loading support history: ${response.statusCode}');
      return [];
      
    } catch (e) {
      print('❌ Error loading support history: $e');
      return [];
    }
  }

  // ✅ OBTENER INFORMACIÓN DE CONTACTO
  Map<String, dynamic> getContactInfo() {
    return {
      'email': _supportEmail,
      'phone': '+52 961 123 4567',
      'whatsapp': '+52 961 123 4567',
      'website': 'https://nativox.com',
      'address': 'Tuxtla Gutiérrez, Chiapas, México',
      'hours': 'Lunes a Viernes: 9:00 AM - 6:00 PM',
    };
  }

  // ✅ OBTENER CATEGORÍAS DISPONIBLES
  List<Map<String, dynamic>> getSupportCategories() {
    return [
      {
        'id': 'tecnico',
        'name': 'Problema Técnico',
        'icon': 'bug_report',
        'description': 'Errores, fallos o problemas de funcionamiento',
      },
      {
        'id': 'cuenta',
        'name': 'Mi Cuenta',
        'icon': 'account_circle',
        'description': 'Problemas con login, perfil o configuración',
      },
      {
        'id': 'contenido',
        'name': 'Contenido',
        'icon': 'library_books',
        'description': 'Lecciones, ejercicios o material de aprendizaje',
      },
      {
        'id': 'sugerencia',
        'name': 'Sugerencia',
        'icon': 'lightbulb',
        'description': 'Ideas para mejorar la aplicación',
      },
      {
        'id': 'facturacion',
        'name': 'Facturación',
        'icon': 'receipt',
        'description': 'Problemas con pagos o suscripciones',
      },
      {
        'id': 'general',
        'name': 'Consulta General',
        'icon': 'help',
        'description': 'Otras dudas o consultas',
      },
    ];
  }

  // ✅ OBTENER NIVELES DE PRIORIDAD
  List<Map<String, dynamic>> getPriorityLevels() {
    return [
      {
        'id': 'baja',
        'name': 'Baja',
        'color': 0xFF4CAF50,
        'description': 'No es urgente, puede esperar',
      },
      {
        'id': 'media',
        'name': 'Media',
        'color': 0xFFFF9800,
        'description': 'Importante pero no crítico',
      },
      {
        'id': 'alta',
        'name': 'Alta',
        'color': 0xFFF44336,
        'description': 'Urgente, necesita atención rápida',
      },
    ];
  }

  // ✅ CONSTRUIR TEMPLATE DE EMAIL
  String _buildEmailTemplate({
    required String nombre,
    required String email,
    required String asunto,
    required String mensaje,
    required String categoria,
    required String prioridad,
    required String userId,
  }) {
    final now = DateTime.now();
    final fecha = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Mensaje de Soporte - Nativox</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: #D4A574; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
            .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }
            .info-box { background: white; padding: 15px; margin: 10px 0; border-left: 4px solid #D4A574; }
            .priority-high { border-left-color: #F44336; }
            .priority-medium { border-left-color: #FF9800; }
            .priority-low { border-left-color: #4CAF50; }
            .message-content { background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border: 1px solid #ddd; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2>🆘 Nuevo Mensaje de Soporte</h2>
                <p>Recibido desde la aplicación Nativox</p>
            </div>
            <div class="content">
                <div class="info-box priority-${prioridad.toLowerCase()}">
                    <h3>📋 Información del Usuario</h3>
                    <p><strong>Nombre:</strong> $nombre</p>
                    <p><strong>Email:</strong> $email</p>
                    <p><strong>ID Usuario:</strong> $userId</p>
                    <p><strong>Fecha:</strong> $fecha</p>
                </div>
                
                <div class="info-box">
                    <h3>🏷️ Detalles del Caso</h3>
                    <p><strong>Categoría:</strong> $categoria</p>
                    <p><strong>Prioridad:</strong> $prioridad</p>
                    <p><strong>Asunto:</strong> $asunto</p>
                </div>
                
                <div class="message-content">
                    <h3>💬 Mensaje del Usuario</h3>
                    <p>$mensaje</p>
                </div>
                
                <div class="info-box">
                    <h3>🔧 Información Técnica</h3>
                    <p><strong>Plataforma:</strong> Flutter Mobile App</p>
                    <p><strong>Versión:</strong> 1.0.0</p>
                    <p><strong>Timestamp:</strong> ${DateTime.now().toIso8601String()}</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  // ✅ VERIFICAR CONECTIVIDAD
  Future<bool> checkApiConnectivity() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/soporte/ping'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Support API connectivity check failed: $e');
      return false;
    }
  }
}

// ============================================
// EXCEPCIONES PERSONALIZADAS
// ============================================

class SupportServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const SupportServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SupportServiceException: $message';
}

class SupportMessageTooLongException extends SupportServiceException {
  const SupportMessageTooLongException() 
      : super('El mensaje es demasiado largo. Máximo 2000 caracteres.');
}

class SupportInvalidEmailException extends SupportServiceException {
  const SupportInvalidEmailException() 
      : super('El formato del email no es válido.');
}