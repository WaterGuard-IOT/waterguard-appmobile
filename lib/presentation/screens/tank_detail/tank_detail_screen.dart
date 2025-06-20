// lib/presentation/screens/tank_detail/tank_detail_screen.dart
import 'package:flutter/material.dart';
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
        content: const Text('¿Estás seguro de que quieres eliminar este tanque? Esta acción no se puede deshacer.'),
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
          tabs: const [ Tab(text: 'General'), Tab(text: 'Calidad'), Tab(text: 'Histórico'), ],
        ),
      ),
      body: BlocListener<TankBloc, detail_states.TankState>(
        listener: (context, state) {
          if (state is detail_states.TankError) {
            ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(state.message), backgroundColor: Colors.red, ), );
          }
          if (state is detail_states.TankDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Tanque eliminado con éxito'), backgroundColor: Colors.green, ), );
            context.read<DashboardBloc>().add(RefreshDashboard());
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<TankBloc, detail_states.TankState>(
          builder: (detailContext, detailState) {
            if (detailState is detail_states.TankLoading) return const Center(child: CircularProgressIndicator());
            if (detailState is detail_states.TankError) return Center(child: Text(detailState.message));
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( tank.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith( fontWeight: FontWeight.bold, ), ),
                      const SizedBox(height: 8),
                      Text( 'Ubicación: ${tank.location['address'] ?? 'No especificada'}', style: Theme.of(context).textTheme.bodyMedium, ),
                      const SizedBox(height: 8),
                      Text( 'Última actualización: ${DateFormat('dd/MM/yyyy HH:mm').format(tank.lastUpdated)}', style: Theme.of(context).textTheme.bodySmall, ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text( 'Nivel de Agua', style: Theme.of(context).textTheme.titleMedium?.copyWith( fontWeight: FontWeight.bold, ), ),
              const SizedBox(height: 16),
              Center(
                child: ModernWaterTankIndicator(
                  percentageFilled: levelPercentage,
                  height: 220,
                  width: 120,
                  isFillingActive: tank.pumpActive,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow( context, 'Capacidad total:', '${tank.capacity.toStringAsFixed(0)} L', ),
                      const Divider(),
                      _buildDetailRow( context, 'Nivel actual:', '${tank.currentLevel.toStringAsFixed(0)} L (${levelPercentage.toStringAsFixed(1)}%)', ),
                      const Divider(),
                      _buildDetailRow( context, 'Nivel crítico:', '${tank.criticalLevel.toStringAsFixed(0)}% (${criticalLevelInLiters.toStringAsFixed(0)} L)', ),
                      const Divider(),
                      _buildDetailRow( context, 'Nivel óptimo:', '${tank.optimalLevel.toStringAsFixed(0)}% (${optimalLevelInLiters.toStringAsFixed(0)} L)', ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text( 'Estado de la Bomba', style: Theme.of(context).textTheme.titleMedium?.copyWith( fontWeight: FontWeight.bold, ), ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration( color: tank.pumpActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2), shape: BoxShape.circle, ),
                        child: Icon( tank.pumpActive ? Icons.power : Icons.power_off, color: tank.pumpActive ? Colors.green : Colors.grey, size: 32, ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( tank.pumpActive ? 'Bomba Activa' : 'Bomba Inactiva', style: Theme.of(context).textTheme.titleMedium?.copyWith( fontWeight: FontWeight.bold, color: tank.pumpActive ? Colors.green : Colors.grey, ), ),
                            const SizedBox(height: 4),
                            Text( tank.pumpActive ? 'Llenando el tanque...' : 'La bomba está apagada.', style: Theme.of(context).textTheme.bodyMedium, ),
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
      },
    );
  }

  Widget _buildQualityTab(detail_states.TankState detailState) {
    if (detailState is! detail_states.TankDetailLoaded || detailState.waterQuality == null) {
      return const Center(child: Text('No hay datos de calidad disponibles.'));
    }
    return Container();
  }

  Widget _buildHistoricalTab(detail_states.TankState detailState) {
    if (detailState is! detail_states.TankDetailLoaded || detailState.historicalData.isEmpty) {
      return const Center(child: Text('No hay datos históricos disponibles.'));
    }
    return Container();
  }

  Widget _buildBottomActions() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final tankMatches = state.tanks.where((t) => t.id == widget.tankId);
          if (tankMatches.isEmpty) return const SizedBox.shrink();
          final tank = tankMatches.first;

          return BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<DashboardBloc>().add(TogglePump(tank: tank));
                      },
                      icon: Icon(tank.pumpActive ? Icons.stop_circle_outlined : Icons.play_circle_fill),
                      label: Text(tank.pumpActive ? 'Detener Bomba' : 'Activar Bomba'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tank.pumpActive ? Colors.red : Colors.green,
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
