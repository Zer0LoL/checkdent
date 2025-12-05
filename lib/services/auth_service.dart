import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';
import '../core/session_manager.dart';
import '../core/api_config.dart';

class AuthService {
  static String baseUrl = '${ApiConfig.apiUrl}/usuarios';

  Future<Usuario> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("🟡 Respuesta Login: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final userData = body['data'];

        if (userData == null) {
          throw Exception("Error: El backend no envió los datos del usuario.");
        }

        Usuario usuario = Usuario.fromJson(userData);

        SessionManager().setUsuario(usuario);

        return usuario;
      } else {
        final errorData = jsonDecode(response.body);
        String msg = errorData['error']?['message'] ?? 'Error desconocido';
        throw Exception(msg);
      }
    } catch (e) {
      print("🔴 Error: $e");
      rethrow;
    }
  }

  Future<void> register(String nombre, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': 'paciente'
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      String msg = body['error']?['message'] ?? 'Error al registrarse';
      throw Exception(msg);
    }
  }
  Future<void> registerDoctor(String nombre, String email, String password, String especialidad) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}/usuarios/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': 'doctor', // <--- LA CLAVE
        'especialidad': especialidad
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      String msg = body['error']?['message'] ?? 'Error al registrar doctor';
      throw Exception(msg);
    }
  }
}