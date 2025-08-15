import 'package:boilerplate_flutter/core/widgets/custom_snackbar.dart';
import 'package:boilerplate_flutter/features/Auth/services/auth_service.dart';
import 'package:boilerplate_flutter/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthController with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final signUpFormKey = GlobalKey<FormState>();

  bool loginObscurePassword = true;
  bool signUpObscurePassword = true;

  final AuthService _authservice = AuthService();

  void login(BuildContext context) async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar(
              title: "Error",
              message: "Please fill all fields",
              icon: Icons.error,
              backgroundColor: Colors.red,
            ),
          );
        return;
      }

      final results = await _authservice.logIn(email: email, password: password);
      
      // Check if results is a Map and has the expected structure
      if (results is Map<String, dynamic>) {
        if (results['success'] == true) {
          // Save the access token to shared preferences
          final token = results['data']?['access_token'];
          if (token != null) {
            await LocalStorageService.saveString('access_token', token);
            context.go('/home');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar(
                  title: "Success",
                  message: "Login successful",
                  icon: Icons.check_circle,
                  backgroundColor: Colors.green,
                ),
              );
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                CustomSnackbar(
                  title: "Error",
                  message: "Invalid response from server",
                  icon: Icons.error,
                  backgroundColor: Colors.red,
                ),
              );
          }
        } else {
          // Handle API error response
          String errorMessage = "Login failed";
          if (results['data'] != null && results['data']['message'] != null) {
            errorMessage = results['data']['message'];
          } else if (results['message'] != null) {
            errorMessage = results['message'];
          }
          
          // Show error with signup suggestion
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'New user? Try signing up instead',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Sign Up',
                  textColor: Colors.white,
                  onPressed: () {
                    context.go('/signup');
                  },
                ),
              ),
            );
        }
      } else {
        // Handle unexpected response format
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar(
              title: "Error",
              message: "Invalid response from server",
              icon: Icons.error,
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      String errorMessage = "Network error occurred";
      
      if (e.toString().contains("SocketException") || e.toString().contains("Connection refused")) {
        errorMessage = "Cannot connect to server. Please check your internet connection.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Request timeout. Please try again.";
      } else if (e.toString().contains("401")) {
        errorMessage = "Invalid email or password";
      } else if (e.toString().contains("404")) {
        errorMessage = "Server not found";
      } else if (e.toString().contains("500")) {
        errorMessage = "Server error";
      } else if (e.toString().contains("Network is unreachable")) {
        errorMessage = "No internet connection";
      }
      
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar(
            title: "Error",
            message: errorMessage,
            icon: Icons.error,
            backgroundColor: Colors.red,
          ),
        );
    }
    notifyListeners();
  }

  void signup(BuildContext context) async {
    try {
      final name = userNameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar(
              title: "Error",
              message: "Please fill all fields",
              icon: Icons.error,
              backgroundColor: Colors.red,
            ),
          );
        return;
      }

      if (password.length < 6) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar(
              title: "Error",
              message: "Password must be at least 6 characters",
              icon: Icons.error,
              backgroundColor: Colors.red,
            ),
          );
        return;
      }

      final results = await _authservice.signUp(
        email: email,
        name: name,
        password: password,
      );

      // Check if results is a Map and has the expected structure
      if (results is Map<String, dynamic>) {
        if (results['success'] == true) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account created successfully!",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You can now login with your credentials',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Login',
                  textColor: Colors.white,
                  onPressed: () {
                    context.go('/');
                  },
                ),
              ),
            );
          // context.pop();
        } else {
          // Handle API error response
          String errorMessage = "Signup failed";
          if (results['data'] != null && results['data']['message'] != null) {
            errorMessage = results['data']['message'];
          } else if (results['message'] != null) {
            errorMessage = results['message'];
          }
          
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              CustomSnackbar(
                title: "Error",
                message: errorMessage,
                icon: Icons.error,
                backgroundColor: Colors.red,
              ),
            );
        }
      } else {
        // Handle unexpected response format
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            CustomSnackbar(
              title: "Error",
              message: "Invalid response from server",
              icon: Icons.error,
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      String errorMessage = "Network error occurred";
      
      if (e.toString().contains("SocketException") || e.toString().contains("Connection refused")) {
        errorMessage = "Cannot connect to server. Please check your internet connection.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Request timeout. Please try again.";
      } else if (e.toString().contains("409")) {
        errorMessage = "Email already exists";
      } else if (e.toString().contains("400")) {
        errorMessage = "Invalid data provided";
      } else if (e.toString().contains("500")) {
        errorMessage = "Server error";
      } else if (e.toString().contains("Network is unreachable")) {
        errorMessage = "No internet connection";
      }
      
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          CustomSnackbar(
            title: "Error",
            message: errorMessage,
            icon: Icons.error,
            backgroundColor: Colors.red,
          ),
        );
    }

    notifyListeners();
  }

  void toggle() {
    loginObscurePassword = !loginObscurePassword;
    notifyListeners();
  }

  void signUpToggle() {
    signUpObscurePassword = !signUpObscurePassword;
    notifyListeners();
  }

  void logout() {
    LocalStorageService.remove('access_token');
    notifyListeners();
  }
}
