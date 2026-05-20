import 'package:flutter/material.dart';

class LoadingFAB extends StatelessWidget {
  final bool loading;
  final Widget child;
  final VoidCallback onPressed;

  const LoadingFAB({
    super.key,
    required this.loading,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2.5,
        ),
      )
          : child,
    );
  }
}