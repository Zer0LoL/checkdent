import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/app_colors.dart';

class RegistrarDoctorPage extends StatefulWidget {
  const RegistrarDoctorPage({super.key});

  @override
  State<RegistrarDoctorPage> createState() => _RegistrarDoctorPageState();
}

class _RegistrarDoctorPageState extends State<RegistrarDoctorPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.registerDoctor(
        _nombreCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
        _especialidadCtrl.text.trim(),
      );

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Doctor registrado exitosamente"), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Doctor"), backgroundColor: Colors.black87),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre del Doctor", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _especialidadCtrl,
                decoration: const InputDecoration(labelText: "Especialidad (Ej: Ortodoncia)", prefixIcon: Icon(Icons.medical_services), border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Correo Electrónico", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                validator: (v) => v!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registrar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("REGISTRAR DOCTOR", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}