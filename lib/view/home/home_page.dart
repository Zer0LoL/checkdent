import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../../core/session_manager.dart';
import '../../services/citas_service.dart';
import '../../models/cita_model.dart';
import '../main_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CitasService _citasService = CitasService();
  List<Cita> _citasProximas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  // Cargamos las citas para mostrar solo las próximas en el Home
  Future<void> _cargarResumen() async {
    try {
      final citas = await _citasService.obtenerMisCitas();
      final hoy = DateTime.now();

      // Filtramos solo las futuras y activas
      final proximas = citas.where((c) =>
      c.fecha.isAfter(hoy.subtract(const Duration(days: 1))) &&
          c.estado != 'cancelada'
      ).toList();

      // Ordenamos por fecha
      proximas.sort((a, b) => a.fecha.compareTo(b.fecha));

      if (mounted) {
        setState(() {
          // Solo tomamos las 2 primeras para no saturar el Home
          _citasProximas = proximas.take(2).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error cargando resumen home: $e");
    }
  }

  // Función para formatear fecha simple
  String _formatoFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessionManager().usuario;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator( // Permite deslizar hacia abajo para recargar
        onRefresh: _cargarResumen,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Citas Dentales",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.notifications_none, color: Colors.black54),
                      SizedBox(width: 12),
                      Icon(Icons.settings_outlined, color: Colors.black54),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TARJETA DE BIENVENIDA
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        // Si tiene foto la usamos, si no icono
                        child: usuario?.foto != null
                            ? null
                            : const Icon(Icons.person, size: 35, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Bienvenido, ${usuario?.nombre ?? 'Paciente'}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            Text(
                                usuario?.email ?? "",
                                style: const TextStyle(color: Colors.black54)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // BOTONES DE ACCIÓN RÁPIDA
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {

                        final mainScreenState = context.findAncestorStateOfType<State<MainScreen>>();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ve a la pestaña 'Citas' para agendar"))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      label: const Text("Sacar cita", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.settings, color: AppColors.primary),
                      label: const Text("Configuración", style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECCIÓN DINÁMICA DE PRÓXIMAS CITAS
              const Text("Próximas Citas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_citasProximas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.event_available, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text("Todo al día", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text("No tienes citas próximas.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                ..._citasProximas.map((cita) => AppointmentCard(
                  icon: Icons.calendar_month,
                  title: cita.tratamientoNombre,
                  date: _formatoFecha(cita.fecha),
                  time: cita.horaInicio,
                  status: cita.estado.toUpperCase(),
                  statusColor: cita.estado == 'confirmada' ? Colors.green : Colors.orange,
                )),

              const SizedBox(height: 24),

              const Text("Opciones Rápidas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  QuickOptionCard(icon: Icons.people, label: "Ver Dentistas", onTap: () {}),
                  const SizedBox(width: 12),
                  QuickOptionCard(icon: Icons.location_on, label: "Ubicación", onTap: () {}),
                ],
              ),

              const SizedBox(height: 24),

              const Text("Consejos de Salud", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}