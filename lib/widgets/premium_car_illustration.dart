import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PremiumCarIllustration extends StatefulWidget {
  const PremiumCarIllustration({super.key, this.height = 250});

  final double height;

  @override
  State<PremiumCarIllustration> createState() => _PremiumCarIllustrationState();
}

class _PremiumCarIllustrationState extends State<PremiumCarIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _controller.isAnimating) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _reduceMotion ? 0.5 : _controller.value;
            final wave = math.sin(progress * math.pi);
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: widget.height * 0.07,
                  child: Center(
                    child: Transform.scale(
                      scaleX: 1 - (0.05 * wave),
                      scaleY: 1 - (0.12 * wave),
                      child: Container(
                        width: widget.height * 1.55,
                        height: widget.height * 0.10,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.24 - (0.06 * wave),
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 22 + (8 * wave),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -7 * wave),
                  child: Transform.rotate(
                    angle: (progress - 0.5) * 0.008,
                    child: Transform.scale(
                      scale: 0.985 + (0.015 * wave),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          },
          child: CustomPaint(
            painter: _PremiumCarPainter(
              brightness: Theme.of(context).brightness,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _PremiumCarPainter extends CustomPainter {
  const _PremiumCarPainter({required this.brightness});

  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 560, size.height / 250);
    canvas.save();
    canvas.translate(
      (size.width - 560 * scale) / 2,
      (size.height - 250 * scale) / 2,
    );
    canvas.scale(scale);

    final body = Path()
      ..moveTo(55, 175)
      ..quadraticBezierTo(64, 131, 118, 124)
      ..lineTo(175, 116)
      ..quadraticBezierTo(218, 60, 300, 55)
      ..quadraticBezierTo(376, 57, 421, 113)
      ..lineTo(487, 128)
      ..quadraticBezierTo(520, 137, 520, 175)
      ..quadraticBezierTo(516, 197, 487, 199)
      ..lineTo(75, 199)
      ..quadraticBezierTo(51, 195, 55, 175)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF67E8F9), AppColors.primary, Color(0xFF172554)],
          stops: [0, 0.48, 1],
        ).createShader(const Rect.fromLTWH(50, 50, 475, 155)),
    );

    final windows = Path()
      ..moveTo(192, 113)
      ..quadraticBezierTo(229, 72, 291, 69)
      ..lineTo(302, 69)
      ..lineTo(302, 112)
      ..close()
      ..moveTo(315, 70)
      ..quadraticBezierTo(371, 76, 401, 112)
      ..lineTo(315, 112)
      ..close();
    canvas.drawPath(
      windows,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDFF9FF), Color(0xFF183152)],
        ).createShader(const Rect.fromLTWH(190, 65, 215, 50)),
    );

    canvas.drawPath(
      Path()
        ..moveTo(92, 142)
        ..quadraticBezierTo(250, 102, 464, 136),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.50)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final center in const [Offset(155, 190), Offset(430, 190)]) {
      canvas.drawCircle(center, 39, Paint()..color = const Color(0xFF07111F));
      canvas.drawCircle(center, 25, Paint()..color = const Color(0xFF334155));
      canvas.drawCircle(center, 12, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawCircle(
        center,
        33,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(476, 148, 35, 18),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFECFEFF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PremiumCarPainter oldDelegate) =>
      oldDelegate.brightness != brightness;
}
