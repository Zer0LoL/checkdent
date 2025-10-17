import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/common_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Citas Dentales",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: Colors.black54),
                    SizedBox(width: 12),
                    Icon(Icons.settings_outlined, color: Colors.black54),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Bienvenido, Juan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text("Lista de Citas",
                              style: TextStyle(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Ver historial"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    label: const Text("Sacar cita", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.settings, color: AppColors.primary),
                    label: const Text("Configuración",
                        style: TextStyle(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text("Próximas Citas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            AppointmentCard(
              icon: Icons.cleaning_services,
              title: "Limpieza Dental",
              date: "12/12/2023",
              time: "10:00 AM",
              status: "Confirmada",
              statusColor: Colors.green,
            ),
            AppointmentCard(
              icon: Icons.medical_services_outlined,
              title: "Revisión General",
              date: "15/12/2023",
              time: "09:30 AM",
              status: "Pendiente",
              statusColor: Colors.orange,
            ),

            const SizedBox(height: 24),

            const Text("Opciones Rápidas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: [
                QuickOptionCard(
                  icon: Icons.people,
                  label: "Ver Dentistas",
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                QuickOptionCard(
                  icon: Icons.location_on,
                  label: "Ubicación",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text("Consejos de Salud Dental",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: AdviceCard(
                    title: "Cuida tu cepillado",
                    description: "Cepilla tus dientes al menos dos veces al día.",
                    doctor: "Dr. Pérez",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AdviceCard(
                    title: "Visita al dentista",
                    description: "Hazte una revisión cada 6 meses.",
                    doctor: "Clínica Sonrisa",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
