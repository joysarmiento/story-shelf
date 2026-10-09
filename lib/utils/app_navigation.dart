import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/memories_screen.dart';
import '../screens/profile_screen.dart';

class AppTab {
  AppTab._();

  static const home = 0;
  static const library = 1;
  static const memories = 2;
  static const profile = 3;
}

final GlobalKey pageSnapshotKey = GlobalKey();

bool _flipping = false;

void navigateToTab(
  BuildContext context,
  int index, {
  required int currentIndex,
}) {
  if (index == currentIndex) return;

  final Widget? screen = switch (index) {
    AppTab.home => const HomeScreen(),
    AppTab.library => const LibraryScreen(),
    AppTab.memories => const MemoriesScreen(),
    AppTab.profile => const ProfileScreen(),

    _ => null,
  };

  if (screen == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
    return;
  }

  _flipToPage(context, screen);
}

Future<void> _flipToPage(BuildContext context, Widget screen) async {
  if (_flipping) return;
  _flipping = true;

  final navigator = Navigator.of(context);
  final pixelRatio = MediaQuery.devicePixelRatioOf(context);

  ui.Image? snapshot;
  try {
    final boundary = _findBoundary(context);
    if (boundary == null) {
      debugPrint('Page flip: no RepaintBoundary found.');
    }
    snapshot = await boundary?.toImage(pixelRatio: pixelRatio);
  } catch (e) {
    debugPrint('Page flip: could not capture the screen: $e');
    snapshot = null;
  }
  if (snapshot == null) {
    debugPrint('Page flip: no snapshot, using the normal transition.');
  }

  if (!navigator.mounted) {
    snapshot?.dispose();
    _flipping = false;
    return;
  }

  navigator.pushReplacement(
    snapshot == null
        ? MaterialPageRoute<void>(builder: (_) => screen)
        : PageFlipRoute<void>(page: screen, snapshot: snapshot),
  );

  await Future<void>.delayed(PageFlipRoute.duration);
  _flipping = false;
}

RenderRepaintBoundary? _findBoundary(BuildContext context) {
  final keyed = pageSnapshotKey.currentContext?.findRenderObject();
  if (keyed is RenderRepaintBoundary) return keyed;

  RenderObject? node = context.findRenderObject();
  while (node != null && node is! RenderRepaintBoundary) {
    node = node.parent;
  }
  return node as RenderRepaintBoundary?;
}

class _Snapshot {
  _Snapshot(this.image);

  final ui.Image image;
  bool disposed = false;

  void dispose() {
    if (disposed) return;
    disposed = true;
    image.dispose();
  }
}

class PageFlipRoute<T> extends PageRouteBuilder<T> {
  PageFlipRoute({required Widget page, required ui.Image snapshot})
    : this._(page, _Snapshot(snapshot));

  PageFlipRoute._(Widget page, this._snap)
    : super(
        pageBuilder: (_, _, _) => page,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (_, animation, _, child) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (_, child) {
              final flipping =
                  animation.status != AnimationStatus.reverse &&
                  animation.value < 1;
              final progress = Curves.easeInOut.transform(animation.value);
              return AbsorbPointer(
                absorbing: flipping,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    child!,
                    if (flipping)
                      Positioned.fill(
                        child: ClipRect(
                          child: CustomPaint(
                            painter: _PageFlipPainter(_snap.image, progress),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );

  static const duration = Duration(milliseconds: 750);

  final _Snapshot _snap;

  @override
  void dispose() {
    _snap.dispose();
    super.dispose();
  }
}

class _PageFlipPainter extends CustomPainter {
  _PageFlipPainter(this.image, this.progress);

  final ui.Image image;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = progress;

    final angle = 0.6 * (1 - s);
    final n = Offset(math.cos(angle), math.sin(angle));
    final c0 = n.dx * w + n.dy * h;
    final c1 = -0.03 * w;
    final c = c0 + (c1 - c0) * s;

    final page = [Offset.zero, Offset(w, 0), Offset(w, h), Offset(0, h)];
    final kept = _clip(page, n, c, keepGreater: false);
    final lifted = _clip(page, n, c, keepGreater: true);

    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, w, h);
    final imagePaint = Paint()..filterQuality = FilterQuality.medium;
    final q = n * c;

    if (lifted.length >= 3) {
      canvas.save();
      canvas.clipPath(Path()..addPolygon(lifted, true));
      canvas.drawRect(
        dst,
        Paint()
          ..shader = ui.Gradient.linear(q, q + n * (0.18 * w), [
            Colors.black.withValues(alpha: 0.35),
            Colors.transparent,
          ]),
      );
      canvas.restore();
    }

    if (kept.length >= 3) {
      canvas.save();
      canvas.clipPath(Path()..addPolygon(kept, true));
      canvas.drawImageRect(image, src, dst, imagePaint);
      canvas.restore();
    }

    if (lifted.length >= 3) {
      final nx = n.dx;
      final ny = n.dy;
      final mirror = Matrix4(
        1 - 2 * nx * nx,
        -2 * nx * ny,
        0,
        0,
        -2 * nx * ny,
        1 - 2 * ny * ny,
        0,
        0,
        0,
        0,
        1,
        0,
        2 * c * nx,
        2 * c * ny,
        0,
        1,
      );
      final flapPath = (Path()..addPolygon(lifted, true)).transform(
        mirror.storage,
      );

      canvas.save();
      canvas.clipPath(flapPath);

      canvas.save();
      canvas.transform(mirror.storage);
      canvas.drawImageRect(image, src, dst, imagePaint);
      canvas.restore();

      canvas.drawRect(
        dst,
        Paint()..color = Colors.white.withValues(alpha: 0.4),
      );
      canvas.drawRect(
        dst,
        Paint()
          ..shader = ui.Gradient.linear(q, q - n * (0.25 * w), [
            Colors.black.withValues(alpha: 0.28),
            Colors.transparent,
          ]),
      );
      canvas.restore();
    }
  }

  static List<Offset> _clip(
    List<Offset> poly,
    Offset n,
    double c, {
    required bool keepGreater,
  }) {
    double side(Offset p) =>
        (n.dx * p.dx + n.dy * p.dy - c) * (keepGreater ? 1 : -1);

    final out = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      final da = side(a);
      final db = side(b);
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) {
        out.add(Offset.lerp(a, b, da / (da - db))!);
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_PageFlipPainter old) =>
      old.progress != progress || old.image != image;
}
