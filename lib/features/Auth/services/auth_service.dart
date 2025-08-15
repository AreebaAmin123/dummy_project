import 'package:boilerplate_flutter/core/config/app_config.dart';
import 'package:boilerplate_flutter/core/services/base_api_service.dart';

class AuthService extends BaseApiService {
  final AppConfig _config = AppConfig();

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // For testing with jsonplaceholder
    if (_config.baseUrl.contains('jsonplaceholder')) {
      // Simulate successful signup
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return {
        'success': true,
        'data': {
          'message': 'Account created successfully',
          'user': {'name': name, 'email': email}
        }
      };
    }
    
    return postMethod(
      _config.registerEndpoint,
      body: {'email': email, 'password': password, 'name': name},
    );
  }

  Future<dynamic> logIn({
    required String email,
    required String password,
  }) async {
    // For testing with jsonplaceholder
    if (_config.baseUrl.contains('jsonplaceholder')) {
      // Simulate successful login
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      return {
        'success': true,
        'data': {
          'access_token': 'test_token_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'Login successful'
        }
      };
    }
    
    return postMethod(
      _config.loginEndpoint,
      body: {'email': email, 'password': password},
    );
  }
}
