import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_model.dart';
import '../core/session_manager.dart';
import '../core/api_config.dart';

class CitasService {
  static String baseUrl = '${ApiConfig.apiUrl}/citas';

  Future<List<Cita>> obtenerMisCitas() async {
    final usuario = SessionManager().usuario;

    if (usuario == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
    }

    final url = Uri.parse('$baseUrl/historial/${usuario.id}');

    print("🔵 Pidiendo citas a: $url");
    print("🔵 Con Headers: x-user-id: ${usuario.id}");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': usuario.id,
        'x-user-rol': usuario.rol,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> listaCitas = data['citas'];
      return listaCitas.map((json) => Cita.fromJson(json)).toList();
    } else {
      print("🔴 Error Citas: ${response.body}");
      throw Exception('Error al cargar citas: ${response.statusCode}');
    }
  }
  Future<void> crearCita({
    required String doctorId,
    required DateTime fecha,
    required String hora,
    required String motivo,
  }) async {
    final usuario = SessionManager().usuario;
    if (usuario == null) throw Exception('Sesión no válida');

    final url = Uri.parse(baseUrl); // POST a /api/citas

    // Calculamos hora fin (30 min después por defecto)
    // Formato esperado: "HH:mm"
    final horas = int.parse(hora.split(':')[0]);
    final minutos = int.parse(hora.split(':')[1]);
    final fin = DateTime(2023, 1, 1, horas, minutos).add(const Duration(minutes: 30));
    final horaFin = "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}";

    final body = {
      "pacienteId": usuario.id,
      "doctorId": doctorId,
      "fecha": fecha.toIso8601String(),
      "horaInicio": hora,
      "horaFin": horaFin,
      "motivo": motivo,
      "tratamientoId": null // Opcional
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': usuario.id,
        'x-user-rol': usuario.rol,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al agendar cita');
    }
  }
}