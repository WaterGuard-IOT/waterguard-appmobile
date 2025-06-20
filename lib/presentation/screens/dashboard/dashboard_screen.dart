import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/entities/alert.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_event.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_event.dart';
import 'package:waterguard/app/routes/app_router.dart';
import 'package:intl/intl.dart';

import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterGuard'),
        actions: [
          // Botón para cambiar el tema
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white,
                ),
                tooltip: state.isDarkMode ? 'Modo claro' : 'Modo oscuro',
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return _buildDashboard(context, state);
          } else if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(RefreshDashboard());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Cargando...'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.addTank);
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Tanque'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Dashboard seleccionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Ya estamos en el dashboard
            return;
          } else if (index == 1) {
            // Navegar a la pantalla de alertas
            Navigator.of(context).pushNamed(AppRouter.alerts);
          } else if (index == 2) {
            // Navegar a la pantalla de configuración
            Navigator.of(context).pushNamed(AppRouter.settings);
          }
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboard());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de alertas activas
            if (state.activeAlerts.isNotEmpty)
              _buildAlertsCard(context, state.activeAlerts),

            const SizedBox(height: 16),

            // Título de la sección de tanques con botón de agregar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Tanques',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (state.tanks.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.addTank);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de tanques o mensaje cuando no hay tanques
            if (state.tanks.isEmpty)
              _buildEmptyTanksState(context)
            else
              ...state.tanks.map((tank) => _buildTankCard(context, tank)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTanksState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_outlined,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay tanques registrados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza agregando tu primer tanque de agua para monitorear sus niveles en tiempo real.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.addTank);
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Mi Primer Tanque'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsCard(BuildContext context, List<Alert> alerts) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas Activas (${alerts.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alerts.take(3).map((alert) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getAlertColor(alert.severity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (alerts.length > 3) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.alerts);
                },
                child: Text(
                  'Ver todas las alertas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTankCard(BuildContext context, Tank tank) {
    final levelPercentage = tank.levelPercentage;
    final statusColor = _getStatusColor(tank.status);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: isDarkMode ? 8 : 4,
      shadowColor: isDarkMode
          ? Colors.black.withOpacity(0.5)
          : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isDarkMode
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade800,
              Colors.grey.shade900,
            ],
          )
              : null,
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.tankDetail,
              arguments: tank.id,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tank.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(tank.status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nivel de Agua',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${tank.currentLevel.toStringAsFixed(0)} L de ${tank.capacity.toStringAsFixed(0)} L',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: levelPercentage / 100,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getWaterLevelColor(levelPercentage),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${levelPercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _getWaterLevelColor(levelPercentage),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bomba',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tank.pumpActive
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tank.pumpActive
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tank.pumpActive
                                      ? Icons.power
                                      : Icons.power_off,
                                  color: tank.pumpActive
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tank.pumpActive ? 'Activa' : 'Inactiva',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: tank.pumpActive
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Última act:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM HH:mm').format(tank.lastUpdated),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return const Color(0xFF4CAF50);
      case 'warning':
        return const Color(0xFFFF9800);
      case 'critical':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'normal':
        return 'Normal';
      case 'warning':
        return 'Atención';
      case 'critical':
        return 'Crítico';
      default:
        return 'Desconocido';
    }
  }

  Color _getWaterLevelColor(double percentage) {
    if (percentage < 20) {
      return const Color(0xFFF44336);
    } else if (percentage < 50) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFF2196F3);
    }
  }

  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.lightBlueAccent;
      default:
        return Colors.grey;
    }
  }
}