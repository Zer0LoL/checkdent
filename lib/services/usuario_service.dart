import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/usuario_model.dart';
import '../core/session_manager.dart';
import '../core/api_config.dart';

class UsuarioService {
  static String baseUrl = '${ApiConfig.apiUrl}/usuarios';

  Future<List<Usuario>> obtenerDoctores() async {
    final response = await http.get(Uri.parse('$baseUrl/doctores/disponibles'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> lista = body['data'];
      return lista.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar doctores');
    }
  }

  Future<String> subirAvatar(File imagen) async {
    final usuario = SessionManager().usuario;
    if (usuario == null) throw Exception("No auth");

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/${usuario.id}/avatar'));

    request.headers.addAll({
      'x-user-id': usuario.id,
      'x-user-rol': usuario.rol,
    });


    String extension = imagen.path.split('.').last.toLowerCase();
    MediaType contentType;

    if (extension == 'png') {
      contentType = MediaType('image', 'png');
    } else {
      contentType = MediaType('image', 'jpeg');
    }

    request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        imagen.path,
        contentType: contentType
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return body['foto'];
    } else {
      final body = jsonDecode(response.body);
      String errorMsg = body['error']?['message'] ?? 'Fallo al subir imagen';
      throw Exception(errorMsg);
    }
  }
  Future<Usuario> actualizarPerfil(String nombre, String telefono, String direccion) async {
    final usuario = SessionManager().usuario;
    if (usuario == null) throw Exception("No auth");

    final response = await http.put(
      Uri.parse('$baseUrl/${usuario.id}'),
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': usuario.id,
        'x-user-rol': usuario.rol,
      },
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'direccion': direccion,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      return Usuario.fromJson(data);
    } else {
      throw Exception('Error al actualizar perfil');
    }
  }
}