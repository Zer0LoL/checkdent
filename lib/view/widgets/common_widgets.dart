import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? AppColors.primary : Colors.white,
        side: BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CitaCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String hora;

  const CitaCard({
    super.key,
    required this.titulo,
    required this.fecha,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event_available, color: AppColors.primary),
        title: Text(titulo),
        subtitle: Text(fecha),
        trailing: Text(hora, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class ConsejoCard extends StatelessWidget {
  final String titulo;
  final String autor;

  const ConsejoCard({
    super.key,
    required this.titulo,
    required this.autor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(titulo),
        subtitle: Text(autor),
      ),
    );
  }
}

class QuickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickOption({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
