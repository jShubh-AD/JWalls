import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class AppSnackBar {
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        required bool isError,
      }) {
    final snackBar = SnackBar(
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 12,
      ),
      behavior: SnackBarBehavior.fixed,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: isError
            ? ContentType.failure
            : ContentType.success,
      ),
    );

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}