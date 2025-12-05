import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';
import '../../services/citas_service.dart';

class AgendarCitaPage extends StatefulWidget {
  const AgendarCitaPage({super.key});

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  final _formKey = GlobalKey<FormState>();

  // Servicios
  final UsuarioService _usuarioService = UsuarioService();
  final CitasService _citasService = CitasService();

  // Datos del formulario
  Usuario? _doctorSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();

  // Estado
  List<Usuario> _listaDoctores = [];
  bool _isLoadingDoctores = true;
  bool _isGuardando = false;

  // Lista simple de horas (Podrías mejorarla trayendo disponibilidad del backend)
  final List<String> _horarios = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "15:00", "15:30", "16:00", "16:30", "17:00"
  ];

  @override
  void initState() {
    super.initState();
    _cargarDoctores();
  }

  Future<void> _cargarDoctores() async {
    try {
      final docs = await _usuarioService.obtenerDoctores();
      setState(() {
        _listaDoctores = docs;
        _isLoadingDoctores = false;
      });
    } catch (e) {
      setState(() => _isLoadingDoctores = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error cargando doctores: $e")));
    }
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona una fecha")));
      return;
    }

    setState(() => _isGuardando = true);

    try {
      await _citasService.crearCita(
        doctorId: _doctorSeleccionado!.id,
        fecha: _fechaSeleccionada!,
        hora: _horaSeleccionada!,
        motivo: _motivoController.text,
      );

      if (!mounted) return;

      // Éxito
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Cita agendada con éxito!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context, true); // Regresa true para que la pantalla anterior recargue

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception:', '')}"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isGuardando = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva Cita"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selecciona un Especialista", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _isLoadingDoctores
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<Usuario>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text("Elige un doctor"),
                items: _listaDoctores.map((doc) {
                  return DropdownMenuItem(
                    value: doc,
                    child: Text("${doc.nombre} (${doc.especialidad ?? 'Dentista'})"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _doctorSeleccionado = val),
                validator: (val) => val == null ? 'Campo requerido' : null,
              ),

              const SizedBox(height: 20),
              const Text("Fecha de la cita", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _fechaSeleccionada == null
                        ? "Seleccionar fecha"
                        : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}",
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Hora disponible", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text("Elige una hora"),
                items: _horarios.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: (val) => setState(() => _horaSeleccionada = val),
                validator: (val) => val == null ? 'Campo requerido' : null,
              ),

              const SizedBox(height: 20),
              const Text("Motivo de consulta", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _motivoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Ej: Dolor de muela, limpieza...",
                ),
                validator: (v) => v!.isEmpty ? 'Escribe el motivo' : null,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGuardando ? null : _guardarCita,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _isGuardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CONFIRMAR CITA", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}