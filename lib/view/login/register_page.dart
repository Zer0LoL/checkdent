import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  void _handleRegister() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor llena todos los campos')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      // Éxito: Mostrar mensaje y volver al Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada! Inicia sesión ahora.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Vuelve atrás (al Login)

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.app_registration, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("REGISTRARSE", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}