import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/entities/alert.dart';
import 'package:waterguard/presentation/blocs/alerts/alerts_bloc.dart';
import 'package:waterguard/presentation/blocs/alerts/alerts_event.dart';
import 'package:waterguard/presentation/blocs/alerts/alerts_state.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar las alertas activas por defecto
    context.read<AlertsBloc>().add(LoadAlerts(resolved: false));

    // Escuchar cambios en las pestañas
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }

      // Cargar alertas según la pestaña seleccionada
      if (_tabController.index == 0) {
        context.read<AlertsBloc>().add(LoadAlerts(resolved: false));
      } else {
        context.read<AlertsBloc>().add(LoadAlerts(resolved: true));
      }
    });
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
        title: const Text('Alertas y Notificaciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Resueltas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de alertas activas
          BlocBuilder<AlertsBloc, AlertsState>(
            builder: (context, state) {
              if (state is AlertsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AlertsLoaded) {
                return _buildAlertsList(context, state.alerts, false);
              } else if (state is AlertsError) {
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
                          context.read<AlertsBloc>().add(LoadAlerts(resolved: false));
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Cargando alertas...'));
            },
          ),

          // Pestaña de alertas resueltas
          BlocBuilder<AlertsBloc, AlertsState>(
            builder: (context, state) {
              if (state is AlertsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AlertsLoaded) {
                return _buildAlertsList(context, state.alerts, true);
              } else if (state is AlertsError) {
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
                          context.read<AlertsBloc>().add(LoadAlerts(resolved: true));
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Cargando alertas...'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, List<Alert> alerts, bool resolved) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              resolved ? Icons.check_circle : Icons.notifications_off,
              size: 64,
              color: resolved ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              resolved
                  ? 'No hay alertas resueltas'
                  : 'No hay alertas activas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AlertsBloc>().add(LoadAlerts(resolved: resolved));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return _buildAlertCard(context, alert, resolved);
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert, bool resolved) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // Mostrar detalles de la alerta en un diálogo
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(_getAlertTitle(alert.type)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.message),
                  const SizedBox(height: 16),
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Tanque ID: ${alert.tankId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (alert.pumpActivated) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Se activó la bomba automáticamente.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4.0),
                decoration: BoxDecoration(
                  color: _getAlertColor(alert.severity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAlertTitle(alert.type),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (!resolved)
                          TextButton(
                            onPressed: () {
                              // Mostrar diálogo de confirmación
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Marcar como Resuelta'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas marcar esta alerta como resuelta?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        context.read<AlertsBloc>().add(
                                          MarkAlertAsResolved(alertId: alert.id),
                                        );
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Marcar como Resuelta'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAlertTitle(String type) {
    switch (type) {
      case 'low_water_level':
        return 'Nivel Bajo de Agua';
      case 'quality_issue':
        return 'Problema de Calidad';
      case 'sensor_disconnected':
        return 'Sensor Desconectado';
      default:
        return 'Alerta';
    }
  }

  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}