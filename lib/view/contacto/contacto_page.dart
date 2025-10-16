import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';

class ContactoPage extends StatelessWidget {
  const ContactoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contacto'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Comunícate con tu doctora 🦷',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Tienes dudas sobre tu tratamiento o necesitas reprogramar una cita? '
                  'Puedes ponerte en contacto directamente con la doctora a través de los siguientes medios:',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primary),
                title: const Text('Teléfono'),
                subtitle: const Text('+51 987 654 321'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: AppColors.primary),
                title: const Text('Correo electrónico'),
                subtitle: const Text('dra.perez@checkdent.com'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.primary),
                title: const Text('Dirección'),
                subtitle: const Text('Av. Salud 123, Lima, Perú'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.primary),
                title: const Text('Horario de atención'),
                subtitle: const Text('Lunes a Sábado - 9:00 AM a 6:00 PM'),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Enviar mensaje directo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            PrimaryButton(
              text: 'Enviar Mensaje',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje enviado con éxito.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
