import 'package:flutter/material.dart';

class HomeTranslationFlag extends StatelessWidget {
  final String path;
  final bool active;

  const HomeTranslationFlag({
    required this.path,
    required this.active,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.5,
      child: Image.asset(path, fit: BoxFit.fill),
    );
  }
}
