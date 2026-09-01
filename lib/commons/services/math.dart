import 'dart:math';
import 'package:poly_collisions/poly_collisions.dart';
// import 'package:gamico/features/game/utilities/ball_utility.dart';
import 'package:gamico/commons/utilities/math/polygon_utility.dart';

class MathService {
  // final distance = 5.0 * first.speed;
  // final angle = atan2(lastY - firstY, lastX - firstX);

  static double interpolate(num xa, num ya, num xb, num yb, num x) {
    return (xb - x) / (xb - xa) * ya + (x - xa) / (xb - xa) * yb;
  }

  static double phi = (1 + sqrt(5)) / 2;
  static double phiReversed = 2 / (1 + sqrt(5));

  static int remoteBallEmissionDelay = 100;

  static double distance(Point p1, Point p2) {
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;

    return sqrt(dx * dx + dy * dy);
  }

  static bool intersects(double a, double b, double c, double d, double p,
      double q, double r, double s) {
    double det, gamma, lambda;

    det = (c - a) * (s - q) - (r - p) * (d - b);

    if (det == 0) {
      return false;
    } else {
      lambda = ((s - q) * (r - a) + (p - r) * (s - b)) / det;
      gamma = ((b - d) * (r - a) + (c - a) * (s - b)) / det;
      return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
    }
  }

  // static bool ballsCollision(BallUtility a, BallUtility b) {
  //   final distance = MathService.distance(
  //     Point(a.centerX, a.centerY),
  //     Point(b.centerX, b.centerY),
  //   );

  //   return distance <= a.radius + b.radius;
  // }

  // static bool ennemyBallsCollision(BallUtility a, BallUtility b) {
  //   return a.couple != b.couple && MathService.ballsCollision(a, b);
  // }

  /// Returns whether the current Polygon utility overlaps with the [other] polygon.
  static bool polygonsIntersection(PolygonUtility a, PolygonUtility b) {
    return PolygonCollision.doesOverlap(a.points, b.points);
  }

  static int getNextThird100Multiple(int n) {
    return n + 3 * remoteBallEmissionDelay - (n % remoteBallEmissionDelay);
  }
}
