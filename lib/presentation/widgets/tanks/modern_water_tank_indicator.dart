import 'dart:math';
import 'package:flutter/material.dart';

class ModernWaterTankIndicator extends StatefulWidget {
  final double percentageFilled;
  final double height;
  final double width;
  final Color? waterColor;
  final bool isFillingActive; // Para controlar si la bomba está activa

  const ModernWaterTankIndicator({
    Key? key,
    required this.percentageFilled,
    this.height = 200,
    this.width = 120,
    this.waterColor,
    this.isFillingActive = false, // Por defecto no está llenándose
  }) : super(key: key);

  @override
  State<ModernWaterTankIndicator> createState() => _ModernWaterTankIndicatorState();
}

class _ModernWaterTankIndicatorState extends State<ModernWaterTankIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  AnimationController? _fillAnimationController;
  Animation<double>? _fillAnimation;
  double _currentPercentage = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentPercentage = widget.percentageFilled;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ModernWaterTankIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cuando se activa la bomba, inicia la animación de llenado
    if (widget.isFillingActive && !oldWidget.isFillingActive) {
      _startFillingAnimation();
    }

    // Si solo cambia el porcentaje (sin activar la bomba)
    if (widget.percentageFilled != oldWidget.percentageFilled && !widget.isFillingActive) {
      setState(() {
        _currentPercentage = widget.percentageFilled;
      });
    }
  }

  void _startFillingAnimation() {
    // Evitar iniciar múltiples animaciones
    if (_isAnimating) return;
    _isAnimating = true;

    // Crear controlador de animación
    _fillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duración del llenado
    );


    _fillAnimation = Tween<double>(
      begin: _currentPercentage,
      end: 75.0, // Hasta un nivel óptimo que cambia el color a azul
    ).animate(
      CurvedAnimation(
        parent: _fillAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    // Actualizar el porcentaje mientras la animación progresa
    _fillAnimation!.addListener(() {
      if (mounted) {
        setState(() {
          _currentPercentage = _fillAnimation!.value;
        });
      }
    });

    // Iniciar la animación
    _fillAnimationController!.forward().then((_) {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();

    // Limpiar el controlador de animación de llenado si existe
    _fillAnimationController?.dispose();

    super.dispose();
  }

  Color _getWaterColor() {
    if (widget.waterColor != null) {
      return widget.waterColor!;
    }

    // Usar _currentPercentage en lugar de widget.percentageFilled
    if (_currentPercentage < 20) {
      return Colors.red;
    } else if (_currentPercentage < 50) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.grey.shade900
        : Colors.grey.shade200;
    final borderColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final waterColor = _getWaterColor();

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.width / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            // Tanque de fondo con borde
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular((widget.width - 8) / 2),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.white, Colors.grey.shade100],
                ),
              ),
            ),

            // Nivel de agua animado
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return ClipPath(
                  clipper: WaterClipper(
                    percentageFilled: _currentPercentage / 100, // Usar porcentaje actual
                    waveHeight: 10.0,
                    animation: _animationController.value,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((widget.width - 8) / 2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          waterColor.withOpacity(0.7),
                          waterColor,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Efecto de burbujas en agua
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BubblesPainter(
                              waterColor: waterColor,
                              animation: _animationController,
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
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: List.generate(5, (index) {
                    final level = 100 - index * 25;
                    final position = constraints.maxHeight * (1 - level / 100);

                    return Positioned(
                      top: position,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    );
                  }),
                );
              },
            ),

            // Indicador de porcentaje
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "${_currentPercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: _currentPercentage > 30 || isDarkMode
                        ? Colors.white
                        : Colors.black,
                    fontSize: min(widget.width / 5, 20),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Brillo superior
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              height: widget.height * 0.1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular((widget.width - 16) / 2),
                    topRight: Radius.circular((widget.width - 16) / 2),
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

// Clipper para el agua con efecto ondulado
class WaterClipper extends CustomClipper<Path> {
  final double percentageFilled;
  final double waveHeight;
  final double animation;

  WaterClipper({
    required this.percentageFilled,
    required this.waveHeight,
    required this.animation,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final waterHeight = size.height * (1 - percentageFilled);

    path.moveTo(0, waterHeight);

    // Crear ondulación del agua
    for (double x = 0; x <= size.width; x++) {
      final waveSin = sin((x / size.width * 2 * pi) + (animation * 2 * pi));
      final y = waterHeight + waveSin * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaterClipper oldClipper) =>
      oldClipper.percentageFilled != percentageFilled ||
          oldClipper.animation != animation;
}

// Efecto de burbujas en el agua
class BubblesPainter extends CustomPainter {
  final Color waterColor;
  final AnimationController animation;

  BubblesPainter({required this.waterColor, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Semilla fija para que las burbujas sean consistentes

    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Crear burbujas aleatorias
    for (int i = 0; i < 10; i++) {
      final bubbleSize = random.nextDouble() * 10 + 2;
      final xPos = random.nextDouble() * size.width;

      // Posición Y animada para que las burbujas suban
      final startYPercent = random.nextDouble();
      final yOffset = animation.value * size.height;
      final yPos = size.height * startYPercent - yOffset;

      // Solo dibujar burbujas que son visibles
      if (yPos + bubbleSize >= 0 && yPos <= size.height) {
        canvas.drawCircle(
          Offset(xPos, yPos % size.height),
          bubbleSize,
          bubblePaint,
        );
      }
    }

    // Efecto de brillo en la parte superior del agua
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0),
        ],
        stops: const [0.0, 0.3, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) => true;
}