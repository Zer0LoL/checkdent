import '../models/usuario_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Usuario? _usuario;
  String? _token;


  void setUsuario(Usuario usuario) {
    _usuario = usuario;
  }

  void setToken(String token) {
    _token = token;
  }


  Usuario? get usuario => _usuario;
  String? get token => _token;


  void logout() {
    _usuario = null;
    _token = null;
  }
}