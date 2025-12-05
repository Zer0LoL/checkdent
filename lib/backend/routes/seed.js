const express = require('express');
const router = express.Router();
const Usuario = require('../models/Usuario');
const Cita = require('../models/Cita');
const Tratamiento = require('../models/Tratamiento');
const Consejo = require('../models/Consejo');
const bcrypt = require('bcryptjs');

router.get('/reset-completo', async (req, res) => {
  try {
    // 1. Limpiar BD (Esto borrará el admin viejo y creará uno nuevo limpio)
    await Usuario.deleteMany({});
    await Cita.deleteMany({});
    await Tratamiento.deleteMany({});
    await Consejo.deleteMany({});

    console.log("🧹 Base de datos limpiada");

    // 2. Crear Usuarios (Contraseña universal '123456')
    // El hook pre-save del modelo se encargará de encriptarla

    const admin = await Usuario.create({
      nombre: "Super Admin",
      email: "admin@checkdent.com",
      password: "123456",
      rol: "admin",
      estado: "activo"
    });

    const doctor = await Usuario.create({
      nombre: "Dr. House",
      email: "doctor@checkdent.com",
      password: "123456",
      rol: "doctor",
      especialidad: "Ortodoncia",
      estado: "activo"
    });

    const paciente = await Usuario.create({
      nombre: "Paciente Prueba",
      email: "paciente@checkdent.com",
      password: "123456",
      rol: "paciente",
      telefono: "999888777",
      estado: "activo"
    });

    // 3. Crear Tratamientos
    const t1 = await Tratamiento.create({ nombre: "Limpieza Profunda", costo: 50, duracionPromedio: 30, doctorId: doctor._id });
    const t2 = await Tratamiento.create({ nombre: "Blanqueamiento", costo: 150, duracionPromedio: 60, doctorId: doctor._id });

    // 4. Crear Consejos
    await Consejo.insertMany([
      { titulo: "Cepillado 45°", descripcion: "Inclina el cepillo a 45 grados contra la encía.", autor: "Dr. House" },
      { titulo: "Hilo Dental", descripcion: "Úsalo diariamente antes de dormir.", autor: "Clínica" }
    ]);

    // 5. Crear Citas de Ejemplo (CORREGIDO: estado 'programada')
    const hoy = new Date();
    const mañana = new Date(hoy); mañana.setDate(hoy.getDate() + 1);
    const ayer = new Date(hoy); ayer.setDate(hoy.getDate() - 1);

    await Cita.create([
      { // Cita PASADA
        pacienteId: paciente._id, doctorId: doctor._id, tratamientoId: t1._id,
        fecha: ayer, horaInicio: "10:00", horaFin: "10:30", estado: "completada"
      },
      { // Cita HOY (Era 'pendiente', ahora es 'programada')
        pacienteId: paciente._id, doctorId: doctor._id, tratamientoId: t2._id,
        fecha: hoy, horaInicio: "15:00", horaFin: "16:00", estado: "programada"
      },
      { // Cita MAÑANA (Era 'pendiente', ahora es 'programada')
        pacienteId: paciente._id, doctorId: doctor._id, tratamientoId: t1._id,
        fecha: mañana, horaInicio: "09:00", horaFin: "09:30", estado: "programada"
      }
    ]);

    res.json({
      msg: "✅ ¡Base de datos reiniciada con éxito!",
      cuentas: {
        admin: "admin@checkdent.com / 123456",
        doctor: "doctor@checkdent.com / 123456",
        paciente: "paciente@checkdent.com / 123456"
      }
    });

  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;