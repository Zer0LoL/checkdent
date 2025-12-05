import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'editar_perfil_page.dart';
import '../../core/app_colors.dart';
import '../../core/session_manager.dart';
import '../../services/usuario_service.dart';
import '../../models/usuario_model.dart';
import '../login/login_page.dart';
import 'package:checkdent/core/api_config.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final UsuarioService _usuarioService = UsuarioService();

  final String _baseUrl = 'http://10.0.2.2:3000';

  void _cerrarSesion() {
    SessionManager().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _procesarImagen(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imagen = File(pickedFile.path);
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subiendo imagen...")));
        String nuevaUrl = await _usuarioService.subirAvatar(imagen);

        final usuarioActual = SessionManager().usuario!;
        final usuarioActualizado = Usuario(
            id: usuarioActual.id,
            nombre: usuarioActual.nombre,
            email: usuarioActual.email,
            rol: usuarioActual.rol,
            telefono: usuarioActual.telefono,
            direccion: usuarioActual.direccion,
            especialidad: usuarioActual.especialidad,
            foto: nuevaUrl
        );

        SessionManager().setUsuario(usuarioActualizado);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Foto actualizada!"), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _cambiarFoto() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => _procesarImagen(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () => _procesarImagen(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessionManager().usuario;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            GestureDetector(
              onTap: _cambiarFoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    backgroundImage: usuario?.foto != null
                        ? NetworkImage(
                        usuario!.foto!.startsWith('http')
                            ? usuario!.foto!
                            : '${ApiConfig.imgBaseUrl}${usuario!.foto!}'
                    )
                        : null,
                    child: usuario?.foto == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              usuario?.nombre ?? 'Usuario',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              usuario?.rol.toUpperCase() ?? 'PACIENTE',
              style: const TextStyle(color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: const Text('Correo electrónico'),
                    subtitle: Text(usuario?.email ?? ''),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: const Text('Teléfono'),
                    subtitle: Text(usuario?.telefono ?? 'No registrado'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: AppColors.primary),
                    title: const Text('Dirección'),
                    subtitle: Text(usuario?.direccion ?? 'No registrada'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditarPerfilPage()),
                );

                if (resultado == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: _cerrarSesion,
              icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.red),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}