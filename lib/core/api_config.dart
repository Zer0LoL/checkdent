class ApiConfig {
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  // --- MODO PRUEBA EN CELULAR FÍSICO (WiFi) ---
  // Si vas a probar el APK en tu cel conectado al mismo WiFi que tu PC:
  // static const String _baseUrl = 'http://192.168.1.XX:3000/api'; // Cambia XX por tu IP

  // --- MODO PRODUCCIÓN (Render) ---
  // Cuando ya lo subas a internet:
  // static const String _baseUrl = 'https://checkdent-backend.onrender.com/api';

  // Getter público
  static String get apiUrl => _baseUrl;

  // Getter para imágenes (si usas Cloudinary esto ya no será tan necesario, pero por si acaso)
  static String get imgBaseUrl => _baseUrl.replaceAll('/api', '');
}