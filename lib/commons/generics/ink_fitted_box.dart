import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';

/// The transparent ink surface [InkFittedBox] installs, on its own.
///
/// Needed wherever the surface must sit *below* a [DeferredPointerHandler]:
/// a [Material] between the FittedBox and the handler bounds-checks hit tests
/// against the reference box, so every tap on content painted outside it (the
/// corner buttons, anything under the reference height) would be swallowed.
class InkSurface extends StatelessWidget {
  final Widget? child;

  const InkSurface({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      textStyle: DefaultTextStyle.of(context).style,
      child: child,
    );
  }
}

/// An [InkFittedBox] whose ink surface sits under a [DeferredPointerHandler],
/// so descendants using `DeferPointer` stay tappable outside the scaled box.
class InkDeferredFittedBox extends StatelessWidget {
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? child;

  const InkDeferredFittedBox({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: fit,
      alignment: alignment,
      child: DeferredPointerHandler(child: InkSurface(child: child)),
    );
  }
}

/// A [FittedBox] that hosts its own ink surface.
///
/// Every page is laid out in reference coordinates inside a FittedBox, so the
/// nearest [Material] of any button is the app's own, far above that scaling.
/// An ink splash then has to project itself down through the FittedBox, and
/// Flutter reads the FittedBox's size to do it — which throws
/// "RenderBox was not laid out" whenever the splash outlives the layout of the
/// subtree it started in (a route pop, a panel closing, a page rebuilt at a
/// different scale mid-animation).
///
/// Putting a transparent [Material] *under* the FittedBox keeps every splash
/// inside the scaled subtree, so the projection never crosses the scaling and
/// the crash cannot happen. The ambient text style is carried over so this is
/// visually a no-op.
class InkFittedBox extends StatelessWidget {
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? child;

  const InkFittedBox({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: fit,
      alignment: alignment,
      child: InkSurface(child: child),
    );
  }
}
