import 'package:boilerplate_flutter/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class DialogService {
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showCustomSnackbar({
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
  }) {
    final snackbar = CustomSnackbar(
      message: message,
      title: title,
      icon: icon,
      backgroundColor: backgroundColor,
    );

    messengerKey.currentState?.showSnackBar(snackbar);
  }

  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
