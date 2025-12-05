import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/session_manager.dart';
import '../login/login_page.dart';
import 'registrar_doctor_page.dart';
import 'admin_agenda_page.dart';
import 'admin_stats_page.dart';
import 'admin_todas_citas_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _cerrarSesion(BuildContext context) {
    SessionManager().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(onPressed: () => _cerrarSesion(context), icon: const Icon(Icons.logout))
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _AdminCard(
            icon: Icons.person_add,
            title: "Registrar Doctor",
            color: Colors.blue,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrarDoctorPage()));
            },
          ),
          _AdminCard(
            icon: Icons.calendar_month,
            title: "Gestionar Citas",
            color: Colors.orange,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminTodasCitasPage()));
            },
          ),

          _AdminCard(
            icon: Icons.calendar_month,
            title: "Ver Citas de Hoy",
            color: Colors.orange,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAgendaPage()));
            },
          ),

          _AdminCard(
            icon: Icons.edit_calendar,
            title: "Horarios",
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configuración de horarios próximamente")));
            },
          ),

          _AdminCard(
            icon: Icons.analytics,
            title: "Reportes",
            color: Colors.purple,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminStatsPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 30, color: color)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}