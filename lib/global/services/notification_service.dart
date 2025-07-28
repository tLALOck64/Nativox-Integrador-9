// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:integrador/core/services/secure_storage_service.dart';

// ============================================
// MODELOS
// ============================================

class NotificationModel {
  final String id;
  final String usuarioId;
  final String mensaje;
  final bool leido;
  final DateTime fechaEnvio;

  NotificationModel({
    required this.id,
    required this.usuarioId,
    required this.mensaje,
    required this.leido,
    required this.fechaEnvio,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      mensaje: json['mensaje'] ?? '',
      leido: json['leido'] ?? false,
      fechaEnvio: DateTime.parse(json['fechaEnvio'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'mensaje': mensaje,
      'leido': leido,
      'fechaEnvio': fechaEnvio.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? usuarioId,
    String? mensaje,
    bool? leido,
    DateTime? fechaEnvio,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      mensaje: mensaje ?? this.mensaje,
      leido: leido ?? this.leido,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, usuarioId: $usuarioId, mensaje: ${mensaje.substring(0, mensaje.length > 50 ? 50 : mensaje.length)}..., leido: $leido, fechaEnvio: $fechaEnvio)';
  }
}

// ============================================
// SERVICIO DE NOTIFICACIONES
// ============================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // URL de tu API
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-user/api_user';
  
  // Cache para performance
  List<NotificationModel>? _cachedNotifications;
  DateTime? _lastFetch;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Headers dinámicos con token
  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService().getToken();
    print('🔑 Token para notificaciones: $token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // ✅ OBTENER TODAS LAS NOTIFICACIONES DEL USUARIO
  Future<List<NotificationModel>> getUserNotifications({bool forceRefresh = false}) async {
    try {
      // Verificar cache si no es refresh forzado
      if (!forceRefresh && 
          _cachedNotifications != null && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
        print('📱 Using cached notifications');
        return List.from(_cachedNotifications!);
      }

      print('🔄 Loading notifications from API...');
      
      // Obtener ID del usuario
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No se pudo obtener el ID del usuario');
        throw NotificationException('Usuario no identificado');
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/notificaciones/usuario/$userId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> jsonList = decoded['data'];
          
          final notifications = jsonList
              .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
              .toList();

          // Ordenar por fecha (más recientes primero)
          notifications.sort((a, b) => b.fechaEnvio.compareTo(a.fechaEnvio));

          // Guardar en cache
          _cachedNotifications = notifications;
          _lastFetch = DateTime.now();

          print('✅ Notifications loaded successfully: ${notifications.length}');
          return notifications;
        } else {
          print('⚠️ Response structure invalid or success=false');
          return [];
        }
        
      } else if (response.statusCode == 404) {
        print('📝 No notifications found for user');
        return [];
        
      } else if (response.statusCode == 401) {
        print('🔑 Token expired or invalid (401)');
        throw NotificationException('Token de autenticación expirado. Por favor, inicia sesión nuevamente.');
        
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        throw NotificationException('Error HTTP: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      
      // Usar cache si está disponible en caso de error
      if (_cachedNotifications != null) {
        print('📱 Using cached notifications due to error');
        return List.from(_cachedNotifications!);
      }
      
      if (e is NotificationException) {
        rethrow;
      }
      
      throw NotificationException('Error al cargar las notificaciones: ${e.toString()}');
    }
  }

  // ✅ MARCAR NOTIFICACIÓN COMO LEÍDA (ENDPOINT CORREGIDO)
  Future<bool> markAsRead(String notificationId) async {
    try {
      print('📖 Marking notification as read: $notificationId');
      
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/notificaciones/marcar-leida/$notificationId'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Notification marked as read successfully');
        
        // Actualizar cache local
        if (_cachedNotifications != null) {
          final index = _cachedNotifications!.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            _cachedNotifications![index] = _cachedNotifications![index].copyWith(leido: true);
            print('📱 Cache updated locally');
          }
        }
        
        return true;
      } else {
        print('❌ Error marking notification as read: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  // ✅ MARCAR TODAS LAS NOTIFICACIONES COMO LEÍDAS
  Future<bool> markAllAsRead() async {
    try {
      print('📖 Marking all notifications as read');
      
      final userData = await SecureStorageService().getUserData();
      final userId = userData?['id'] ?? userData?['uid'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No se pudo obtener el ID del usuario');
        return false;
      }

      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/notificaciones/usuario/$userId/leer-todas'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ All notifications marked as read successfully');
        
        // Actualizar cache local
        if (_cachedNotifications != null) {
          _cachedNotifications = _cachedNotifications!
              .map((notification) => notification.copyWith(leido: true))
              .toList();
          print('📱 All notifications updated in cache');
        }
        
        return true;
      } else {
        print('❌ Error marking all notifications as read: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  // ✅ OBTENER CANTIDAD DE NOTIFICACIONES NO LEÍDAS
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getUserNotifications();
      final unreadCount = notifications.where((n) => !n.leido).length;
      print('📊 Unread notifications count: $unreadCount');
      return unreadCount;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // ✅ OBTENER SOLO NOTIFICACIONES NO LEÍDAS
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final notifications = await getUserNotifications();
      return notifications.where((n) => !n.leido).toList();
    } catch (e) {
      print('❌ Error getting unread notifications: $e');
      return [];
    }
  }

  // ✅ LIMPIAR CACHE
  void clearCache() {
    _cachedNotifications = null;
    _lastFetch = null;
    print('🗑️ Notifications cache cleared');
  }

  // ✅ VERIFICAR CONECTIVIDAD
  Future<bool> checkApiConnectivity() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/notificaciones/ping'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Notification API connectivity check failed: $e');
      return false;
    }
  }

  // ✅ OBTENER INFO DEL CACHE
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCache': _cachedNotifications != null,
      'cacheSize': _cachedNotifications?.length ?? 0,
      'lastFetch': _lastFetch?.toIso8601String(),
      'cacheValidUntil': _lastFetch?.add(_cacheValidDuration).toIso8601String(),
      'isCacheValid': _cachedNotifications != null && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration,
    };
  }

  // ✅ FORZAR RECARGA DESDE API
  Future<List<NotificationModel>> forceRefresh() async {
    clearCache();
    return await getUserNotifications(forceRefresh: true);
  }
}

// ============================================
// EXCEPCIONES PERSONALIZADAS
// ============================================

class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NotificationException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'NotificationException: $message';
}

class NotificationNotFoundException extends NotificationException {
  const NotificationNotFoundException(String notificationId) 
      : super('Notificación no encontrada: $notificationId');
}

class NotificationPermissionException extends NotificationException {
  const NotificationPermissionException() 
      : super('No tienes permisos para acceder a estas notificaciones');
}