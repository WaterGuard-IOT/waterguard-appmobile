// lib/presentation/widgets/tanks/modern_water_tank_indicator.dart - MEJORADO
import 'dart:math';
import 'package:flutter/material.dart';

class ModernWaterTankIndicator extends StatefulWidget {
  final double percentageFilled;
  final double height;
  final double width;
  final bool isFillingActive;
  final bool showDetails;

  const ModernWaterTankIndicator({
    Key? key,
    required this.percentageFilled,
    this.height = 200,
    this.width = 120,
    this.isFillingActive = false,
    this.showDetails = true,
  }) : super(key: key);

  @override
  State<ModernWaterTankIndicator> createState() => _ModernWaterTankIndicatorState();
}

class _ModernWaterTankIndicatorState extends State<ModernWaterTankIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _fillingAnimationController;
  late AnimationController _pumpIndicatorController;
  late Animation<double> _fillAnimation;

  double _currentDisplayPercentage = 0.0;

  @override
  void initState() {
    super.initState();

    // Controlador para las ondas del agua
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Controlador para la animación de llenado
    _fillingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controlador para el indicador de bomba
    _pumpIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animación para transiciones suaves del nivel
    _fillAnimation = Tween<double>(
      begin: _currentDisplayPercentage,
      end: widget.percentageFilled,
    ).animate(CurvedAnimation(
      parent: _fillingAnimationController,
      curve: Curves.easeInOut,
    ));

    _currentDisplayPercentage = widget.percentageFilled;
    _updateAnimations();
  }

  @override
  void didUpdateWidget(ModernWaterTankIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animar cambios en el nivel del agua
    if (widget.percentageFilled != oldWidget.percentageFilled) {
      _fillAnimation = Tween<double>(
        begin: _currentDisplayPercentage,
        end: widget.percentageFilled,
      ).animate(CurvedAnimation(
        parent: _fillingAnimationController,
        curve: Curves.easeInOut,
      ));

      _fillingAnimationController.reset();
      _fillingAnimationController.forward();
      _currentDisplayPercentage = widget.percentageFilled;
    }

    // Controlar animación de bomba
    if (widget.isFillingActive != oldWidget.isFillingActive) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isFillingActive) {
      _pumpIndicatorController.repeat();
    } else {
      _pumpIndicatorController.stop();
    }
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _fillingAnimationController.dispose();
    _pumpIndicatorController.dispose();
    super.dispose();
  }

  Color _getWaterColor() {
    final percentage = widget.percentageFilled;
    if (percentage < 20) {
      return Colors.red.shade600;
    } else if (percentage < 50) {
      return Colors.orange.shade600;
    } else if (percentage < 80) {
      return Colors.blue.shade600;
    } else {
      return Colors.green.shade600;
    }
  }

  Color _getStatusColor() {
    final percentage = widget.percentageFilled;
    if (percentage < 20) return Colors.red;
    if (percentage < 50) return Colors.orange;
    if (percentage < 80) return Colors.blue;
    return Colors.green;
  }

  String _getStatusText() {
    final percentage = widget.percentageFilled;
    if (percentage < 20) return 'Crítico';
    if (percentage < 50) return 'Bajo';
    if (percentage < 80) return 'Normal';
    return 'Óptimo';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200;
    final borderColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
    final waterColor = _getWaterColor();

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de bomba
          if (widget.isFillingActive) _buildPumpIndicator(),

          const SizedBox(height: 8),

          // Tanque principal
          Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(widget.width / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(isDarkMode ? 0.05 : 0.8),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Stack(
                children: [
                  // Contenedor interno del tanque
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular((widget.width - 12) / 2),
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [Colors.grey.shade800, Colors.grey.shade900]
                            : [Colors.white, Colors.grey.shade50],
                      ),
                    ),
                  ),

                  // Agua animada
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _waveAnimationController,
                      _fillAnimation,
                    ]),
                    builder: (context, child) {
                      final currentPercentage = _fillAnimation.value;

                      return ClipPath(
                        clipper: WaterClipper(
                          percentageFilled: currentPercentage / 100,
                          waveHeight: widget.isFillingActive ? 12.0 : 6.0,
                          animationValue: _waveAnimationController.value,
                          isActive: widget.isFillingActive,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular((widget.width - 12) / 2),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                waterColor.withOpacity(0.6),
                                waterColor,
                                waterColor.withOpacity(0.9),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Efecto de burbujas cuando la bomba está activa
                              if (widget.isFillingActive)
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: _pumpIndicatorController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: BubblesPainter(
                                          animation: _pumpIndicatorController,
                                          waterLevel: currentPercentage / 100,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // Efecto de flujo hacia arriba cuando se llena
                              if (widget.isFillingActive)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: FlowEffectPainter(
                                      animation: _waveAnimationController,
                                      waterColor: waterColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Marcadores de nivel
                  _buildLevelMarkers(),

                  // Texto del porcentaje
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${widget.percentageFilled.toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: min(widget.width / 6, 16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.showDetails) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getStatusColor(),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Estado de llenado
          if (widget.isFillingActive && widget.showDetails) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pumpIndicatorController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pumpIndicatorController.value * 0.1),
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                          size: 16,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Llenando...',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPumpIndicator() {
    return AnimatedBuilder(
      animation: _pumpIndicatorController,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: 1.0 + (_pumpIndicatorController.value * 0.2),
              child: Icon(
                Icons.power,
                color: Colors.green,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelMarkers() {
    return Positioned.fill(
      child: CustomPaint(
        painter: LevelMarkersPainter(
          tankHeight: widget.height - 12,
          tankWidth: widget.width - 12,
        ),
      ),
    );
  }
}

class WaterClipper extends CustomClipper<Path> {
  final double percentageFilled;
  final double waveHeight;
  final double animationValue;
  final bool isActive;

  WaterClipper({
    required this.percentageFilled,
    required this.waveHeight,
    required this.animationValue,
    required this.isActive,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final waterHeight = size.height * (1 - percentageFilled);
    final adjustedWaveHeight = isActive ? waveHeight : waveHeight * 0.5;

    // Crear ondas más dinámicas
    path.moveTo(0, waterHeight);

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;

      // Múltiples ondas superpuestas para efecto más realista
      final wave1 = sin((normalizedX * 2 * pi) + (animationValue * 2 * pi));
      final wave2 = sin((normalizedX * 4 * pi) - (animationValue * 2 * pi)) * 0.5;
      final wave3 = sin((normalizedX * 6 * pi) + (animationValue * 3 * pi)) * 0.3;

      final combinedWave = wave1 + wave2 + wave3;
      final y = waterHeight + combinedWave * adjustedWaveHeight;

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
  final double waterLevel;

  BubblesPainter({
    required this.animation,
    required this.waterLevel,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Semilla fija para consistencia
    final bubblePaint = Paint()..color = Colors.white.withOpacity(0.4);

    for (int i = 0; i < 20; i++) {
      final bubbleSize = random.nextDouble() * 6 + 2;
      final xPos = random.nextDouble() * size.width;
      final baseYPos = size.height * 0.9; // Empezar desde abajo

      // Movimiento hacia arriba con variación
      final yOffset = (animation.value + random.nextDouble() * 0.5) % 1.0;
      final yPos = baseYPos - (yOffset * size.height * 0.8);

      // Solo dibujar burbujas dentro del área de agua
      final waterSurface = size.height * (1 - waterLevel);
      if (yPos > waterSurface) {
        // Efecto de desvanecimiento hacia arriba
        final opacity = 1.0 - (yOffset * 0.7);
        bubblePaint.color = Colors.white.withOpacity(0.4 * opacity);

        canvas.drawCircle(Offset(xPos, yPos), bubbleSize, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) => false;
}

class FlowEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final Color waterColor;

  FlowEffectPainter({
    required this.animation,
    required this.waterColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waterColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Líneas verticales que representan el flujo
    for (int i = 0; i < 5; i++) {
      final xPos = (size.width / 6) * (i + 1);
      final startY = size.height * 0.8;
      final endY = startY - (animation.value * 30);

      if (endY > 0) {
        paint.color = waterColor.withOpacity(0.3 * (1 - animation.value));
        canvas.drawLine(
          Offset(xPos, startY),
          Offset(xPos, endY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FlowEffectPainter oldDelegate) => false;
}

class LevelMarkersPainter extends CustomPainter {
  final double tankHeight;
  final double tankWidth;

  LevelMarkersPainter({
    required this.tankHeight,
    required this.tankWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Marcadores cada 25%
    for (int i = 1; i < 4; i++) {
      final y = tankHeight * i / 4;
      canvas.drawLine(
        Offset(tankWidth * 0.85, y),
        Offset(tankWidth * 0.95, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LevelMarkersPainter oldDelegate) => false;
}