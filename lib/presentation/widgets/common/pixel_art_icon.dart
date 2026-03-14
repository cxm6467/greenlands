import 'package:flutter/material.dart';

/// Pixel art style icon for game features
class PixelArtIcon extends StatelessWidget {
  final PixelArtIconType type;
  final double size;

  const PixelArtIcon({super.key, required this.type, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PixelArtIconPainter(type: type),
        size: Size(size, size),
      ),
    );
  }
}

enum PixelArtIconType {
  swords, // Quest-based Adventure
  heroes, // Company of Heroes
  magic, // AI-Powered Dialogue
  scroll, // Dynamic Quests
}

class PixelArtIconPainter extends CustomPainter {
  final PixelArtIconType type;

  PixelArtIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 16; // 16x16 pixel grid

    switch (type) {
      case PixelArtIconType.swords:
        _drawSwords(canvas, size, pixelSize);
        break;
      case PixelArtIconType.heroes:
        _drawHeroes(canvas, size, pixelSize);
        break;
      case PixelArtIconType.magic:
        _drawMagic(canvas, size, pixelSize);
        break;
      case PixelArtIconType.scroll:
        _drawScroll(canvas, size, pixelSize);
        break;
    }
  }

  void _drawSwords(Canvas canvas, Size size, double pixelSize) {
    final swordPaint = Paint()
      ..color =
          const Color(0xFFC0C0C0) // Silver
      ..style = PaintingStyle.fill;

    final handlePaint = Paint()
      ..color =
          const Color(0xFF654321) // Brown handle
      ..style = PaintingStyle.fill;

    final crossPaint = Paint()
      ..color =
          const Color(0xFFDAA520) // Gold cross-guard
      ..style = PaintingStyle.fill;

    // Left sword blade
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - pixelSize * 5,
        size.height / 2 - pixelSize * 6,
        pixelSize * 2,
        pixelSize * 10,
      ),
      swordPaint,
    );

    // Left sword cross-guard
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - pixelSize * 6,
        size.height / 2 - pixelSize * 2,
        pixelSize * 4,
        pixelSize,
      ),
      crossPaint,
    );

    // Left sword handle
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - pixelSize * 5,
        size.height / 2 - pixelSize,
        pixelSize * 2,
        pixelSize * 4,
      ),
      handlePaint,
    );

    // Right sword blade
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 + pixelSize * 3,
        size.height / 2 - pixelSize * 6,
        pixelSize * 2,
        pixelSize * 10,
      ),
      swordPaint,
    );

    // Right sword cross-guard
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 + pixelSize * 2,
        size.height / 2 - pixelSize * 2,
        pixelSize * 4,
        pixelSize,
      ),
      crossPaint,
    );

    // Right sword handle
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 + pixelSize * 3,
        size.height / 2 - pixelSize,
        pixelSize * 2,
        pixelSize * 4,
      ),
      handlePaint,
    );
  }

  void _drawHeroes(Canvas canvas, Size size, double pixelSize) {
    final headPaint = Paint()
      ..color =
          const Color(0xFFFFDBAC) // Skin tone
      ..style = PaintingStyle.fill;

    final bodyPaint = Paint()
      ..color =
          const Color(0xFF4169E1) // Blue
      ..style = PaintingStyle.fill;

    // Left hero
    _drawHeroFigure(
      canvas,
      Offset(size.width / 2 - pixelSize * 3, size.height / 2),
      pixelSize,
      headPaint,
      bodyPaint,
    );

    // Right hero
    _drawHeroFigure(
      canvas,
      Offset(size.width / 2 + pixelSize * 3, size.height / 2),
      pixelSize,
      headPaint,
      bodyPaint,
    );
  }

  void _drawHeroFigure(
    Canvas canvas,
    Offset center,
    double pixelSize,
    Paint headPaint,
    Paint bodyPaint,
  ) {
    // Head
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - pixelSize * 4),
        width: pixelSize * 3,
        height: pixelSize * 3,
      ),
      headPaint,
    );

    // Body
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy),
        width: pixelSize * 4,
        height: pixelSize * 5,
      ),
      bodyPaint,
    );
  }

  void _drawMagic(Canvas canvas, Size size, double pixelSize) {
    final orbPaint = Paint()
      ..color =
          const Color(0xFF9370DB) // Purple
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFFDA70D6)
          .withValues(alpha: 0.5) // Pink glow
      ..style = PaintingStyle.fill;

    final sparkPaint = Paint()
      ..color =
          const Color(0xFFFFD700) // Gold sparkles
      ..style = PaintingStyle.fill;

    // Outer glow
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      pixelSize * 7,
      glowPaint,
    );

    // Main orb
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      pixelSize * 5,
      orbPaint,
    );

    // Inner shine
    canvas.drawCircle(
      Offset(size.width / 2 - pixelSize, size.height / 2 - pixelSize),
      pixelSize * 2,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    // Sparkles around orb
    final sparkles = [
      Offset(size.width / 2 - pixelSize * 6, size.height / 2 - pixelSize * 3),
      Offset(size.width / 2 + pixelSize * 6, size.height / 2 - pixelSize * 2),
      Offset(size.width / 2 - pixelSize * 3, size.height / 2 + pixelSize * 5),
      Offset(size.width / 2 + pixelSize * 4, size.height / 2 + pixelSize * 4),
    ];

    for (final sparkle in sparkles) {
      canvas.drawRect(
        Rect.fromCenter(center: sparkle, width: pixelSize, height: pixelSize),
        sparkPaint,
      );
    }
  }

  void _drawScroll(Canvas canvas, Size size, double pixelSize) {
    final scrollPaint = Paint()
      ..color =
          const Color(0xFFF5DEB3) // Wheat/parchment
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color =
          const Color(0xFF8B7355) // Dark brown
      ..style = PaintingStyle.fill;

    final textPaint = Paint()
      ..color =
          const Color(0xFF654321) // Brown text
      ..style = PaintingStyle.fill;

    // Main scroll body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: pixelSize * 10,
          height: pixelSize * 12,
        ),
        Radius.circular(pixelSize),
      ),
      scrollPaint,
    );

    // Top rod
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - pixelSize * 6,
        size.height / 2 - pixelSize * 7,
        pixelSize * 12,
        pixelSize,
      ),
      darkPaint,
    );

    // Bottom rod
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - pixelSize * 6,
        size.height / 2 + pixelSize * 6,
        pixelSize * 12,
        pixelSize,
      ),
      darkPaint,
    );

    // Text lines
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 3,
          size.height / 2 - pixelSize * 3 + i * pixelSize * 1.5,
          pixelSize * 6,
          pixelSize * 0.5,
        ),
        textPaint,
      );
    }
  }

  @override
  bool shouldRepaint(PixelArtIconPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
