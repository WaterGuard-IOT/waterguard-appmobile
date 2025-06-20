// lib/presentation/screens/add_tank/add_tank_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_bloc.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_event.dart';
import 'package:waterguard/presentation/blocs/add_tank/add_tank_state.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_state.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_event.dart';

class AddTankScreen extends StatefulWidget {
  const AddTankScreen({Key? key}) : super(key: key);

  @override
  State<AddTankScreen> createState() => _AddTankScreenState();
}

class _AddTankScreenState extends State<AddTankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController(text: '1000');
  // --- NUEVA FUNCIONALIDAD: Controlador para nivel actual ---
  final _currentLevelController = TextEditingController(text: '0');
  final _criticalLevelController = TextEditingController(text: '20');
  final _optimalLevelController = TextEditingController(text: '80');

  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AddTankBloc>().add(ResetAddTankState());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _currentLevelController.dispose();
    _criticalLevelController.dispose();
    _optimalLevelController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Tanque'),
      ),
      body: BlocConsumer<AddTankBloc, AddTankState>(
        listener: (context, state) {
          if (state is AddTankSuccess) {
            context.read<DashboardBloc>().add(RefreshDashboard());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Tanque creado exitosamente!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AddTankError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AddTankLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creando tanque...'),
                ],
              ),
            );
          }
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Información del Tanque', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Nombre del Tanque',
              icon: Icons.label,
              validator: (value) =>
              value!.isEmpty ? 'Por favor ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _capacityController,
              label: 'Capacidad Total (Litros)',
              icon: Icons.water,
              keyboardType: TextInputType.number,
              validator: (value) =>
              value!.isEmpty ? 'Ingresa la capacidad' : null,
            ),
            const SizedBox(height: 16),
            // --- NUEVA FUNCIONALIDAD: Campo para nivel de agua actual ---
            _buildTextField(
              controller: _currentLevelController,
              label: 'Nivel Actual (Litros)',
              icon: Icons.waves,
              keyboardType: TextInputType.number,
              validator: (value) =>
              value!.isEmpty ? 'Ingresa el nivel actual' : null,
            ),
            const SizedBox(height: 24),
            Text('Niveles de Alerta (%)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _criticalLevelController,
                    label: 'Nivel Crítico (%)',
                    icon: Icons.warning_amber,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _optimalLevelController,
                    label: 'Nivel Óptimo (%)',
                    icon: Icons.check_circle_outline,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Ubicación Manual', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Dirección (Ej: Av. Principal 123)',
              icon: Icons.location_city,
              validator: (value) =>
              value!.isEmpty ? 'Ingresa la dirección' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _latitudeController,
                    label: 'Latitud',
                    icon: Icons.map,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa la latitud';
                      if (double.tryParse(value) == null) return 'Número inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _longitudeController,
                    label: 'Longitud',
                    icon: Icons.map,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa la longitud';
                      if (double.tryParse(value) == null) return 'Número inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createTank,
              icon: const Icon(Icons.add_circle),
              label: const Text('Crear Tanque'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  void _createTank() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No estás autenticado.')),
      );
      return;
    }

    final tankData = {
      "userId": int.parse(authState.userId),
      "name": _nameController.text,
      "capacity": double.parse(_capacityController.text),
      "currentLevel": double.parse(_currentLevelController.text), // Enviar el nivel actual
      "criticalLevel": double.parse(_criticalLevelController.text),
      "optimalLevel": double.parse(_optimalLevelController.text),
      "pumpActive": false,
      "status": "normal",
      "location": {
        "latitude": double.tryParse(_latitudeController.text) ?? 0.0,
        "longitude": double.tryParse(_longitudeController.text) ?? 0.0,
        "address": _addressController.text,
      }
    };

    context.read<AddTankBloc>().add(CreateTank(tankData: tankData));
  }
}
