import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'view/home/home_page.dart';
import 'view/citas/citas_page.dart';
import 'view/contacto/contacto_page.dart';
import 'view/perfil/perfil_page.dart';
import 'core/app_colors.dart';

void main() => runApp(const CheckDentApp());

class CheckDentApp extends StatelessWidget {
  const CheckDentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckDent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: AppRoutes.routes,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomePage(),
    CitasPage(),
    ContactoPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Contacto'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
