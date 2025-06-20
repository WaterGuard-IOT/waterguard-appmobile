// lib/presentation/screens/alerts/alerts_screen.dart - MEJORADO
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
            Tab(
              icon: Icon(Icons.notifications_active),
              text: 'Activas',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Resueltas',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final resolved = _tabController.index == 1;
              context.read<AlertsBloc>().add(LoadAlerts(resolved: resolved));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de alertas activas
          BlocBuilder<AlertsBloc, AlertsState>(
            builder: (context, state) {
              return _buildAlertsContent(context, state, false);
            },
          ),

          // Pestaña de alertas resueltas
          BlocBuilder<AlertsBloc, AlertsState>(
            builder: (context, state) {
              return _buildAlertsContent(context, state, true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsContent(BuildContext context, AlertsState state, bool resolved) {
    if (state is AlertsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando alertas...'),
          ],
        ),
      );
    } else if (state is AlertsLoaded) {
      return _buildAlertsList(context, state.alerts, resolved);
    } else if (state is AlertsError) {
      return _buildErrorState(context, state.message, resolved);
    }

    return const Center(child: Text('Cargando alertas...'));
  }

  Widget _buildErrorState(BuildContext context, String message, bool resolved) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar alertas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AlertsBloc>().add(LoadAlerts(resolved: resolved));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, List<Alert> alerts, bool resolved) {
    // Filtrar y ordenar alertas
    final filteredAlerts = alerts.where((alert) => alert.resolved == resolved).toList();

    // Ordenar por timestamp (más recientes primero)
    filteredAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (filteredAlerts.isEmpty) {
      return _buildEmptyState(context, resolved);
    }

    // Agrupar alertas por fecha
    final groupedAlerts = _groupAlertsByDate(filteredAlerts);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AlertsBloc>().add(LoadAlerts(resolved: resolved));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: groupedAlerts.length,
        itemBuilder: (context, index) {
          final group = groupedAlerts[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(group['date']),
              ...group['alerts'].map<Widget>((alert) => _buildAlertCard(context, alert, resolved)),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool resolved) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: resolved
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                resolved ? Icons.check_circle_outline : Icons.notifications_off_outlined,
                size: 60,
                color: resolved ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              resolved
                  ? 'No hay alertas resueltas'
                  : 'No hay alertas activas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: resolved ? Colors.green : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resolved
                  ? 'Las alertas resueltas aparecerán aquí'
                  : '¡Excelente! Todos tus tanques están funcionando correctamente',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!resolved) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Ver Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupAlertsByDate(List<Alert> alerts) {
    final Map<String, List<Alert>> grouped = {};

    for (final alert in alerts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(alert.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(alert);
    }

    return grouped.entries.map((entry) => {
      'date': DateTime.parse(entry.key),
      'alerts': entry.value,
    }).toList();
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(now);
    final isYesterday = DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Hoy';
    } else if (isYesterday) {
      dateText = 'Ayer';
    } else {
      // Usar formato simple sin locale específico
      dateText = DateFormat('EEEE, dd MMM').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert, bool resolved) {
    final alertInfo = _getAlertInfo(alert.type);
    final severityInfo = _getSeverityInfo(alert.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityInfo['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showAlertDetails(context, alert),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del alert
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: severityInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      alertInfo['icon'],
                      color: severityInfo['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alertInfo['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: severityInfo['color'].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                severityInfo['label'],
                                style: TextStyle(
                                  color: severityInfo['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tanque ${alert.tankId}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (alert.pumpActivated)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.power,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Mensaje del alert
              Text(
                alert.message,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer con tiempo y acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(alert.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (!resolved && !alert.resolved)
                    TextButton(
                      onPressed: () => _showResolveDialog(context, alert),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        'Resolver',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getAlertInfo(String type) {
    switch (type) {
      case 'low_water_level':
        return {
          'title': 'Nivel Bajo de Agua',
          'icon': Icons.water_drop_outlined,
        };
      case 'quality_issue':
        return {
          'title': 'Problema de Calidad',
          'icon': Icons.science_outlined,
        };
      case 'sensor_disconnected':
        return {
          'title': 'Sensor Desconectado',
          'icon': Icons.sensors_off_outlined,
        };
      case 'pump_malfunction':
        return {
          'title': 'Fallo de Bomba',
          'icon': Icons.power_off_outlined,
        };
      case 'high_temperature':
        return {
          'title': 'Temperatura Alta',
          'icon': Icons.thermostat_outlined,
        };
      case 'ph_critical':
        return {
          'title': 'pH Crítico',
          'icon': Icons.science_outlined,
        };
      default:
        return {
          'title': 'Alerta del Sistema',
          'icon': Icons.notification_important_outlined,
        };
    }
  }

  Map<String, dynamic> _getSeverityInfo(String severity) {
    switch (severity) {
      case 'error':
        return {
          'label': 'Crítico',
          'color': Colors.red.shade600,
        };
      case 'warning':
        return {
          'label': 'Advertencia',
          'color': Colors.orange.shade600,
        };
      case 'info':
        return {
          'label': 'Información',
          'color': Colors.blue.shade600,
        };
      default:
        return {
          'label': 'Desconocido',
          'color': Colors.grey.shade600,
        };
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return DateFormat('dd/MM HH:mm').format(timestamp);
    }
  }

  void _showAlertDetails(BuildContext context, Alert alert) {
    final alertInfo = _getAlertInfo(alert.type);
    final severityInfo = _getSeverityInfo(alert.severity);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: severityInfo['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                alertInfo['icon'],
                color: severityInfo['color'],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alertInfo['title'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: severityInfo['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: severityInfo['color'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                severityInfo['label'],
                style: TextStyle(
                  color: severityInfo['color'],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              alert.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(ctx, 'Tanque:', 'Tanque ${alert.tankId}'),
            _buildDetailRow(ctx, 'Fecha:', DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp)),
            _buildDetailRow(ctx, 'Estado:', alert.resolved ? 'Resuelto' : 'Activo'),
            if (alert.pumpActivated) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.power, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Se activó la bomba automáticamente',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
          if (!alert.resolved)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _showResolveDialog(context, alert);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Resolver'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(BuildContext context, Alert alert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Resolver Alerta'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas marcar esta alerta como resuelta?\n\nEsto indica que el problema ha sido solucionado.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AlertsBloc>().add(
                MarkAlertAsResolved(alertId: alert.id),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alerta marcada como resuelta'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }
}