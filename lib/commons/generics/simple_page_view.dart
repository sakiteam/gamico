import 'package:flutter/material.dart';

class GamicoSimplePageView extends StatefulWidget {
  final int initialPage;
  final List<Widget> children;
  final double viewportFraction;

  const GamicoSimplePageView({
    super.key,
    this.initialPage = 0,
    this.children = const [],
    this.viewportFraction = 1,
  });

  @override
  State<GamicoSimplePageView> createState() => _GamicoSimplePageViewState();
}

class _GamicoSimplePageViewState extends State<GamicoSimplePageView> {
  late final PageController pageController = PageController(
    initialPage: widget.initialPage,
    viewportFraction: widget.viewportFraction,
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: widget.children,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
