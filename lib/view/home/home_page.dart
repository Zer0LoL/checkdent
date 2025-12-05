import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../../core/session_manager.dart';
import '../../services/citas_service.dart';
import '../../services/consejos_service.dart';
import '../../models/cita_model.dart';
import '../../models/consejo_model.dart';
import '../main_screen.dart';
import '../../core/api_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CitasService _citasService = CitasService();
  final ConsejosService _consejosService = ConsejosService();

  List<Cita> _citasProximas = [];
  List<Consejo> _consejos = [];

  bool _isLoadingCitas = true;
  bool _isLoadingConsejos = true;


  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    _cargarCitas();
    _cargarConsejos();
  }

  Future<void> _cargarCitas() async {
    try {
      final citas = await _citasService.obtenerMisCitas();
      final hoy = DateTime.now();
      final proximas = citas.where((c) =>
      c.fecha.isAfter(hoy.subtract(const Duration(days: 1))) &&
          c.estado != 'cancelada'
      ).toList();
      proximas.sort((a, b) => a.fecha.compareTo(b.fecha));

      if (mounted) setState(() {
        _citasProximas = proximas.take(2).toList();
        _isLoadingCitas = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingCitas = false);
    }
  }

  Future<void> _cargarConsejos() async {
    try {
      final data = await _consejosService.obtenerConsejos();
      if (mounted) setState(() {
        _consejos = data;
        _isLoadingConsejos = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingConsejos = false);
    }
  }

  String _formatoFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessionManager().usuario;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _cargarTodo,
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
                  const Text("Citas Dentales", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Icon(Icons.notifications_none, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 20),

              // TARJETA BIENVENIDA
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        backgroundImage: usuario?.foto != null
                            ? NetworkImage(
                            usuario!.foto!.startsWith('http')
                                ? usuario!.foto!
                                : '${ApiConfig.imgBaseUrl}${usuario!.foto!}'
                        )
                            : null,
                        child: usuario?.foto == null
                            ? const Icon(Icons.person, size: 35, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bienvenido, ${usuario?.nombre ?? 'Paciente'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(usuario?.email ?? "", style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // BOTONES ACCIÓN
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      // LOGICA NAVEGACIÓN CORREGIDA
                      onPressed: () {
                        // Usamos la llave maestra para cambiar a la pestaña 1 (Citas)
                        mainScreenKey.currentState?.changeTab(1);
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
                      onPressed: () {
                        // Aquí podrías llevar a perfil
                        mainScreenKey.currentState?.changeTab(3);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.person, color: AppColors.primary),
                      label: const Text("Mi Perfil", style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text("Próximas Citas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_isLoadingCitas)
                const Center(child: CircularProgressIndicator())
              else if (_citasProximas.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(children: const [
                    Icon(Icons.event_available, size: 40, color: Colors.grey),
                    Text("No tienes citas próximas", style: TextStyle(color: Colors.grey))
                  ]),
                )
              else
                ..._citasProximas.map((cita) => AppointmentCard(
                  icon: Icons.calendar_month,
                  title: cita.tratamientoNombre,
                  date: _formatoFecha(cita.fecha),
                  time: cita.horaInicio,
                  status: cita.estado.toUpperCase(),
                  statusColor: Colors.green,
                )),

              const SizedBox(height: 24),
              const Text("Consejos de Salud", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // CARRUSEL CONSEJOS CORREGIDO
              SizedBox(
                height: 140,
                child: _isLoadingConsejos
                    ? const Center(child: CircularProgressIndicator())
                    : _consejos.isEmpty
                    ? const Center(child: Text("No hay consejos disponibles"))
                    : PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: _consejos.length,
                  itemBuilder: (context, index) {
                    final item = _consejos[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("💡 ${item.titulo}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 5),
                          Text(item.descripcion, maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}