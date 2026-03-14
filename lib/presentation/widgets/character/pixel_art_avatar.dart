import 'package:flutter/material.dart';
import '../../../domain/entities/character.dart';

/// A widget that displays a pixel art style avatar for a character
class PixelArtAvatar extends StatelessWidget {
  final CharacterRace race;
  final CharacterClass characterClass;
  final double size;
  final bool showBorder;

  const PixelArtAvatar({
    super.key,
    required this.race,
    required this.characterClass,
    this.size = 128,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(color: _getBorderColor(), width: 3),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(showBorder ? 5 : 0),
        child: CustomPaint(
          painter: PixelArtAvatarPainter(
            race: race,
            characterClass: characterClass,
          ),
          size: Size(size, size),
        ),
      ),
    );
  }

  Color _getBorderColor() {
    // Border color based on character class
    switch (characterClass) {
      case CharacterClass.warrior:
        return const Color(0xFFB22222); // Red for warrior
      case CharacterClass.ranger:
        return const Color(0xFF228B22); // Green for ranger
      case CharacterClass.wizard:
        return const Color(0xFF4169E1); // Blue for wizard
      case CharacterClass.rogue:
        return const Color(0xFF8B008B); // Purple for rogue
    }
  }
}

/// CustomPainter that draws pixel art style avatars
class PixelArtAvatarPainter extends CustomPainter {
  final CharacterRace race;
  final CharacterClass characterClass;

  PixelArtAvatarPainter({required this.race, required this.characterClass});

  @override
  void paint(Canvas canvas, Size size) {
    // Base pixel size for a 32x32 pixel grid
    final rawPixelSize = size.width / 32;

    // Snap to the nearest whole logical pixel to avoid sub-pixel blurring
    final pixelSize = rawPixelSize.roundToDouble();

    // Actual drawn grid size based on the snapped pixel size
    final gridSize = pixelSize * 32;

    // Center the 32x32 grid within the available canvas size
    final dx = (size.width - gridSize) / 2;
    final dy = (size.height - gridSize) / 2;

    final gridSizeSize = Size(gridSize, gridSize);

    canvas.save();
    canvas.translate(dx, dy);

    // Background
    _drawBackground(canvas, gridSizeSize, pixelSize);

    // Face/Head
    _drawHead(canvas, gridSizeSize, pixelSize);

    // Eyes
    _drawEyes(canvas, gridSizeSize, pixelSize);

    // Facial features based on race
    _drawRacialFeatures(canvas, gridSizeSize, pixelSize);

    // Class-specific accessories
    _drawClassAccessories(canvas, gridSizeSize, pixelSize);

   canvas.restore();
 }

  void _drawBackground(Canvas canvas, Size size, double pixelSize) {
    final paint = Paint()
      ..color = const Color(0xFFECECEC)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawHead(Canvas canvas, Size size, double pixelSize) {
    final skinColor = _getSkinColor();
    final paint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    // Head shape (simplified oval)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: pixelSize * 20,
        height: pixelSize * 24,
      ),
      Radius.circular(pixelSize * 4),
    );

    canvas.drawRRect(headRect, paint);

