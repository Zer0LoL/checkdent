import 'package:flutter/material.dart';
import '../view/home/home_page.dart';
import '../view/citas/citas_page.dart';
import '../view/contacto/contacto_page.dart';
import '../view/perfil/perfil_page.dart';

class AppRoutes {
  static const String citas = '/citas';
  static const String contacto = '/contacto';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get routes => {
    citas: (context) => const CitasPage(),
    contacto: (context) => const ContactoPage(),
    perfil: (context) => const PerfilPage(),
  };
}
