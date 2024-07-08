import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SimpleSimulation extends Simulation {
  double target;

  SimpleSimulation(this.target);

  @override
  double dx(double time) {
    return 0;
  }

  @override
  bool isDone(double time) {
    return true;
  }

  @override
  double x(double time) {
    return target;
  }
}

class CustomScroll extends ScrollPhysics {
  /// Creates physics for a [PageView].
  final ValueGetter<double> lineHeight;

  const CustomScroll({super.parent, required this.lineHeight});

  @override
  CustomScroll applyTo(ScrollPhysics? ancestor) {
    return CustomScroll(
        parent: buildParent(ancestor), lineHeight: lineHeight);
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double px = position.pixels;
    final lh = lineHeight();
    if (velocity < -tolerance.velocity) {
      px -= lh;
    } else if (velocity > tolerance.velocity) {
      px += lh;
    }
    return (px / lh).floorToDouble() * lh;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    applyPhysicsToUserOffset(position, target - position.pixels);
    return SimpleSimulation(target);
  }

  @override
  bool get allowImplicitScrolling => true;

  @override
  bool get allowUserScrolling => true;
}
