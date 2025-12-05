import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consejo_model.dart';
import '../core/api_config.dart';

class ConsejosService {
  static String baseUrl = '${ApiConfig.apiUrl}/consejos';

  Future<List<Consejo>> obtenerConsejos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> lista = body['consejos'];
      return lista.map((json) => Consejo.fromJson(json)).toList();
    } else {
      throw Exception('Error cargando consejos');
    }
  }
}