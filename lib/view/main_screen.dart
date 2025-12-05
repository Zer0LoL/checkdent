import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'home/home_page.dart';
import 'citas/citas_page.dart';
import 'contacto/contacto_page.dart';
import 'perfil/perfil_page.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: mainScreenKey);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

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
        type: BottomNavigationBarType.fixed,
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