// lib/presentation/screens/edit_tank/edit_tank_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/presentation/blocs/auth/auth_bloc.dart';
import 'package:waterguard/presentation/blocs/auth/auth_state.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:waterguard/presentation/blocs/dashboard/dashboard_event.dart';
import 'package:waterguard/presentation/blocs/tank/tank_bloc.dart';
import 'package:waterguard/presentation/blocs/tank/tank_event.dart';
import 'package:waterguard/presentation/blocs/tank/tank_state.dart';

class EditTankScreen extends StatefulWidget {
  final Tank tank;

  const EditTankScreen({Key? key, required this.tank}) : super(key: key);

  @override
  State<EditTankScreen> createState() => _EditTankScreenState();
}

class _EditTankScreenState extends State<EditTankScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _criticalLevelController;
  late TextEditingController _optimalLevelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tank.name);
    _capacityController = TextEditingController(text: widget.tank.capacity.toStringAsFixed(0));
    // --- CORRECCIÓN: Usar los valores de nivel directamente (asumiendo que son porcentajes) ---
    _criticalLevelController = TextEditingController(text: widget.tank.criticalLevel.toStringAsFixed(0));
    _optimalLevelController = TextEditingController(text: widget.tank.optimalLevel.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _criticalLevelController.dispose();
    _optimalLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tanque'),
      ),
      body: BlocListener<TankBloc, TankState>(
        listener: (context, state) {
          if (state is TankUpdateSuccess) {
            context.read<DashboardBloc>().add(RefreshDashboard());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanque actualizado con éxito'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is TankError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<TankBloc, TankState>(
          builder: (context, state) {
            if (state is TankLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildForm();
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Nombre del Tanque',
              icon: Icons.label,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _capacityController,
              label: 'Capacidad Total (Litros)',
              icon: Icons.water,
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
    );
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado.'))
      );
      return;
    }

    final updatedData = {
      "name": _nameController.text,
      "capacity": double.parse(_capacityController.text),
      "criticalLevel": double.parse(_criticalLevelController.text),
      "optimalLevel": double.parse(_optimalLevelController.text),
      "pumpActive": widget.tank.pumpActive,
      "status": widget.tank.status,
      "location": widget.tank.location,
      "userId": int.parse(authState.userId),
    };

    context.read<TankBloc>().add(
      UpdateTank(
        tankId: int.parse(widget.tank.id),
        tankData: updatedData,
      ),
    );
  }
}
