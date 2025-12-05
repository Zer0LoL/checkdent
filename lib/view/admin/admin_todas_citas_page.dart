import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/admin_service.dart';

class AdminTodasCitasPage extends StatefulWidget {
  const AdminTodasCitasPage({super.key});

  @override
  State<AdminTodasCitasPage> createState() => _AdminTodasCitasPageState();
}

class _AdminTodasCitasPageState extends State<AdminTodasCitasPage> {
  final AdminService _adminService = AdminService();
  List<dynamic> _citas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    try {
      final data = await _adminService.obtenerCitasPendientes();
      if (mounted) setState(() {
        _citas = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarCancelacion(String citaId, String paciente) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Cancelar Cita?"),
        content: Text("Estás a punto de cancelar la cita de $paciente. Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cerrar diálogo
              await _ejecutarCancelacion(citaId);
            },
            child: const Text("Sí, Cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarCancelacion(String citaId) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.cancelarCita(citaId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cita cancelada"), backgroundColor: Colors.green));
      _cargarCitas(); // Recargar lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Citas"), backgroundColor: Colors.black87),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _citas.isEmpty
          ? const Center(child: Text("No hay citas pendientes"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _citas.length,
        itemBuilder: (context, index) {
          final cita = _citas[index];
          final paciente = cita['paciente']?['nombre'] ?? 'Anónimo';
          final telefono = cita['paciente']?['telefono'] ?? 'Sin teléfono';
          final fechaRaw = DateTime.parse(cita['fecha']);
          final fecha = "${fechaRaw.day}/${fechaRaw.month}/${fechaRaw.year}";

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                    title: Text(paciente, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("📞 $telefono\n👨‍⚕️ Dr. ${cita['doctor']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => _confirmarCancelacion(cita['id'], paciente),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(fecha)]),
                      Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 5), Text(cita['horaInicio'])]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(cita['estado'].toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}