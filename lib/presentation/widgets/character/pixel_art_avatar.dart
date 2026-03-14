import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../domain/entities/character.dart';

/// TRUE pixel art avatar with visible square pixels
class PixelArtAvatar extends StatefulWidget {
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
  State<PixelArtAvatar> createState() => _PixelArtAvatarState();
}

class _PixelArtAvatarState extends State<PixelArtAvatar> {
  late Future<ui.Image> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _generatePixelArt();
  }

  @override
  void didUpdateWidget(covariant PixelArtAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.race != widget.race ||
        oldWidget.characterClass != widget.characterClass) {
      // Regenerate the pixel art only when the relevant properties change.
      _imageFuture = _generatePixelArt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: widget.showBorder
          ? BoxDecoration(
              border: Border.all(color: _getBorderColor(), width: 3),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: FutureBuilder<ui.Image>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.showBorder ? 2 : 0),
            child: CustomPaint(
              painter: PixelArtPainter(snapshot.data!),
              size: Size(widget.size, widget.size),
            ),
          );
        },
      ),
    );
  }

  Color _getBorderColor() {
    switch (widget.characterClass) {
      case CharacterClass.warrior:
        return const Color(0xFFB22222);
      case CharacterClass.ranger:
        return const Color(0xFF228B22);
      case CharacterClass.wizard:
        return const Color(0xFF4169E1);
      case CharacterClass.rogue:
        return const Color(0xFF8B008B);
    }
  }

  Future<ui.Image> _generatePixelArt() async {
    const pixelWidth = 32;
    const pixelHeight = 32;

    // Create pixel buffer
    final pixels = List.generate(
      pixelHeight,
      (_) => List.filled(pixelWidth, const Color(0x00000000)),
    );

    // Draw pixels based on race and class
    _drawPixels(pixels);

    // Convert to image
    return _pixelsToImage(pixels);
  }

  void _drawPixels(List<List<Color>> pixels) {
    final skinColor = _getSkinColor();
    final hairColor = _getHairColor();
    final eyeColor = _getEyeColor();

    // Background
    _fillRect(pixels, 0, 0, 32, 32, const Color(0xFFECECEC));

    // Head (16x16 centered)
    _fillRect(pixels, 8, 8, 16, 16, skinColor);

    // Eyes (2 pixels each)
    _setPixel(pixels, 12, 14, Colors.white);
    _setPixel(pixels, 13, 14, Colors.white);
    _setPixel(pixels, 18, 14, Colors.white);
    _setPixel(pixels, 19, 14, Colors.white);

    _setPixel(pixels, 12, 14, eyeColor);
    _setPixel(pixels, 18, 14, eyeColor);

    // Racial features
    switch (race) {
      case CharacterRace.dwarf:
        _drawDwarfBeard(pixels, hairColor);
        break;
      case CharacterRace.elf:
        _drawElfEars(pixels, skinColor);
        break;
      case CharacterRace.hobbit:
        _drawHobbitHair(pixels, hairColor);
        break;
      case CharacterRace.human:
        _drawHumanHair(pixels, hairColor);
        break;
    }

    // Class accessories
    switch (characterClass) {
      case CharacterClass.warrior:
        _drawHelmet(pixels);
        break;
      case CharacterClass.ranger:
        _drawHood(pixels);
        break;
      case CharacterClass.wizard:
        _drawWizardHat(pixels);
        break;
      case CharacterClass.rogue:
        _drawMask(pixels);
        break;
    }
  }

  void _drawDwarfBeard(List<List<Color>> pixels, Color color) {
    // Beard pixels
    _fillRect(pixels, 10, 20, 12, 6, color);
    _setPixel(pixels, 9, 21, color);
    _setPixel(pixels, 22, 21, color);
  }

  void _drawElfEars(List<List<Color>> pixels, Color color) {
    // Left ear
    _setPixel(pixels, 6, 12, color);
    _setPixel(pixels, 7, 11, color);
    _setPixel(pixels, 7, 12, color);

    // Right ear
    _setPixel(pixels, 25, 12, color);
    _setPixel(pixels, 24, 11, color);
    _setPixel(pixels, 24, 12, color);
  }

  void _drawHobbitHair(List<List<Color>> pixels, Color color) {
    // Curly hair on top
    _fillRect(pixels, 8, 6, 16, 3, color);
  }

  void _drawHumanHair(List<List<Color>> pixels, Color color) {
    // Simple hair
    _fillRect(pixels, 8, 7, 16, 2, color);
  }

  void _drawHelmet(List<List<Color>> pixels) {
    const helmetColor = Color(0xFF708090);
    _fillRect(pixels, 7, 6, 18, 4, helmetColor);
    // Visor
    _fillRect(pixels, 9, 13, 14, 2, helmetColor);
  }

  void _drawHood(List<List<Color>> pixels) {
    const hoodColor = Color(0xFF2F4F2F);
    _fillRect(pixels, 6, 5, 20, 5, hoodColor);
  }

  void _drawWizardHat(List<List<Color>> pixels) {
    const hatColor = Color(0xFF4B0082);
    // Cone
    for (int y = 0; y < 6; y++) {
      int width = 16 - (y * 2);
      int x = 8 + y;
      _fillRect(pixels, x, y, width, 1, hatColor);
    }
    // Brim
    _fillRect(pixels, 6, 6, 20, 2, hatColor);
    // Stars
    _setPixel(pixels, 14, 3, const Color(0xFFFFD700));
    _setPixel(pixels, 17, 2, const Color(0xFFFFD700));
  }

  void _drawMask(List<List<Color>> pixels) {
    // Black mask across eyes
    _fillRect(pixels, 8, 13, 16, 3, Colors.black);
    // Eye cutouts
    _fillRect(pixels, 11, 14, 3, 1, Colors.white);
    _fillRect(pixels, 18, 14, 3, 1, Colors.white);
  }

  Color _getSkinColor() {
    switch (race) {
      case CharacterRace.elf:
        return const Color(0xFFFFE4C4);
      case CharacterRace.dwarf:
        return const Color(0xFFDEB887);
      case CharacterRace.hobbit:
        return const Color(0xFFF5CBA7);
      case CharacterRace.human:
        return const Color(0xFFE8B896);
    }
  }

  Color _getHairColor() {
    switch (race) {
      case CharacterRace.dwarf:
        return const Color(0xFF8B4513);
      case CharacterRace.elf:
        return const Color(0xFFFFD700);
      case CharacterRace.hobbit:
        return const Color(0xFF654321);
      case CharacterRace.human:
        return const Color(0xFF4A3728);
    }
  }

  Color _getEyeColor() {
    switch (characterClass) {
      case CharacterClass.warrior:
        return const Color(0xFF8B4513);
      case CharacterClass.ranger:
        return const Color(0xFF228B22);
      case CharacterClass.wizard:
        return const Color(0xFF4169E1);
      case CharacterClass.rogue:
        return const Color(0xFF696969);
    }
  }

  void _setPixel(List<List<Color>> pixels, int x, int y, Color color) {
    if (x >= 0 && x < pixels[0].length && y >= 0 && y < pixels.length) {
      pixels[y][x] = color;
    }
  }

  void _fillRect(
    List<List<Color>> pixels,
    int x,
    int y,
    int width,
    int height,
    Color color,
  ) {
    for (int dy = 0; dy < height; dy++) {
      for (int dx = 0; dx < width; dx++) {
        _setPixel(pixels, x + dx, y + dy, color);
      }
    }
  }

  Future<ui.Image> _pixelsToImage(List<List<Color>> pixels) async {
    final height = pixels.length;
    final width = pixels[0].length;

    // Create byte data (RGBA format)
    final bytes = <int>[];
    for (final row in pixels) {
      for (final color in row) {
        bytes.add((color.r * 255.0).round().clamp(0, 255));
        bytes.add((color.g * 255.0).round().clamp(0, 255));
        bytes.add((color.b * 255.0).round().clamp(0, 255));
        bytes.add((color.a * 255.0).round().clamp(0, 255));
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List.fromList(bytes),
      width,
      height,
      ui.PixelFormat.rgba8888,
      (image) => completer.complete(image),
    );

    return completer.future;
  }
}

class PixelArtPainter extends CustomPainter {
  final ui.Image image;

  PixelArtPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Use nearest-neighbor filtering for sharp pixels
    final paint = Paint()
      ..filterQuality = FilterQuality
          .none // This is the key!
      ..isAntiAlias = false;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(PixelArtPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
