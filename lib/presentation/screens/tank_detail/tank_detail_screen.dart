import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/presentation/blocs/tank/tank_bloc.dart';
import 'package:waterguard/presentation/blocs/tank/tank_event.dart';
import 'package:waterguard/presentation/blocs/tank/tank_state.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/tanks/modern_water_tank_indicator.dart';

class TankDetailScreen extends StatefulWidget {
  final String tankId;

  const TankDetailScreen({Key? key, required this.tankId}) : super(key: key);

  @override
  State<TankDetailScreen> createState() => _TankDetailScreenState();
}

class _TankDetailScreenState extends State<TankDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar los datos del tanque
    context.read<TankBloc>().add(LoadTankDetail(tankId: widget.tankId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Tanque'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Calidad'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: BlocBuilder<TankBloc, TankState>(
        builder: (context, state) {
          if (state is TankLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TankDetailLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(context, state),
                _buildQualityTab(context, state),
                _buildHistoricalTab(context, state),
              ],
            );
          } else if (state is TankError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TankBloc>().add(LoadTankDetail(tankId: widget.tankId));
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Cargando datos...'));
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildGeneralTab(BuildContext context, TankDetailLoaded state) {
    final tank = state.tank;
    final levelPercentage = tank.levelPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del tanque
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tank.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ubicación: ${tank.location['address']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última actualización: ${DateFormat('dd/MM/yyyy HH:mm').format(tank.lastUpdated)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nivel de agua actual
          Text(
            'Nivel de Agua',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Indicador visual del nivel
          Center(
            child: ModernWaterTankIndicator(
              percentageFilled: levelPercentage,
              height: 220,
              width: 120,
              waterColor: _getWaterLevelColor(levelPercentage),
              isFillingActive: tank.pumpActive,
            ),
          ),

          const SizedBox(height: 16),

          // Detalles del nivel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'Capacidad total:',
                    '${tank.capacity.toStringAsFixed(0)} L',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Nivel actual:',
                    '${tank.currentLevel.toStringAsFixed(0)} L',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Nivel crítico:',
                    '${tank.criticalLevel.toStringAsFixed(0)} L',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Nivel óptimo:',
                    '${tank.optimalLevel.toStringAsFixed(0)} L',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Estado de la bomba
          Text(
            'Estado de la Bomba',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: tank.pumpActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tank.pumpActive ? Icons.power : Icons.power_off,
                      color: tank.pumpActive ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tank.pumpActive ? 'Bomba Activa' : 'Bomba Inactiva',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: tank.pumpActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tank.pumpActive
                              ? 'La bomba está funcionando para llenar el tanque.'
                              : 'La bomba está apagada actualmente.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTab(BuildContext context, TankDetailLoaded state) {
    final quality = state.waterQuality;

    if (quality == null) {
      return const Center(
        child: Text('No hay datos de calidad disponibles para este tanque.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de calidad
          Card(
            color: _getQualityColor(quality.status).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getQualityColor(quality.status).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getQualityIcon(quality.status),
                      color: _getQualityColor(quality.status),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getQualityTitle(quality.status),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getQualityColor(quality.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getQualityDescription(quality.status),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Última medición: ${DateFormat('dd/MM/yyyy HH:mm').format(quality.timestamp)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Indicadores clave
          Text(
            'Parámetros de Calidad',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // pH
          _buildParameterCard(
            context,
            'pH',
            quality.ph.toString(),
            quality.isPhNormal ? 'Normal' : 'Fuera de rango',
            quality.isPhNormal ? Colors.green : Colors.orange,
            Icons.science,
            'El pH mide la acidez del agua. Rango ideal: 6.5 - 8.5',
          ),

          const SizedBox(height: 16),

          // Temperatura
          _buildParameterCard(
            context,
            'Temperatura',
            '${quality.temperature.toString()} °C',
            quality.isTemperatureNormal ? 'Normal' : 'Fuera de rango',
            quality.isTemperatureNormal ? Colors.green : Colors.orange,
            Icons.thermostat,
            'Temperatura del agua. Rango ideal: 15°C - 25°C',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTab(BuildContext context, TankDetailLoaded state) {
    if (state.historicalData.isEmpty) {
      return const Center(
        child: Text('No hay datos históricos disponibles para este tanque.'),
      );
    }

    // Preparar los datos para el gráfico
    final spots = state.historicalData.asMap().entries.map((entry) {
      final data = entry.value;
      return FlSpot(
        entry.key.toDouble(),
        data['level'].toDouble(),
      );
    }).toList();

    // Colores que funcionan en ambos temas
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDarkMode ? Colors.lightBlue : Colors.blue;
    final gradientColor = isDarkMode ? Colors.lightBlue.withOpacity(0.3) : Colors.blue.withOpacity(0.2);
    final gridColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveles Históricos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Últimos 7 días',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Gráfico de línea mejorado
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  verticalInterval: 1,
                  horizontalInterval: state.tank.capacity / 5,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: gridColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: state.tank.capacity / 5,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}L',
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < state.historicalData.length) {
                          final data = state.historicalData[value.toInt()];
                          final date = DateTime.parse(data['timestamp']);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 35,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: gridColor,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (state.historicalData.length - 1).toDouble(),
                minY: 0,
                maxY: state.tank.capacity * 1.1, // Un poco más para dar espacio

                // Configuración del tooltip mejorado
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => isDarkMode
                        ? Colors.grey.shade800
                        : Colors.white,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        final dataIndex = flSpot.x.toInt();

                        if (dataIndex >= 0 && dataIndex < state.historicalData.length) {
                          final data = state.historicalData[dataIndex];
                          final date = DateTime.parse(data['timestamp']);
                          final level = flSpot.y;

                          return LineTooltipItem(
                            '${DateFormat('dd/MM/yyyy').format(date)}\n${level.toInt()} L',
                            TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                    tooltipBorder: BorderSide(
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade400,
                      width: 1,
                    ),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                  ),
                  handleBuiltInTouches: true,
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: lineColor,
                          strokeWidth: 2,
                          dashArray: [3, 3],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: lineColor,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: isDarkMode ? Colors.white : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          gradientColor,
                          gradientColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Leyenda mejorada
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                // Primera fila: Indicador de línea
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 3,
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nivel de agua (L)',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Segunda fila: Instrucciones de interacción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Toca los puntos para más detalles',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return BlocBuilder<TankBloc, TankState>(
      builder: (context, state) {
        if (state is TankDetailLoaded) {
          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón para controlar la bomba
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Mostrar diálogo de confirmación
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              state.tank.pumpActive
                                  ? 'Desactivar Bomba'
                                  : 'Activar Bomba',
                            ),
                            content: Text(
                              state.tank.pumpActive
                                  ? '¿Estás seguro de que deseas desactivar la bomba?'
                                  : '¿Estás seguro de que deseas activar la bomba?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();

                                  // Para el prototipo, podemos simplemente llamar a TogglePump
                                  // y luego forzar un setState para iniciar la animación
                                  context.read<TankBloc>().add(
                                    TogglePump(
                                      tankId: state.tank.id,
                                      active: !state.tank.pumpActive,
                                    ),
                                  );

                                  // Si estás activando la bomba, simula el llenado
                                  if (!state.tank.pumpActive) {
                                    // Para prototipo, podemos usar algo simple como esto
                                    Future.delayed(Duration(milliseconds: 500), () {
                                      setState(() {
                                        // Este setState forzará la reconstrucción del widget con isFillingActive=true
                                      });
                                    });
                                  }
                                },
                                child: const Text('Confirmar'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        state.tank.pumpActive
                            ? Icons.power_off
                            : Icons.power,
                      ),
                      label: Text(
                        state.tank.pumpActive
                            ? 'Desactivar Bomba'
                            : 'Activar Bomba',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.tank.pumpActive
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(
      BuildContext context,
      String title,
      String value,
      String status,
      Color statusColor,
      IconData icon,
      String description,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Color _getWaterLevelColor(double percentage) {
    if (percentage < 20) {
      return const Color(0xFFF44336); // Rojo crítico
    } else if (percentage < 50) {
      return const Color(0xFFFF9800); // Naranja advertencia
    } else {
      return const Color(0xFF2196F3); // Azul óptimo
    }
  }

  Color _getQualityColor(String status) {
    switch (status) {
      case 'excellent':
      case 'good':
        return const Color(0xFF4CAF50); // Verde bueno
      case 'acceptable':
        return const Color(0xFFFF9800); // Naranja aceptable
      case 'poor':
        return const Color(0xFFF44336); // Rojo malo
      default:
        return const Color(0xFF9E9E9E); // Gris desconocido
    }
  }

  IconData _getQualityIcon(String status) {
    switch (status) {
      case 'excellent':
      case 'good':
        return Icons.check_circle;
      case 'acceptable':
        return Icons.info;
      case 'poor':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getQualityTitle(String status) {
    switch (status) {
      case 'excellent':
        return 'Calidad Excelente';
      case 'good':
        return 'Buena Calidad';
      case 'acceptable':
        return 'Calidad Aceptable';
      case 'poor':
        return 'Calidad Deficiente';
      default:
        return 'Calidad Desconocida';
    }
  }

  String _getQualityDescription(String status) {
    switch (status) {
      case 'excellent':
        return 'El agua está en condiciones óptimas.';
      case 'good':
        return 'El agua es segura para su uso.';
      case 'acceptable':
        return 'El agua es utilizable pero requiere vigilancia.';
      case 'poor':
        return 'El agua requiere atención inmediata.';
      default:
        return 'No hay suficiente información sobre la calidad del agua.';
    }
  }

  Color _getContrastingTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}