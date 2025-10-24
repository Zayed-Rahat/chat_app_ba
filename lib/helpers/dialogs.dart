import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        // ignore: deprecated_member_use
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 1)),
    );
  }
}
