import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.primary,
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Center(
              child: Column(
                children: [
                  Text(
                    'Dra. Valeria Pérez',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Odontóloga especialista en ortodoncia',
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: AppColors.primary),
                title: const Text('Correo electrónico'),
                subtitle: const Text('dra.perez@checkdent.com'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primary),
                title: const Text('Teléfono'),
                subtitle: const Text('+51 987 654 321'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.primary),
                title: const Text('Ubicación'),
                subtitle: const Text('Lima, Perú'),
              ),
            ),

            const SizedBox(height: 25),
            const Divider(),

            PrimaryButton(
              text: 'Editar Perfil',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función próximamente disponible.')),
                );
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              text: 'Cerrar Sesión',
              filled: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada correctamente.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
