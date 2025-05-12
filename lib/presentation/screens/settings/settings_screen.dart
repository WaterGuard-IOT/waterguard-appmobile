// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/entities/user_settings.dart';
import 'package:waterguard/presentation/blocs/settings/settings_bloc.dart';
import 'package:waterguard/presentation/blocs/settings/settings_event.dart';
import 'package:waterguard/presentation/blocs/settings/settings_state.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controladores para valores de pH
  late TextEditingController _minPhController;
  late TextEditingController _maxPhController;

  // Controladores para valores de temperatura
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;

  // Controladores para niveles de agua
  late TextEditingController _criticalLevelController;
  late TextEditingController _optimalLevelController;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _minPhController = TextEditingController();
    _maxPhController = TextEditingController();
    _minTempController = TextEditingController();
    _maxTempController = TextEditingController();
    _criticalLevelController = TextEditingController();
    _optimalLevelController = TextEditingController();

    // Cargar configuraciones
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SettingsBloc>().add(LoadSettings());
    }
  }

  @override
  void dispose() {
    _minPhController.dispose();
    _maxPhController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _criticalLevelController.dispose();
    _optimalLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            // Actualizar controladores cuando se cargan las configuraciones
            _updateControllers(state.settings);
          } else if (state is SettingsError) {
            // Mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return _buildSettingsForm(context, state.settings);
          } else if (state is SettingsError) {
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
                      context.read<SettingsBloc>().add(LoadSettings());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Cargando configuraciones...'));
        },
      ),
    );
  }

  void _updateControllers(UserSettings settings) {
    _minPhController.text = settings.defaultMinPh.toString();
    _maxPhController.text = settings.defaultMaxPh.toString();
    _minTempController.text = settings.defaultMinTemperature.toString();
    _maxTempController.text = settings.defaultMaxTemperature.toString();
    _criticalLevelController.text = settings.defaultCriticalLevelPercentage.toString();
    _optimalLevelController.text = settings.defaultOptimalLevelPercentage.toString();
  }

  Widget _buildSettingsForm(BuildContext context, UserSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección pH
          _buildSectionTitle(context, 'Configuración de pH'),
          _buildInfoCard(
            'El pH mide la acidez del agua. Un pH neutro (7.0) es ideal para muchos usos.',
            'Valores típicamente aceptables: 6.5 - 8.5',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minPhController,
                  label: 'pH mínimo',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxPhController,
                  label: 'pH máximo',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de pH',
            onPressed: () {
              final minPh = double.tryParse(_minPhController.text) ?? settings.defaultMinPh;
              final maxPh = double.tryParse(_maxPhController.text) ?? settings.defaultMaxPh;

              context.read<SettingsBloc>().add(
                UpdatePhThresholds(minPh: minPh, maxPh: maxPh),
              );
            },
          ),

          const Divider(height: 32),

          // Sección Temperatura
          _buildSectionTitle(context, 'Configuración de Temperatura'),
          _buildInfoCard(
            'La temperatura del agua afecta su calidad. Temperaturas extremas pueden afectar la eficiencia de sistemas y tuberías.',
            'Valores típicamente aceptables: 15°C - 25°C',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minTempController,
                  label: 'Temperatura mínima (°C)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxTempController,
                  label: 'Temperatura máxima (°C)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de Temperatura',
            onPressed: () {
              final minTemp = double.tryParse(_minTempController.text) ?? settings.defaultMinTemperature;
              final maxTemp = double.tryParse(_maxTempController.text) ?? settings.defaultMaxTemperature;

              context.read<SettingsBloc>().add(
                UpdateTemperatureThresholds(
                  minTemperature: minTemp,
                  maxTemperature: maxTemp,
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Sección Niveles de Agua
          _buildSectionTitle(context, 'Configuración de Niveles de Agua'),
          _buildInfoCard(
            'Establezca umbrales para determinar cuándo un tanque necesita ser llenado o cuándo está en nivel óptimo.',
            'Los valores son porcentajes respecto a la capacidad total del tanque.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _criticalLevelController,
                  label: 'Nivel crítico (%)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _optimalLevelController,
                  label: 'Nivel óptimo (%)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de Nivel',
            onPressed: () {
              final criticalLevel = double.tryParse(_criticalLevelController.text) ??
                  settings.defaultCriticalLevelPercentage;
              final optimalLevel = double.tryParse(_optimalLevelController.text) ??
                  settings.defaultOptimalLevelPercentage;

              context.read<SettingsBloc>().add(
                UpdateWaterLevelThresholds(
                  criticalPercentage: criticalLevel,
                  optimalPercentage: optimalLevel,
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Botón para restaurar valores por defecto
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Mostrar diálogo de confirmación
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Restaurar Valores por Defecto'),
                    content: const Text(
                        '¿Estás seguro de que deseas restaurar todos los valores a la configuración por defecto?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          // Implementar restauración de valores por defecto
                        },
                        child: const Text('Restaurar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar Valores por Defecto'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String mainText, String additionalInfo) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mainText,
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
            if (additionalInfo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                additionalInfo,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildUpdateButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}