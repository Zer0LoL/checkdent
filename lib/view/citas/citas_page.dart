import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';

class CitasPage extends StatelessWidget {
  const CitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            SizedBox(height: 8),
            CitaCard(
              titulo: 'Ortodoncia - Juan Pérez',
              fecha: 'Martes 22 de Octubre',
              hora: '10:00 AM',
            ),
            CitaCard(
              titulo: 'Limpieza Dental - María López',
              fecha: 'Miércoles 23 de Octubre',
              hora: '4:30 PM',
            ),
            CitaCard(
              titulo: 'Extracción - Pedro Gómez',
              fecha: 'Viernes 25 de Octubre',
              hora: '11:15 AM',
            ),
            CitaCard(
              titulo: 'Blanqueamiento - Sofía Rojas',
              fecha: 'Sábado 26 de Octubre',
              hora: '9:00 AM',
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/nueva_cita');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Agendar Cita'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
