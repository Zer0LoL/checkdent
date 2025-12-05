import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/session_manager.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioService = UsuarioService();

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final usuario = SessionManager().usuario!;
    _nombreController = TextEditingController(text: usuario.nombre);
    _telefonoController = TextEditingController(text: usuario.telefono ?? '');
    _direccionController = TextEditingController(text: usuario.direccion ?? '');
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final nuevoUsuario = await _usuarioService.actualizarPerfil(
        _nombreController.text.trim(),
        _telefonoController.text.trim(),
        _direccionController.text.trim(),
      );

      SessionManager().setUsuario(nuevoUsuario);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado correctamente"), backgroundColor: Colors.green));
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil"), backgroundColor: AppColors.primary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? "El nombre es obligatorio" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Teléfono", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("GUARDAR CAMBIOS", style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}