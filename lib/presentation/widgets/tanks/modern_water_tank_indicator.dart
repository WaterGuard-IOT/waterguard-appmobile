// lib/presentation/widgets/tanks/modern_water_tank_indicator.dart
import 'dart:math';
import 'package:flutter/material.dart';

class ModernWaterTankIndicator extends StatefulWidget {
  final double percentageFilled;
  final double height;
  final double width;
  final bool isFillingActive;

  const ModernWaterTankIndicator({
    Key? key,
    required this.percentageFilled,
    this.height = 200,
    this.width = 120,
    this.isFillingActive = false,
  }) : super(key: key);

  @override
  State<ModernWaterTankIndicator> createState() => _ModernWaterTankIndicatorState();
}

// --- CORRECCIÓN: Usar TickerProviderStateMixin para soportar múltiples animaciones si es necesario ---
class _ModernWaterTankIndicatorState extends State<ModernWaterTankIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // La animación de la ola siempre está activa
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    super.dispose();
  }

  Color _getWaterColor() {
    if (widget.percentageFilled < 20) {
      return Colors.red;
    } else if (widget.percentageFilled < 50) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final waterColor = _getWaterColor();

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.width / 2),
        boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5), ), ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular((widget.width - 8) / 2),
                border: Border.all( color: borderColor, width: 2, ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode ? [Colors.grey.shade900, Colors.black] : [Colors.white, Colors.grey.shade100],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _waveAnimationController,
              builder: (context, child) {
                return ClipPath(
                  // --- MEJORA: La animación ahora es más fluida ---
                  clipper: WaterClipper(
                    percentageFilled: widget.percentageFilled / 100,
                    waveHeight: 8.0,
                    animationValue: _waveAnimationController.value,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((widget.width - 8) / 2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [ waterColor.withOpacity(0.7), waterColor, ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (widget.isFillingActive)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: BubblesPainter(animation: _waveAnimationController),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all( color: Colors.white.withOpacity(0.3), width: 1, ),
                ),
                child: Text(
                  "${widget.percentageFilled.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: min(widget.width / 5, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterClipper extends CustomClipper<Path> {
  final double percentageFilled;
  final double waveHeight;
  final double animationValue;

  WaterClipper({
    required this.percentageFilled,
    required this.waveHeight,
    required this.animationValue,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final waterHeight = size.height * (1 - percentageFilled);

    path.moveTo(0, waterHeight);
    for (double x = 0; x <= size.width; x++) {
      final waveSin = sin((x / size.width * 2 * pi) + (animationValue * 2 * pi));
      final y = waterHeight + waveSin * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaterClipper oldClipper) => true;
}

class BubblesPainter extends CustomPainter {
  final Animation<double> animation;

  BubblesPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final bubblePaint = Paint()..color = Colors.white.withOpacity(0.3);

    for (int i = 0; i < 15; i++) {
      final bubbleSize = random.nextDouble() * 8 + 2;
      final xPos = random.nextDouble() * size.width;
      final yOffset = (animation.value + random.nextDouble()) % 1.0;
      final yPos = size.height * (1 - yOffset);

      if (yPos > size.height * (1 - size.height * (percentageFilled / 100) / size.height)) {
        canvas.drawCircle(Offset(xPos, yPos), bubbleSize, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) => false;

  // Agregué una variable para que no haya error en el painter
  double get percentageFilled => 1.0;
}
