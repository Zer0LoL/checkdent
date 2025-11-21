import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/session_manager.dart';
import '../login/login_page.dart'; // Asegúrate de importar tu Login

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  void _cerrarSesion(BuildContext context) {
    // 1. Limpiamos la memoria
    SessionManager().logout();

    // 2. Navegamos al Login eliminando todo el historial de navegación
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // LEEMOS LOS DATOS REALES
    final usuario = SessionManager().usuario;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              usuario?.nombre ?? 'Usuario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.rol.toUpperCase() ?? 'PACIENTE',
              style: const TextStyle(color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: const Text('Correo electrónico'),
                    subtitle: Text(usuario?.email ?? ''),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: const Text('Teléfono'),
                    subtitle: Text(usuario?.telefono ?? 'No registrado'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: const Text('Dirección'),
                    subtitle: Text(usuario?.direccion ?? 'No registrada'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botón Editar (Visual por ahora)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Edición de perfil próximamente"))
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 10),

            // BOTÓN CERRAR SESIÓN REAL
            TextButton.icon(
              onPressed: () => _cerrarSesion(context),
              icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.red),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}