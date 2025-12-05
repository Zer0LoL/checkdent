import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/session_manager.dart';

class AdminService {
  Future<Map<String, dynamic>> obtenerDashboard() async {
    final usuario = SessionManager().usuario;
    final response = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/admin/dashboard'),
      headers: {
        'x-user-id': usuario!.id,
        'x-user-rol': usuario.rol,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error cargando dashboard');
    }
  }

  Future<List<dynamic>> obtenerCitasHoy() async {
    final usuario = SessionManager().usuario;
    final response = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/admin/citas/hoy'),
      headers: {
        'x-user-id': usuario!.id,
        'x-user-rol': usuario.rol,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['citas'];
    } else {
      throw Exception('Error cargando agenda');
    }
  }
  Future<List<dynamic>> obtenerCitasPendientes() async {
    final usuario = SessionManager().usuario;
    final response = await http.get(
      Uri.parse('${ApiConfig.apiUrl}/admin/citas/pendientes'),
      headers: {
        'x-user-id': usuario!.id,
        'x-user-rol': usuario.rol,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['citas'];
    } else {
      throw Exception('Error cargando citas pendientes');
    }
  }


  Future<void> cancelarCita(String citaId) async {
    final usuario = SessionManager().usuario;
    final response = await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/citas/$citaId/cancelar'),
      headers: {
        'x-user-id': usuario!.id,
        'x-user-rol': usuario.rol,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo cancelar la cita');
    }
  }

}