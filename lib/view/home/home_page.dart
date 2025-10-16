import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('CheckDent'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Bienvenida, Dra. Pérez 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aquí tienes un resumen de tus próximas citas y recordatorios.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                QuickOption(
                  icon: Icons.event,
                  label: 'Ver Citas',
                  onTap: () {
                    Navigator.pushNamed(context, '/citas');
                  },
                ),
                const SizedBox(width: 8),
                QuickOption(
                  icon: Icons.notifications,
                  label: 'Recordatorios',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                QuickOption(
                  icon: Icons.message,
                  label: 'Contacto',
                  onTap: () {
                    Navigator.pushNamed(context, '/contacto');
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Text(
              'Próximas citas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const CitaCard(
              titulo: 'Control de ortodoncia - Juan Pérez',
              fecha: 'Martes 22 de Octubre, 10:00 AM',
              hora: '10:00 AM',
            ),
            const CitaCard(
              titulo: 'Limpieza dental - María López',
              fecha: 'Miércoles 23 de Octubre, 4:30 PM',
              hora: '4:30 PM',
            ),

            const SizedBox(height: 25),
            const Text(
              'Consejos de cuidado dental 🦷',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const ConsejoCard(
              titulo: 'Evita alimentos duros si usas brackets.',
              autor: 'Recomendado por CheckDent',
            ),
            const ConsejoCard(
              titulo: 'Usa hilo dental todos los días.',
              autor: 'Consejo de la Dra. Pérez',
            ),
            const ConsejoCard(
              titulo: 'Programa una limpieza cada 6 meses.',
              autor: 'CheckDent Tips',
            ),
          ],
        ),
      ),
    );
  }
}
