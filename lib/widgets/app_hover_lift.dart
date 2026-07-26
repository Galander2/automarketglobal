import 'package:flutter/material.dart';

/// Adds a consistent, lightweight hover and press response to custom
/// interactive surfaces.
///
/// Material buttons receive the same visual language from the application
/// theme. This widget is intended for cards, navigation items and bespoke
/// controls that cannot be styled through a Material button theme.
class AppHoverLift extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final BorderRadius borderRadius;
  final double hoverScale;
  final double pressedScale;

  const AppHoverLift({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.hoverScale = 1.018,
    this.pressedScale = 0.985,
  });

  @override
  State<AppHoverLift> createState() => _AppHoverLiftState();
}

class _AppHoverLiftState extends State<AppHoverLift> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (!widget.enabled || _hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final colors = Theme.of(context).colorScheme;
    final active = widget.enabled && (_hovered || _pressed);
    final scale = !widget.enabled
        ? 1.0
        : _pressed
        ? widget.pressedScale
        : _hovered
        ? widget.hoverScale
        : 1.0;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _setHovered(true),
      onExit: (_) {
        _setHovered(false);
        _setPressed(false);
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: scale,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: active
                  ? Border.all(
                      color: colors.primary.withValues(alpha: 0.92),
                      width: 1.35,
                    )
                  : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.24),
                        blurRadius: _pressed ? 12 : 22,
                        spreadRadius: _pressed ? 0 : 1,
                        offset: Offset(0, _pressed ? 3 : 8),
                      ),
                    ]
                  : const [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
