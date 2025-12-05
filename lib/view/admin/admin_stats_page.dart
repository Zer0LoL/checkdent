import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/admin_service.dart';

class AdminStatsPage extends StatefulWidget {
  const AdminStatsPage({super.key});

  @override
  State<AdminStatsPage> createState() => _AdminStatsPageState();
}

class _AdminStatsPageState extends State<AdminStatsPage> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    try {
      final info = await _adminService.obtenerDashboard();
      if (mounted) setState(() {
        _data = info['dashboard'];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporte Clínica"), backgroundColor: Colors.black87),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text("No hay datos disponibles"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Resumen de Hoy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatCard(
                  label: "Total Citas",
                  value: _data!['hoy']['total'].toString(),
                  color: Colors.blue,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: "Pendientes",
                  value: _data!['hoy']['pendientes'].toString(),
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Métricas Mensuales", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _FullWidthCard(
              title: "Total Pacientes Registrados",
              value: _data!['pacientes_totales'].toString(),
              icon: Icons.people_alt,
            ),
            const SizedBox(height: 10),
            _FullWidthCard(
              title: "Citas Completadas (Mes)",
              value: _data!['mes_actual']['completadas'].toString(),
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),

            const SizedBox(height: 20),
            const Text("Tratamientos Populares", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...(_data!['tratamientos_populares'] as List).map((t) => Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(t['nombre']),
                trailing: Text("${t['total_citas']} citas", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _FullWidthCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _FullWidthCard({required this.title, required this.value, required this.icon, this.iconColor = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 15),
                Text(title, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}