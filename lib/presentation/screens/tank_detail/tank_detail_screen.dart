// lib/presentation/screens/tank_detail/tank_detail_screen.dart - MEJORADO
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/app/routes/app_router.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_event.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:waterguard/presentation/blocs/tank/tank_bloc.dart';
import 'package:waterguard/presentation/blocs/tank/tank_event.dart' as detail_events;
import 'package:waterguard/presentation/blocs/tank/tank_state.dart' as detail_states;
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
    context.read<TankBloc>().add(detail_events.LoadTankDetail(tankId: widget.tankId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(BuildContext context, Tank tank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar "${tank.name}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TankBloc>().add(detail_events.DeleteTank(tankId: int.parse(tank.id)));
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Tanque'),
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashboardState) {
              if (dashboardState is DashboardLoaded) {
                final tankMatches = dashboardState.tanks.where((t) => t.id == widget.tankId);
                if (tankMatches.isEmpty) return const SizedBox.shrink();
                final tank = tankMatches.first;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar Tanque',
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.editTank,
                          arguments: { 'tank': tank, 'bloc': context.read<TankBloc>(), },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Eliminar Tanque',
                      onPressed: () => _showDeleteConfirmationDialog(context, tank),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'General'),
            Tab(icon: Icon(Icons.science), text: 'Calidad'),
            Tab(icon: Icon(Icons.timeline), text: 'Histórico'),
          ],
        ),
      ),
      body: BlocListener<TankBloc, detail_states.TankState>(
        listener: (context, state) {
          if (state is detail_states.TankError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is detail_states.TankDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanque eliminado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DashboardBloc>().add(RefreshDashboard());
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<TankBloc, detail_states.TankState>(
          builder: (detailContext, detailState) {
            if (detailState is detail_states.TankLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (detailState is detail_states.TankError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(detailState.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TankBloc>().add(detail_events.LoadTankDetail(tankId: widget.tankId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildQualityTab(detailState),
                _buildHistoricalTab(detailState),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildGeneralTab() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        if (dashboardState is! DashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final tankMatches = dashboardState.tanks.where((t) => t.id == widget.tankId);
        if (tankMatches.isEmpty) {
          return const Center(child: Text("Tanque no encontrado. Pudo haber sido eliminado."));
        }
        final tank = tankMatches.first;

        final levelPercentage = tank.capacity > 0 ? (tank.currentLevel / tank.capacity) * 100 : 0.0;
        final criticalLevelInLiters = tank.capacity * (tank.criticalLevel / 100);
        final optimalLevelInLiters = tank.capacity * (tank.optimalLevel / 100);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del tanque
              _buildTankHeader(tank),
              const SizedBox(height: 24),

              // Indicador principal del tanque
              Text(
                'Nivel de Agua',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ModernWaterTankIndicator(
                  percentageFilled: levelPercentage,
                  height: 280,
                  width: 140,
                  isFillingActive: tank.pumpActive,
                  showDetails: true,
                ),
              ),
              const SizedBox(height: 24),

              // Estadísticas detalladas
              _buildDetailedStats(tank, levelPercentage, criticalLevelInLiters, optimalLevelInLiters),
              const SizedBox(height: 24),

              // Estado de la bomba
              _buildPumpStatus(tank),
              const SizedBox(height: 24),

              // Información de ubicación
              _buildLocationInfo(tank),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTankHeader(Tank tank) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tank.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${tank.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Última actualización: ${DateFormat('dd/MM/yyyy HH:mm').format(tank.lastUpdated)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(Tank tank, double levelPercentage, double criticalLevelInLiters, double optimalLevelInLiters) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Tanque',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Capacidad total:', '${tank.capacity.toStringAsFixed(0)} L', Icons.straighten),
            const Divider(),
            _buildStatRow(
              'Nivel actual:',
              '${tank.currentLevel.toStringAsFixed(0)} L (${levelPercentage.toStringAsFixed(1)}%)',
              Icons.water_drop,
              valueColor: _getPercentageColor(levelPercentage),
            ),
            const Divider(),
            _buildStatRow(
              'Nivel crítico:',
              '${tank.criticalLevel.toStringAsFixed(0)}% (${criticalLevelInLiters.toStringAsFixed(0)} L)',
              Icons.warning_amber,
              valueColor: Colors.red.shade600,
            ),
            const Divider(),
            _buildStatRow(
              'Nivel óptimo:',
              '${tank.optimalLevel.toStringAsFixed(0)}% (${optimalLevelInLiters.toStringAsFixed(0)} L)',
              Icons.check_circle_outline,
              valueColor: Colors.green.shade600,
            ),
            const Divider(),
            _buildStatRow(
              'Estado:',
              _getStatusText(tank.status),
              Icons.info_outline,
              valueColor: _getStatusColor(tank.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPumpStatus(Tank tank) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Bomba',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: tank.pumpActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tank.pumpActive ? Colors.green : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    tank.pumpActive ? Icons.power : Icons.power_off,
                    color: tank.pumpActive ? Colors.green : Colors.grey,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
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
                      const SizedBox(height: 8),
                      Text(
                        tank.pumpActive
                            ? 'La bomba está funcionando y llenando el tanque activamente.'
                            : 'La bomba está apagada. El nivel de agua se mantiene estable.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (tank.pumpActive) ...[
                        const SizedBox(height: 8),
                        Text(
                          '⚡ Consumo estimado: 2.5 kW/h',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Tank tank) {
    final location = tank.location;
    final address = location['address'] ?? 'No especificada';
    final lat = location['latitude']?.toString() ?? 'N/A';
    final lng = location['longitude']?.toString() ?? 'N/A';

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Dirección:', address, Icons.location_on),
            if (lat != 'N/A' && lng != 'N/A') ...[
              const Divider(),
              _buildStatRow('Coordenadas:', '$lat, $lng', Icons.gps_fixed),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQualityTab(detail_states.TankState detailState) {
    if (detailState is! detail_states.TankDetailLoaded) {
      return const Center(child: Text('Cargando datos de calidad...'));
    }

    // Simular datos de calidad de agua
    final mockQuality = {
      'ph': 7.2,
      'temperature': 22.5,
      'turbidity': 1.8,
      'conductivity': 350.0,
      'chlorine': 0.3,
      'oxygen': 7.5,
      'status': 'good',
      'timestamp': DateTime.now(),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado general de calidad
          _buildQualityOverview(mockQuality),
          const SizedBox(height: 24),

          // Parámetros individuales
          _buildQualityParameters(mockQuality),
          const SizedBox(height: 24),

          // Recomendaciones
          _buildQualityRecommendations(mockQuality),
        ],
      ),
    );
  }

  Widget _buildQualityOverview(Map<String, dynamic> quality) {
    final status = quality['status'] as String;
    Color statusColor = Colors.green;
    String statusText = 'Excelente';
    IconData statusIcon = Icons.check_circle;

    switch (status) {
      case 'poor':
        statusColor = Colors.red;
        statusText = 'Deficiente';
        statusIcon = Icons.error;
        break;
      case 'acceptable':
        statusColor = Colors.orange;
        statusText = 'Aceptable';
        statusIcon = Icons.warning;
        break;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(statusIcon, size: 60, color: statusColor),
            const SizedBox(height: 16),
            Text(
              'Calidad del Agua: $statusText',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última medición: ${DateFormat('dd/MM/yyyy HH:mm').format(quality['timestamp'])}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityParameters(Map<String, dynamic> quality) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parámetros de Calidad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQualityParam('pH', quality['ph'], '6.5 - 8.5', 'Acidez/Alcalinidad'),
            _buildQualityParam('Temperatura', quality['temperature'], '15 - 25°C', 'Temperatura del agua'),
            _buildQualityParam('Turbidez', quality['turbidity'], '< 4 NTU', 'Claridad del agua'),
            _buildQualityParam('Conductividad', quality['conductivity'], '100 - 800 µS/cm', 'Minerales disueltos'),
            _buildQualityParam('Cloro libre', quality['chlorine'], '0.2 - 0.5 mg/L', 'Desinfección'),
            _buildQualityParam('Oxígeno disuelto', quality['oxygen'], '> 6 mg/L', 'Nivel de oxigenación'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityParam(String name, dynamic value, String range, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Rango normal: $range',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildQualityRecommendations(Map<String, dynamic> quality) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Recomendaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendation('✓ Calidad del agua en niveles óptimos'),
            _buildRecommendation('• Realizar análisis completo cada 30 días'),
            _buildRecommendation('• Mantener limpieza regular del tanque'),
            _buildRecommendation('• Verificar filtros cada 15 días'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildHistoricalTab(detail_states.TankState detailState) {
    if (detailState is! detail_states.TankDetailLoaded) {
      return const Center(child: Text('Cargando datos históricos...'));
    }

    // Generar datos históricos mockeados
    final historicalData = _generateMockHistoricalData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico de Niveles (Últimos 7 días)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de niveles
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                            final index = value.toInt();
                            if (index >= 0 && index < days.length) {
                              return Text(days[index], style: const TextStyle(fontSize: 12));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: historicalData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Estadísticas del período
          _buildHistoricalStats(historicalData),
        ],
      ),
    );
  }

  List<FlSpot> _generateMockHistoricalData() {
    return [
      FlSpot(0, 45), // Lunes
      FlSpot(1, 52), // Martes
      FlSpot(2, 48), // Miércoles
      FlSpot(3, 65), // Jueves
      FlSpot(4, 72), // Viernes
      FlSpot(5, 68), // Sábado
      FlSpot(6, 75), // Domingo
    ];
  }

  Widget _buildHistoricalStats(List<FlSpot> data) {
    final levels = data.map((spot) => spot.y).toList();
    final maxLevel = levels.reduce((a, b) => a > b ? a : b);
    final minLevel = levels.reduce((a, b) => a < b ? a : b);
    final avgLevel = levels.reduce((a, b) => a + b) / levels.length;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas del Período',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Máximo', '${maxLevel.toStringAsFixed(1)}%', Colors.green),
                _buildStatColumn('Promedio', '${avgLevel.toStringAsFixed(1)}%', Colors.blue),
                _buildStatColumn('Mínimo', '${minLevel.toStringAsFixed(1)}%', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final tankMatches = state.tanks.where((t) => t.id == widget.tankId);
          if (tankMatches.isEmpty) return const SizedBox.shrink();
          final tank = tankMatches.first;

          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Información del estado actual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: tank.pumpActive ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tank.pumpActive ? 'Bomba funcionando' : 'Bomba detenida',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: tank.pumpActive
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón principal mejorado
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: tank.pumpActive
                              ? [
                            Colors.red.shade600,
                            Colors.red.shade700,
                          ]
                              : [
                            Colors.green.shade600,
                            Colors.green.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (tank.pumpActive ? Colors.red : Colors.green)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Haptic feedback para mejor UX
                            HapticFeedback.mediumImpact();
                            context.read<DashboardBloc>().add(TogglePump(tank: tank));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    tank.pumpActive
                                        ? Icons.stop_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    tank.pumpActive
                                        ? 'Detener Bomba'
                                        : 'Activar Bomba',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (tank.pumpActive)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ON',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Información adicional
                    if (tank.pumpActive) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Consumo estimado: 2.5 kW/h',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Métodos auxiliares
  Color _getPercentageColor(double percentage) {
    if (percentage < 20) return Colors.red.shade600;
    if (percentage < 50) return Colors.orange.shade600;
    if (percentage < 80) return Colors.blue.shade600;
    return Colors.green.shade600;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal': return Colors.green.shade600;
      case 'warning': return Colors.orange.shade600;
      case 'critical': return Colors.red.shade600;
      default: return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'normal': return 'Normal';
      case 'warning': return 'Atención';
      case 'critical': return 'Crítico';
      default: return 'Desconocido';
    }
  }
}