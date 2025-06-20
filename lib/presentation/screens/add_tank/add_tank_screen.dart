// lib/presentation/screens/add_tank/add_tank_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
  final _criticalLevelController = TextEditingController(text: '20');
  final _optimalLevelController = TextEditingController(text: '80');
  final _addressController = TextEditingController();

  Position? _currentPosition;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<AddTankBloc>().add(ResetAddTankState());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _criticalLevelController.dispose();
    _optimalLevelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Permiso de ubicación denegado')));
          setState(() => _isFetchingLocation = false);
          return;
        }
      }
      _currentPosition = await Geolocator.getCurrentPosition();
      _addressController.text = 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(4)}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener la ubicación: $e')));
    } finally {
      setState(() => _isFetchingLocation = false);
    }
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
            // Actualizar dashboard y volver a la pantalla anterior
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
            Text('Ubicación', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Dirección o Coordenadas',
              icon: Icons.location_on,
              validator: (value) =>
              value!.isEmpty ? 'Ingresa la ubicación' : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isFetchingLocation ? null : _getCurrentLocation,
                icon: _isFetchingLocation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: const Text('Usar ubicación actual'),
              ),
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
      "nombre": _nameController.text,
      "capacidad": double.parse(_capacityController.text),
      "nivelCritico": double.parse(_criticalLevelController.text),
      "nivelOptimo": double.parse(_optimalLevelController.text),
      "ubicacion": {
        "latitud": _currentPosition?.latitude ?? 0.0,
        "longitud": _currentPosition?.longitude ?? 0.0,
        "direccion": _addressController.text,
      }
    };

    context.read<AddTankBloc>().add(CreateTank(tankData: tankData));
  }
}
