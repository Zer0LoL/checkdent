import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../../models/cita_model.dart';
import '../../services/citas_service.dart';
import 'agendar_cita_page.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final CitasService _citasService = CitasService();
  List<Cita> _todasLasCitas = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    try {
      final citas = await _citasService.obtenerMisCitas();
      if (mounted) {
        setState(() {
          _todasLasCitas = citas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }


  String _formatearFecha(DateTime fecha) {

    return DateFormat('EEE d MMM', 'es').format(fecha);
  }

  @override
  Widget build(BuildContext context) {

    final hoy = DateTime.now();

    final proximas = _todasLasCitas.where((c) =>
    c.fecha.isAfter(hoy.subtract(const Duration(days: 1))) &&
        c.estado != 'cancelada'
    ).toList();

    final pasadas = _todasLasCitas.where((c) =>
    !proximas.contains(c)
    ).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text("Error: $_errorMessage"))
          : RefreshIndicator(
        onRefresh: _cargarCitas,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SECCIÓN PRÓXIMAS
            const Text(
              'Próximas Citas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (proximas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No tienes citas próximas agendadas."),
              ),

            ...proximas.map((cita) => CitaCard(
              titulo: cita.tratamientoNombre,
              fecha: _formatearFecha(cita.fecha),
              hora: cita.horaInicio,
              esProxima: true,

            )),

            const SizedBox(height: 24),

            // SECCIÓN PASADAS
            const Text(
              'Citas Pasadas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (pasadas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("No tienes historial de citas."),
              ),

            ...pasadas.map((cita) => CitaCard(
              titulo: "${cita.tratamientoNombre} (${cita.estado})",
              fecha: _formatearFecha(cita.fecha),
              hora: cita.horaInicio,
              esProxima: false,
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navegamos y esperamos respuesta (true si agendó)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgendarCitaPage()),
          );

          // Si agendó, recargamos la lista de citas
          if (result == true) {
            _cargarCitas();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Agendar Cita'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}