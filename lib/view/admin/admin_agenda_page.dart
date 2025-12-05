import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/admin_service.dart';

class AdminAgendaPage extends StatefulWidget {
  const AdminAgendaPage({super.key});

  @override
  State<AdminAgendaPage> createState() => _AdminAgendaPageState();
}

class _AdminAgendaPageState extends State<AdminAgendaPage> {
  final AdminService _adminService = AdminService();
  List<dynamic> _citas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAgenda();
  }

  Future<void> _cargarAgenda() async {
    try {
      final data = await _adminService.obtenerCitasHoy();
      if (mounted) setState(() {
        _citas = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agenda Global (Hoy)"), backgroundColor: Colors.black87),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _citas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_available, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("No hay citas programadas para hoy", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _citas.length,
        itemBuilder: (context, index) {
          final cita = _citas[index];
          final paciente = cita['paciente']?['nombre'] ?? 'Anónimo';
          final doctor = cita['tratamiento']?['nombre'] ?? 'Consulta';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColorEstado(cita['estado']),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(paciente, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Tratamiento: $doctor"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  Text(cita['horaInicio'] ?? '--:--'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorEstado(String? estado) {
    switch (estado) {
      case 'confirmada': return Colors.green;
      case 'pendiente': return Colors.orange;
      case 'cancelada': return Colors.red;
      case 'completada': return Colors.blue;
      default: return Colors.grey;
    }
  }
}