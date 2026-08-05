import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 30;

  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);
}

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1180;
}

abstract final class AppConstraints {
  static const double contentMaxWidth = 1360;
  static const double formMaxWidth = 540;
  static const double minInteractiveSize = 48;
}

extension ResponsiveContext on BuildContext {
  Size get viewport => MediaQuery.sizeOf(this);
  bool get isCompact => viewport.width < AppBreakpoints.compact;
  bool get isExpanded => viewport.width >= AppBreakpoints.expanded;
}
