import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

/// Lightweight interactive vehicle presentation used by the authentication UI.
///
/// The vehicle is painted with Flutter primitives, so it never depends on a
/// network request, a heavyweight 3D engine, or an image that can fail to load.
/// Drag horizontally (or use the arrow keys) to inspect it from every angle.
class FloatingVehicleVisual extends StatefulWidget {
  final double height;
  final bool showAmbientGlow;
  final bool showGroundReflection;

  const FloatingVehicleVisual({
    super.key,
    this.height = 320,
    this.showAmbientGlow = true,
    this.showGroundReflection = true,
  });

  @override
  State<FloatingVehicleVisual> createState() => _FloatingVehicleVisualState();
}

class _FloatingVehicleVisualState extends State<FloatingVehicleVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  double _angle = math.pi * 0.18;
  bool _dragging = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && _motion.isAnimating) {
      _motion.stop();
      _motion.value = 0.5;
    } else if (!reduceMotion && !_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _rotate(double delta) {
    setState(() {
      _angle = (_angle + delta) % (math.pi * 2);
      if (_angle < 0) _angle += math.pi * 2;
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _rotate(-math.pi / 18);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _rotate(math.pi / 18);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final safeHeight = widget.height.clamp(150.0, 420.0).toDouble();
    final degrees = ((_angle * 180 / math.pi).round() % 360).toString();

    return Semantics(
      label: 'Интерактивный обзор автомобиля на 360 градусов',
      value: '$degrees градусов',
      hint: 'Проведите влево или вправо либо используйте клавиши со стрелками',
      onIncrease: () => _rotate(math.pi / 12),
      onDecrease: () => _rotate(-math.pi / 12),
      child: Focus(
        onKeyEvent: _handleKey,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: (details) =>
                _rotate(details.delta.dx / 115),
            onHorizontalDragEnd: (_) => setState(() => _dragging = false),
            onHorizontalDragCancel: () => setState(() => _dragging = false),
            child: SizedBox(
              height: safeHeight,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _motion,
                builder: (context, child) {
                  final reduceMotion =
                      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
                  final wave = reduceMotion
                      ? 0.0
                      : math.sin(_motion.value * math.pi * 2);
                  final floatOffset = _dragging ? 0.0 : wave * 7;

                  return AnimatedScale(
                    scale: _hovered ? 1.025 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.showAmbientGlow)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.accent.withValues(alpha: 0.22),
                                      AppColors.primary.withValues(alpha: 0.10),
                                      Colors.transparent,
                                    ],
                                    stops: const [0, 0.48, 1],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (widget.showGroundReflection)
                          Positioned(
                            bottom: safeHeight * 0.11 - floatOffset * 0.18,
                            child: _GroundShadow(
                              width: safeHeight * (0.72 - wave.abs() * 0.025),
                            ),
                          ),
                        Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: Size(safeHeight * 1.25, safeHeight * 0.66),
                              painter: _VehiclePainter(
                                angle: _angle,
                                glowStrength: _hovered ? 1 : 0.72,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          child: AnimatedOpacity(
                            opacity: _dragging ? 0.35 : 0.82,
                            duration: const Duration(milliseconds: 160),
                            child: _RotationHint(degrees: degrees),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  final double width;

  const _GroundShadow({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.62),
            blurRadius: 26,
            spreadRadius: 7,
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.18),
            blurRadius: 34,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}

class _RotationHint extends StatelessWidget {
  final String degrees;

  const _RotationHint({required this.degrees});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB30A1222),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.threesixty_rounded,
            size: 17,
            color: AppColors.accent,
          ),
          const SizedBox(width: 7),
          Text(
            '$degrees°  •  вращайте',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehiclePainter extends CustomPainter {
  final double angle;
  final double glowStrength;

  const _VehiclePainter({required this.angle, required this.glowStrength});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final side = math.sin(angle);
    final facing = math.cos(angle);
    final sideAmount = side.abs();
    final bodyWidth = size.width * (0.50 + sideAmount * 0.38);
    final bodyHeight = size.height * (0.29 + sideAmount * 0.05);
    final left = center.dx - bodyWidth / 2;
    final top = center.dy - bodyHeight / 2;
    final rect = Rect.fromLTWH(left, top, bodyWidth, bodyHeight);

    final glow = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.18 * glowStrength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(size.height * 0.055),
        const Radius.circular(44),
      ),
      glow,
    );

    final bodyPath = Path()
      ..moveTo(rect.left, rect.center.dy + rect.height * 0.24)
      ..quadraticBezierTo(
        rect.left + rect.width * 0.04,
        rect.top + rect.height * 0.20,
        rect.left + rect.width * 0.22,
        rect.top + rect.height * 0.10,
      )
      ..lineTo(rect.left + rect.width * 0.36, rect.top - rect.height * 0.42)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top - rect.height * 0.70,
        rect.left + rect.width * 0.67,
        rect.top - rect.height * 0.38,
      )
      ..lineTo(rect.right - rect.width * 0.10, rect.top + rect.height * 0.03)
      ..quadraticBezierTo(
        rect.right,
        rect.top + rect.height * 0.14,
        rect.right,
        rect.center.dy + rect.height * 0.23,
      )
      ..quadraticBezierTo(
        rect.right - rect.width * 0.03,
        rect.bottom,
        rect.right - rect.width * 0.18,
        rect.bottom,
      )
      ..lineTo(rect.left + rect.width * 0.15, rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.center.dy + rect.height * 0.24,
      )
      ..close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF203D69), Color(0xFF09111F), Color(0xFF02060C)],
        stops: [0, 0.55, 1],
      ).createShader(bodyPath.getBounds());
    canvas.drawPath(bodyPath, bodyPaint);

    final glassPath = Path()
      ..moveTo(rect.left + rect.width * 0.31, rect.top + rect.height * 0.02)
      ..lineTo(rect.left + rect.width * 0.40, rect.top - rect.height * 0.34)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top - rect.height * 0.48,
        rect.left + rect.width * 0.63,
        rect.top - rect.height * 0.29,
      )
      ..lineTo(rect.left + rect.width * 0.72, rect.top + rect.height * 0.03)
      ..close();
    canvas.drawPath(
      glassPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF6DEBFF).withValues(alpha: 0.50),
            const Color(0xFF132A48).withValues(alpha: 0.78),
            const Color(0xFF020814).withValues(alpha: 0.94),
          ],
        ).createShader(glassPath.getBounds()),
    );

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.52)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + rect.width * 0.12, rect.top + rect.height * 0.22)
        ..quadraticBezierTo(
          rect.center.dx,
          rect.top - rect.height * 0.02,
          rect.right - rect.width * 0.08,
          rect.top + rect.height * 0.22,
        ),
      highlight,
    );

    if (sideAmount > 0.22) {
      final wheelRadius = size.height * (0.085 + sideAmount * 0.025);
      _drawWheel(
        canvas,
        Offset(rect.left + rect.width * 0.22, rect.bottom - wheelRadius * 0.15),
        wheelRadius,
      );
      _drawWheel(
        canvas,
        Offset(
          rect.right - rect.width * 0.20,
          rect.bottom - wheelRadius * 0.15,
        ),
        wheelRadius,
      );
    }

    final isFront = facing >= 0;
    final lampColor = isFront
        ? const Color(0xFF8EFAFF)
        : const Color(0xFFFF315B);
    final lampPaint = Paint()
      ..color = lampColor.withValues(alpha: 0.94)
      ..strokeWidth = size.height * 0.018
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final lampY = rect.top + rect.height * 0.46;
    final spread = rect.width * (0.18 + sideAmount * 0.26);
    canvas.drawLine(
      Offset(center.dx - spread, lampY),
      Offset(center.dx - spread * 0.48, lampY + size.height * 0.004),
      lampPaint,
    );
    canvas.drawLine(
      Offset(center.dx + spread * 0.48, lampY + size.height * 0.004),
      Offset(center.dx + spread, lampY),
      lampPaint,
    );

    final grilleWidth = rect.width * (0.18 - sideAmount * 0.07);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, rect.bottom - rect.height * 0.18),
          width: grilleWidth
              .clamp(size.width * 0.035, size.width * 0.18)
              .toDouble(),
          height: rect.height * 0.18,
        ),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF010307),
    );

    final accentPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.88)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + rect.width * 0.12, rect.bottom - 2)
        ..quadraticBezierTo(
          center.dx,
          rect.bottom + 5,
          rect.right - rect.width * 0.12,
          rect.bottom - 2,
        ),
      accentPaint,
    );
  }

  void _drawWheel(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF020307));
    canvas.drawCircle(
      center,
      radius * 0.66,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF61718A), Color(0xFF151C28), Color(0xFF020307)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final spoke = Paint()
      ..color = const Color(0xFF9BEFFF).withValues(alpha: 0.58)
      ..strokeWidth = 1.2;
    for (var index = 0; index < 8; index++) {
      final theta = index * math.pi / 4;
      canvas.drawLine(
        center,
        center + Offset(math.cos(theta), math.sin(theta)) * radius * 0.57,
        spoke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VehiclePainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.glowStrength != glowStrength;
}
