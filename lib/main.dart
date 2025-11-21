import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- 1. IMPORTA ESTO

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'view/login/login_page.dart'; // Tu pantalla de inicio

// 2. CONVIERTE EL MAIN EN ASYNC
void main() async {
  // Asegura que los motores de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 3. CARGA EL IDIOMA ESPAÑOL (Mata el error LocaleDataException)
  await initializeDateFormatting('es');

  runApp(const CheckDentApp());
}

class CheckDentApp extends StatelessWidget {
  const CheckDentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckDent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      home: const LoginPage(),
    );
  }
}