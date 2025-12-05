import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'view/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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