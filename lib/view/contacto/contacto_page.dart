import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';

class ContactoPage extends StatelessWidget {
  const ContactoPage({super.key});

  Future<void> _abrirWhatsApp() async {
    final uri = Uri.parse("https://wa.me/51987654321?text=Hola,%20quisiera%20más%20información");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw 'Error';
  }

  Future<void> _hacerLlamada() async {
    final uri = Uri.parse("tel:+51987654321");
    if (!await launchUrl(uri)) throw 'Error';
  }

  Future<void> _abrirMapa() async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=-12.043889,-76.997806");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw 'Error';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Contáctanos", style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/mapa_clinica.png',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.4)),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Clínica Dental CheckDent", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _abrirMapa,
                      child: Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Expanded(child: Text("Av. Los Incas 1234, Lima, Perú", style: TextStyle(fontSize: 16, decoration: TextDecoration.underline))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("Horarios de Atención", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,4))],
                      ),
                      child: Column(
                        children: [
                          _buildHorarioRow("Lunes - Viernes", "09:00 AM - 08:00 PM", true),
                          const Divider(),
                          _buildHorarioRow("Sábados", "09:00 AM - 06:00 PM", true),
                          const Divider(),
                          _buildHorarioRow("Domingos", "09:00 AM - 01:00 PM", false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text("Canales de Contacto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildContactButton(
                            label: "WhatsApp",
                            icon: FontAwesomeIcons.whatsapp,
                            color: Colors.green,
                            onTap: _abrirWhatsApp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildContactButton(
                            label: "Llamar",
                            icon: Icons.phone,
                            color: AppColors.primary,
                            onTap: _hacerLlamada,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildContactButton(
                        label: "Ver en Google Maps",
                        icon: Icons.map,
                        color: Colors.blueAccent,
                        onTap: _abrirMapa,
                        isFullWidth: true
                    ),

                    const SizedBox(height: 30),
                    Center(child: Text("¡Tu sonrisa es nuestra prioridad!", style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioRow(String dia, String hora, bool abierto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dia, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: abierto ? Colors.green : Colors.orange),
              const SizedBox(width: 6),
              Text(hora, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({required String label, required IconData icon, required Color color, required VoidCallback onTap, bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
      ),
    );
  }
}