import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/registration_request_model.dart';
import '../model/registration_response_model.dart';


abstract class RegistrationDataSource {
  Future<RegistrationResponseModel> registerWithEmailAndPassword(
    RegistrationRequestModel request
  );
  Future<bool> checkEmailAvailability(String email);
}

class RegistrationDataSourceImpl implements RegistrationDataSource {
  static const String _baseUrl = 'https://a3pl892azf.execute-api.us-east-1.amazonaws.com/micro-user/api_user';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<RegistrationResponseModel> registerWithEmailAndPassword(
    RegistrationRequestModel request
  ) async {
    try {
      print('🔄 RegistrationDataSource: Creating user account');
      print('🔄 RegistrationDataSource: Request body: ${json.encode(request.toJson())}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/usuarios/registrar'), 
        headers: _headers,
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 RegistrationDataSource: API Response status: ${response.statusCode}');
      print('📡 RegistrationDataSource: API Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        return RegistrationResponseModel.fromJson(responseData);
        
      } else if (response.statusCode == 409) {
        throw Exception('EMAIL_ALREADY_EXISTS');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Datos inválidos';
        throw Exception('INVALID_DATA: $errorMessage');
      } else {
        throw Exception('SERVER_ERROR: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ RegistrationDataSource: Exception: $e');
      
      if (e.toString().contains('EMAIL_ALREADY_EXISTS')) {
        throw Exception('EMAIL_ALREADY_EXISTS');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('NETWORK_ERROR');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('TIMEOUT_ERROR');
      } else {
        throw Exception('UNKNOWN_ERROR: ${e.toString()}');
      }
    }
  }

  @override
  Future<bool> checkEmailAvailability(String email) async {
    try {
      print('🔄 RegistrationDataSource: Checking email availability: $email');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/usuarios/check-email?email=$email'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      print('📡 RegistrationDataSource: Email check status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['available'] ?? true;
      } else if (response.statusCode == 409) {
        return false; // Email already taken
      } else {
        return true; // Assume available if can't check
      }
      
    } catch (e) {
      print('❌ RegistrationDataSource: Email check error: $e');
      return true; // Assume available if can't check
    }
  }
}