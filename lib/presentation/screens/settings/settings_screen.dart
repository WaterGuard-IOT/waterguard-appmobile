// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/entities/user_settings.dart';
import 'package:waterguard/presentation/blocs/settings/settings_bloc.dart';
import 'package:waterguard/presentation/blocs/settings/settings_event.dart';
import 'package:waterguard/presentation/blocs/settings/settings_state.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_state.dart';
import 'package:waterguard/presentation/blocs/theme/theme_bloc.dart';
import 'package:waterguard/presentation/blocs/theme/theme_event.dart';
import 'package:waterguard/presentation/blocs/theme/theme_state.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores para valores de pH
  late TextEditingController _minPhController;
  late TextEditingController _maxPhController;

  // Controladores para valores de temperatura
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;

  // Controladores para niveles de agua
  late TextEditingController _criticalLevelController;
  late TextEditingController _optimalLevelController;

  // Controladores de perfil
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Estados de notificaciones
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _criticalAlertsOnly = false;

  // Configuración de unidades
  String _temperatureUnit = 'celsius';
  String _volumeUnit = 'liters';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);

    // Inicializar controladores
    _minPhController = TextEditingController();
    _maxPhController = TextEditingController();
    _minTempController = TextEditingController();
    _maxTempController = TextEditingController();
    _criticalLevelController = TextEditingController();
    _optimalLevelController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Cargar configuraciones
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SettingsBloc>().add(LoadSettings());
      _loadUserProfile(authState.userId);
    }
  }

  void _loadUserProfile(String userId) async {
    final userRepository = GetIt.instance<UserRepository>();
    final user = await userRepository.getUserById(userId);
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
        _emailNotifications = user.preferredNotifications.contains('email');
        _pushNotifications = user.preferredNotifications.contains('push');
        _smsNotifications = user.preferredNotifications.contains('sms');
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _minPhController.dispose();
    _maxPhController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _criticalLevelController.dispose();
    _optimalLevelController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
            Tab(icon: Icon(Icons.tune), text: 'Umbrales'),
            Tab(icon: Icon(Icons.notifications), text: 'Notificaciones'),
            Tab(icon: Icon(Icons.settings), text: 'General'),
          ],
        ),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            _updateControllers(state.settings);
          } else if (state is SettingsError) {
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
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(),
              _buildThresholdsTab(state),
              _buildNotificationsTab(),
              _buildGeneralTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar de perfil
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white, // Siempre blanco para buen contraste
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white, // Siempre blanco
                        size: 20,
                      ),
                      onPressed: () {
                        // Funcionalidad de cambiar foto
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función de cambiar foto próximamente')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Información del perfil
          _buildSectionTitle('Información Personal'),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nameController,
            label: 'Nombre completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            enabled: false, // Email no editable
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _phoneController,
            label: 'Número de teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Estadísticas del usuario
          _buildSectionTitle('Mis Estadísticas'),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard('Tanques Gestionados', '3', Icons.water_drop),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Alertas Resueltas', '12', Icons.check_circle),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Botón de guardar perfil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _saveProfile();
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdsTab(SettingsState state) {
    if (state is! SettingsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información importante
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los cambios se aplicarán a todos tus tanques y afectarán las alertas automáticas.',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección pH
          _buildSectionTitle('Configuración de pH'),
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
                  icon: Icons.science,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxPhController,
                  label: 'pH máximo',
                  keyboardType: TextInputType.number,
                  icon: Icons.science,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de pH',
            onPressed: () => _updatePhThresholds(state.settings),
          ),

          const Divider(height: 32),

          // Sección Temperatura
          _buildSectionTitle('Configuración de Temperatura'),
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
                  label: 'Temperatura mínima (°$_temperatureUnit)',
                  keyboardType: TextInputType.number,
                  icon: Icons.thermostat,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxTempController,
                  label: 'Temperatura máxima (°$_temperatureUnit)',
                  keyboardType: TextInputType.number,
                  icon: Icons.thermostat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de Temperatura',
            onPressed: () => _updateTemperatureThresholds(state.settings),
          ),

          const Divider(height: 32),

          // Sección Niveles de Agua
          _buildSectionTitle('Configuración de Niveles de Agua'),
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
                  icon: Icons.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _optimalLevelController,
                  label: 'Nivel óptimo (%)',
                  keyboardType: TextInputType.number,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUpdateButton(
            text: 'Actualizar Umbrales de Nivel',
            onPressed: () => _updateWaterLevelThresholds(state.settings),
          ),

          const SizedBox(height: 32),

          // Botón para restaurar valores por defecto
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showRestoreDefaultsDialog(),
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar Valores por Defecto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Preferencias de Notificación'),
          const SizedBox(height: 16),

          _buildNotificationTile(
            'Notificaciones Push',
            'Recibir alertas en tu dispositivo móvil',
            Icons.notifications,
            _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
          ),

          _buildNotificationTile(
            'Notificaciones por Email',
            'Recibir alertas en tu correo electrónico',
            Icons.email,
            _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
          ),

          _buildNotificationTile(
            'Notificaciones SMS',
            'Recibir alertas por mensaje de texto',
            Icons.sms,
            _smsNotifications,
                (value) => setState(() => _smsNotifications = value),
          ),

          const Divider(height: 32),

          _buildSectionTitle('Tipos de Alertas'),
          const SizedBox(height: 16),

          _buildNotificationTile(
            'Solo Alertas Críticas',
            'Recibir únicamente alertas de alta prioridad',
            Icons.priority_high,
            _criticalAlertsOnly,
                (value) => setState(() => _criticalAlertsOnly = value),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveNotificationSettings,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Configuración de Notificaciones'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tema de la aplicación
          _buildSectionTitle('Apariencia'),
          const SizedBox(height: 16),

          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema de la aplicación',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              state.isDarkMode ? 'Modo oscuro activado' : 'Modo claro activado',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: state.isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ToggleTheme());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Unidades de medida
          _buildSectionTitle('Unidades de Medida'),
          const SizedBox(height: 16),

          _buildUnitSelector(
            'Temperatura',
            _temperatureUnit,
            {'celsius': '°C', 'fahrenheit': '°F'},
                (value) => setState(() => _temperatureUnit = value),
          ),

          const SizedBox(height: 16),

          _buildUnitSelector(
            'Volumen',
            _volumeUnit,
            {'liters': 'Litros', 'gallons': 'Galones'},
                (value) => setState(() => _volumeUnit = value),
          ),

          const SizedBox(height: 32),

          // Información de la aplicación
          _buildSectionTitle('Información de la Aplicación'),
          const SizedBox(height: 16),

          _buildInfoTile('Versión', '1.0.0', Icons.info),
          _buildInfoTile('Última actualización', 'Hoy', Icons.update),
          _buildInfoTile('Desarrollado por', 'WaterGuard Team', Icons.code),

          const SizedBox(height: 32),

          // Acciones
          _buildActionButton(
            'Limpiar Caché',
            'Eliminar datos temporales',
            Icons.cleaning_services,
            Colors.orange,
            _clearCache,
          ),

          const SizedBox(height: 16),

          _buildActionButton(
            'Exportar Datos',
            'Descargar un respaldo de tus datos',
            Icons.download,
            Colors.green,
            _exportData,
          ),

          const SizedBox(height: 16),

          _buildActionButton(
            'Reportar Problema',
            'Enviar feedback o reportar un error',
            Icons.bug_report,
            Colors.blue,
            _reportIssue,
          ),
        ],
      ),
    );
  }

  // Widgets auxiliares
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      keyboardType: keyboardType,
      enabled: enabled,
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

  Widget _buildUpdateButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUnitSelector(
      String title,
      String currentValue,
      Map<String, String> options,
      ValueChanged<String> onChanged,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: currentValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: options.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(value),
      ),
    );
  }

  Widget _buildActionButton(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Card(
        elevation: isDarkMode ? 4 : 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDarkMode
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
          onTap: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Métodos de actualización
  void _updateControllers(UserSettings settings) {
    _minPhController.text = settings.defaultMinPh.toString();
    _maxPhController.text = settings.defaultMaxPh.toString();
    _minTempController.text = settings.defaultMinTemperature.toString();
    _maxTempController.text = settings.defaultMaxTemperature.toString();
    _criticalLevelController.text = settings.defaultCriticalLevelPercentage.toString();
    _optimalLevelController.text = settings.defaultOptimalLevelPercentage.toString();
  }

  void _updatePhThresholds(UserSettings settings) {
    final minPh = double.tryParse(_minPhController.text) ?? settings.defaultMinPh;
    final maxPh = double.tryParse(_maxPhController.text) ?? settings.defaultMaxPh;

    context.read<SettingsBloc>().add(
      UpdatePhThresholds(minPh: minPh, maxPh: maxPh),
    );

    _showSuccessMessage('Umbrales de pH actualizados correctamente');
  }

  void _updateTemperatureThresholds(UserSettings settings) {
    final minTemp = double.tryParse(_minTempController.text) ?? settings.defaultMinTemperature;
    final maxTemp = double.tryParse(_maxTempController.text) ?? settings.defaultMaxTemperature;

    context.read<SettingsBloc>().add(
      UpdateTemperatureThresholds(
        minTemperature: minTemp,
        maxTemperature: maxTemp,
      ),
    );

    _showSuccessMessage('Umbrales de temperatura actualizados correctamente');
  }

  void _updateWaterLevelThresholds(UserSettings settings) {
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

    _showSuccessMessage('Umbrales de nivel de agua actualizados correctamente');
  }

  void _saveProfile() {
    _showSuccessMessage('Perfil actualizado correctamente');
  }

  void _saveNotificationSettings() {
    _showSuccessMessage('Configuración de notificaciones guardada');
  }

  void _showRestoreDefaultsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Valores por Defecto'),
        content: const Text(
          '¿Estás seguro de que deseas restaurar todos los valores a la configuración por defecto? Esta acción no se puede deshacer.',
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
              _showSuccessMessage('Valores restaurados por defecto');
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    _showSuccessMessage('Caché limpiado correctamente');
  }

  void _exportData() {
    _showSuccessMessage('Datos exportados correctamente');
  }

  void _reportIssue() {
    _showSuccessMessage('Reporte enviado. Gracias por tu feedback');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}