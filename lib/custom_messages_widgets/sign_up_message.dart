import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Future<void> showSignupMessage(
  BuildContext context,
  String message,
  bool isError,
) async {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    flushbarPosition: FlushbarPosition.TOP,
    animationDuration: const Duration(milliseconds: 500),
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle_outline,
      size: 28.0,
      color: Colors.white,
    ),
  ).show(context);
}