    // Add shading
    final shadingPaint = Paint()
      ..color = skinColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 10,
          size.height / 2 + pixelSize * 6,
          pixelSize * 20,
          pixelSize * 6,
        ),
        Radius.circular(pixelSize * 2),
      ),
      shadingPaint,
    );
  }

  void _drawEyes(Canvas canvas, Size size, double pixelSize) {
    final eyeColor = _getEyeColor();
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final irisPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Left eye
    final leftEyeCenter = Offset(
      size.width / 2 - pixelSize * 5,
      size.height / 2 - pixelSize * 2,
    );

    // Right eye
    final rightEyeCenter = Offset(
      size.width / 2 + pixelSize * 5,
      size.height / 2 - pixelSize * 2,
    );

    // Draw both eyes
    for (final eyeCenter in [leftEyeCenter, rightEyeCenter]) {
      // White of eye
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: eyeCenter,
            width: pixelSize * 5,
            height: pixelSize * 4,
          ),
          Radius.circular(pixelSize),
        ),
        eyePaint,
      );

      // Iris
      canvas.drawCircle(eyeCenter, pixelSize * 1.5, irisPaint);

      // Pupil
      canvas.drawCircle(eyeCenter, pixelSize * 0.8, pupilPaint);

      // Shine/highlight
      canvas.drawCircle(
        Offset(eyeCenter.dx - pixelSize * 0.3, eyeCenter.dy - pixelSize * 0.3),
        pixelSize * 0.4,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawRacialFeatures(Canvas canvas, Size size, double pixelSize) {
    switch (race) {
      case CharacterRace.dwarf:
        _drawBeard(canvas, size, pixelSize, const Color(0xFF8B4513));
        break;
      case CharacterRace.elf:
        _drawElfEars(canvas, size, pixelSize);
        break;
      case CharacterRace.hobbit:
        _drawHobbitHair(canvas, size, pixelSize);
        break;
      case CharacterRace.human:
        _drawHumanHair(canvas, size, pixelSize);
        break;
    }
  }

  void _drawBeard(
    Canvas canvas,
    Size size,
    double pixelSize,
    Color beardColor,
  ) {
    final paint = Paint()
      ..color = beardColor
      ..style = PaintingStyle.fill;

    // Beard shape
    final beardPath = Path();
    beardPath.moveTo(size.width / 2 - pixelSize * 8, size.height / 2);
    beardPath.lineTo(
      size.width / 2 - pixelSize * 7,
      size.height / 2 + pixelSize * 10,
    );
    beardPath.lineTo(
      size.width / 2 + pixelSize * 7,
      size.height / 2 + pixelSize * 10,
    );
    beardPath.lineTo(size.width / 2 + pixelSize * 8, size.height / 2);
    beardPath.close();

    canvas.drawPath(beardPath, paint);

    // Add texture with darker shade
    final texturePaint = Paint()
      ..color = beardColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 7 + i * pixelSize * 3,
          size.height / 2 + pixelSize * 2,
          pixelSize * 2,
          pixelSize * 6,
        ),
        texturePaint,
      );
    }
  }

  void _drawElfEars(Canvas canvas, Size size, double pixelSize) {
    final skinColor = _getSkinColor();
    final paint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    // Left ear
    final leftEarPath = Path();
    leftEarPath.moveTo(
      size.width / 2 - pixelSize * 10,
      size.height / 2 - pixelSize * 4,
    );
    leftEarPath.lineTo(
      size.width / 2 - pixelSize * 13,
      size.height / 2 - pixelSize * 8,
    );
    leftEarPath.lineTo(size.width / 2 - pixelSize * 10, size.height / 2);
    leftEarPath.close();
    canvas.drawPath(leftEarPath, paint);

    // Right ear
    final rightEarPath = Path();
    rightEarPath.moveTo(
      size.width / 2 + pixelSize * 10,
      size.height / 2 - pixelSize * 4,
    );
    rightEarPath.lineTo(
      size.width / 2 + pixelSize * 13,
      size.height / 2 - pixelSize * 8,
    );
    rightEarPath.lineTo(size.width / 2 + pixelSize * 10, size.height / 2);
    rightEarPath.close();
    canvas.drawPath(rightEarPath, paint);
  }

  void _drawHobbitHair(Canvas canvas, Size size, double pixelSize) {
    final hairPaint = Paint()
      ..color = const Color(0xFF654321)
      ..style = PaintingStyle.fill;

    // Curly hair on top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 10,
          size.height / 2 - pixelSize * 14,
          pixelSize * 20,
          pixelSize * 6,
        ),
        Radius.circular(pixelSize * 3),
      ),
      hairPaint,
    );
  }

  void _drawHumanHair(Canvas canvas, Size size, double pixelSize) {
    final hairPaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.fill;

    // Simple hair
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 10,
          size.height / 2 - pixelSize * 12,
          pixelSize * 20,
          pixelSize * 4,
        ),
        Radius.circular(pixelSize * 2),
      ),
      hairPaint,
    );
  }

  void _drawClassAccessories(Canvas canvas, Size size, double pixelSize) {
    switch (characterClass) {
      case CharacterClass.warrior:
        _drawHelmet(canvas, size, pixelSize);
        break;
      case CharacterClass.ranger:
        _drawHood(canvas, size, pixelSize);
        break;
      case CharacterClass.wizard:
        _drawWizardHat(canvas, size, pixelSize);
        break;
      case CharacterClass.rogue:
        _drawMask(canvas, size, pixelSize);
        break;
    }
  }

  void _drawHelmet(Canvas canvas, Size size, double pixelSize) {
    final helmetPaint = Paint()
      ..color = const Color(0xFF708090)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 11,
          size.height / 2 - pixelSize * 14,
          pixelSize * 22,
          pixelSize * 8,
        ),
        Radius.circular(pixelSize * 4),
      ),
      helmetPaint,
    );

    // Metallic shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2 - pixelSize * 4, size.height / 2 - pixelSize * 10),
      pixelSize * 2,
      shinePaint,
    );
  }

  void _drawHood(Canvas canvas, Size size, double pixelSize) {
    final hoodPaint = Paint()
      ..color = const Color(0xFF2F4F2F)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 12,
          size.height / 2 - pixelSize * 14,
          pixelSize * 24,
          pixelSize * 10,
        ),
        Radius.circular(pixelSize * 6),
      ),
      hoodPaint,
    );
  }

  void _drawWizardHat(Canvas canvas, Size size, double pixelSize) {
    final hatPaint = Paint()
      ..color = const Color(0xFF4B0082)
      ..style = PaintingStyle.fill;

    // Cone shape
    final hatPath = Path();
    hatPath.moveTo(size.width / 2, size.height / 2 - pixelSize * 20);
    hatPath.lineTo(
      size.width / 2 - pixelSize * 8,
      size.height / 2 - pixelSize * 10,
    );
    hatPath.lineTo(
      size.width / 2 + pixelSize * 8,
      size.height / 2 - pixelSize * 10,
    );
    hatPath.close();

    canvas.drawPath(hatPath, hatPaint);

    // Brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 10,
          size.height / 2 - pixelSize * 11,
          pixelSize * 20,
          pixelSize * 2,
        ),
        Radius.circular(pixelSize),
      ),
      hatPaint,
    );

    // Stars decoration
    final starPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2 - pixelSize * 2, size.height / 2 - pixelSize * 15),
      pixelSize * 0.8,
      starPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2 + pixelSize * 1, size.height / 2 - pixelSize * 17),
      pixelSize * 0.6,
      starPaint,
    );
  }

  void _drawMask(Canvas canvas, Size size, double pixelSize) {
    final maskPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Mask across eyes
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width / 2 - pixelSize * 10,
          size.height / 2 - pixelSize * 4,
          pixelSize * 20,
          pixelSize * 5,
        ),
        Radius.circular(pixelSize * 2),
      ),
      maskPaint,
    );
  }

  Color _getSkinColor() {
    switch (race) {
      case CharacterRace.elf:
        return const Color(0xFFFFE4C4); // Pale
      case CharacterRace.dwarf:
        return const Color(0xFFDEB887); // Tan
      case CharacterRace.hobbit:
        return const Color(0xFFF5CBA7); // Rosy
      case CharacterRace.human:
        return const Color(0xFFE8B896); // Medium
    }
  }

  Color _getEyeColor() {
    // Eye color based on class for variety
    switch (characterClass) {
      case CharacterClass.warrior:
        return const Color(0xFF8B4513); // Brown
      case CharacterClass.ranger:
        return const Color(0xFF228B22); // Green
      case CharacterClass.wizard:
        return const Color(0xFF4169E1); // Blue
      case CharacterClass.rogue:
        return const Color(0xFF696969); // Grey
    }
  }

  @override
  bool shouldRepaint(PixelArtAvatarPainter oldDelegate) {
    return oldDelegate.race != race ||
        oldDelegate.characterClass != characterClass;
  }
}
