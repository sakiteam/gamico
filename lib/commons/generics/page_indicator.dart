import 'package:flutter/material.dart';

class GamicoPageIndicator extends StatefulWidget {
  final PageController controller;
  final double indicatorSize;
  final int count;
  final Color? color;
  final Widget Function(bool active)? builder;

  const GamicoPageIndicator({
    super.key,
    required this.controller,
    this.indicatorSize = 8 * 450 / 400,
    required this.count,
    this.color,
    this.builder,
  });

  @override
  State<GamicoPageIndicator> createState() => _GamicoPageIndicatorState();
}

class _GamicoPageIndicatorState extends State<GamicoPageIndicator> {
  late int _index;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
    _index = _controller.initialPage;
    _controller.addListener(listenToPageController);
  }

  void listenToPageController() {
    if (mounted) {
      setState(() {
        _index = (_controller.page ?? 0).round();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(listenToPageController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.count, (index) {
        final active = index == _index;

        // onTap: () {
        //       widget.controller.animateToPage(
        //         index,
        //         duration: const Duration(milliseconds: 500),
        //         curve: Curves.linear,
        //       );
        //     },

        final mainColor = widget.color ?? Colors.brown;

        return widget.builder?.call(active) ??
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                width: widget.indicatorSize,
                height: widget.indicatorSize,
                decoration: BoxDecoration(
                  color: active ? mainColor : mainColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(widget.indicatorSize),
                  border: Border.all(color: Colors.grey.shade700),
                ),
              ),
            );
      }),
    );
  }
}
