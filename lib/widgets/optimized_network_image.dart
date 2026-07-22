import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OptimizedNetworkImage extends StatelessWidget {
  const OptimizedNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIcon = Icons.directions_car,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logicalWidth = width ??
              (constraints.hasBoundedWidth ? constraints.maxWidth : 800.0);
          final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
          final decodedWidth = (logicalWidth * devicePixelRatio)
              .round()
              .clamp(1, 1920)
              .toInt();

          if (url.isEmpty) return _placeholder();

          return Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            cacheWidth: kIsWeb ? null : decodedWidth,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return _placeholder();
            },
            errorBuilder: (_, __, ___) => _placeholder(),
          );
        },
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFF1F3F5),
      child: Center(
        child: Icon(fallbackIcon, size: 52, color: Colors.grey.shade400),
      ),
    );
  }
}
