const express = require('express');
const { auth, requireAuthenticated, requireDoctor } = require('../middleware/auth');
const { schemas, validate } = require('../middleware/validation');
const { enviarCorreoCita } = require('../utils/emailService');
const Cita = require('../models/Cita');
const Tratamiento = require('../models/Tratamiento');
const Usuario = require('../models/Usuario');


const router = express.Router();

// GET /api/citas/disponibilidad - Get doctor's availability
router.get('/disponibilidad', auth, async (req, res) => {
  try {
    const { fecha, id_doctor } = req.query;

    if (!fecha) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Date parameter is required'
      });
    }

    // If no doctor specified, get the first doctor (assuming single practice)
    let doctorId = id_doctor;
    if (!doctorId) {
      const doctor = await Usuario.findOne({ rol: 'doctor' });
      
      if (!doctor) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'No doctor available'
        });
      }
      
      doctorId = doctor._id;
    }

    // Get existing appointments for the specified date
    const existingCitas = await Cita.find({
      fecha: new Date(fecha),
      estado: { $in: ['pendiente', 'confirmada'] }
    });

    // Generate available time slots (9 AM to 6 PM, 1-hour slots)
    const workingHours = [];
    for (let hour = 9; hour < 18; hour++) {
      const timeSlot = `${hour.toString().padStart(2, '0')}:00`;
      workingHours.push(timeSlot);
    }

    // Filter out booked slots
    const bookedHours = existingCitas.map(cita => {
      const time = new Date(cita.horaInicio);
      return time.getHours().toString().padStart(2, '0') + ':00';
    });

    const availableHours = workingHours.filter(hour => 
      !bookedHours.includes(hour)
    );

    res.json({
      fecha,
      doctorId,
      available_slots: availableHours,
      booked_slots: bookedHours
    });

  } catch (error) {
    console.error('Get availability error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get availability'
    });
  }
});


// POST /api/citas - Schedule new appointment
const createCitaHandler = async (req, res) => {
  try {
    const {
      pacienteId: bodyPacienteId,
      doctorId,
      tratamientoId,
      fecha,
      horaInicio,
      horaFin,
      motivo,
      notas
    } = req.validatedBody || {};

    // Prefer pacienteId from body, otherwise use authenticated user
    const pacienteId = bodyPacienteId || req.usuario?.id;

    if (!pacienteId) {
      return res.status(400).json({ error: 'Bad Request', message: 'PacienteId is required' });
    }

    // Only patients can schedule for themselves (doctors can create for patients)
    if (req.usuario && req.usuario.rol === 'paciente' && req.usuario.id !== pacienteId) {
      return res.status(403).json({ error: 'Forbidden', message: 'Patients can only schedule for themselves' });
    }

    // Validate doctor and treatment
    const [doctor, tratamiento] = await Promise.all([
      Usuario.findById(doctorId),
      Tratamiento.findById(tratamientoId)
    ]);

    if (!doctor) return res.status(404).json({ error: 'Not Found', message: 'Doctor not found' });
    if (tratamientoId && !tratamiento) return res.status(404).json({ error: 'Not Found', message: 'Treatment not found' });

    // Check conflict
    const targetDate = new Date(fecha);
    targetDate.setHours(0,0,0,0);
    const nextDate = new Date(targetDate);
    nextDate.setDate(nextDate.getDate() + 1);

    const conflict = await Cita.findOne({
      doctorId,
      fecha: { $gte: targetDate, $lt: nextDate },
      horaInicio,
      estado: { $in: ['programada', 'pendiente', 'confirmada'] }
    });

    if (conflict) return res.status(409).json({ error: 'Time Slot Unavailable', message: 'The selected time slot is already booked' });

    const cita = new Cita({
      pacienteId,
      doctorId,
      tratamientoId: tratamientoId || null,
      fecha: new Date(fecha),
      horaInicio,
      horaFin: horaFin || horaInicio,
      estado: 'programada',
      motivo: motivo || null,
      notas: notas || null
    });

    await cita.save();
    try {
          const pacienteInfo = await Usuario.findById(pacienteId);
          const doctorInfo = await Usuario.findById(doctorId);

          if (pacienteInfo && doctorInfo) {
            const fechaBonita = new Date(fecha).toLocaleDateString('es-ES', {
               weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
            });

            console.log(`📧 Enviando correo a: ${pacienteInfo.email}`);

            enviarCorreoCita(
              pacienteInfo.email,
              pacienteInfo.nombre,
              fechaBonita,
              horaInicio,
              doctorInfo.nombre
            );
          }
        } catch (emailError) {
          console.error("⚠️ Error intentando enviar correo (no crítico):", emailError);
        }
    const pacienteFull = await Usuario.findById(pacienteId);
        const doctorFull = await Usuario.findById(doctorId);

        if (pacienteFull && doctorFull) {
            const fechaStr = new Date(fecha).toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

            enviarCorreoCita(pacienteFull.email, pacienteFull.nombre, fechaStr, horaInicio, doctorFull.nombre);
        }

    // Populate doctor and treatment for response
    await cita.populate('tratamientoId', 'nombre');
    await cita.populate('doctorId', 'nombre');

    res.status(201).json({
      message: 'Appointment scheduled successfully',
      cita: {
        id: cita._id,
        fecha: cita.fecha,
        horaInicio: cita.horaInicio,
        estado: cita.estado,
        tratamiento: cita.tratamientoId ? { id: cita.tratamientoId._id, nombre: cita.tratamientoId.nombre } : null,
        doctor: cita.doctorId ? { id: cita.doctorId._id, nombre: cita.doctorId.nombre } : null,
        creado_en: cita.createdAt
      }
    });

  } catch (error) {
    console.error('Schedule appointment error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to schedule appointment' });
  }
};

router.post('/', auth, validate(schemas.createCita), createCitaHandler);

// Alias route for modal/form submissions
router.post('/modal', auth, validate(schemas.createCita), createCitaHandler);


// PUT /api/citas/:id/reprogramar - Reschedule appointment
router.put('/:id/reprogramar', auth, async (req, res) => {
  try {
    const citaId = req.params.id;
    const { fecha, hora } = req.body;

    if (!fecha || !hora) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'New date and time are required'
      });
    }

    // Get existing appointment
    const cita = await Cita.findById(citaId);

    if (!cita) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Appointment not found'
      });
    }

    // Check permissions (only owner or doctor can reschedule)
    if (req.usuario.id !== cita.pacienteId.toString() && req.usuario.rol !== 'doctor') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only reschedule your own appointments'
      });
    }

    // Check if appointment can be rescheduled
    if (cita.estado === 'completada' || cita.estado === 'cancelada') {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Cannot reschedule completed or cancelled appointments'
      });
    }

    // Check if new time slot is available
    const conflictCheck = await Cita.findOne({
      _id: { $ne: citaId },
      fecha: new Date(fecha),
      horaInicio: hora,
      estado: { $in: ['pendiente', 'confirmada'] }
    });

    if (conflictCheck) {
      return res.status(409).json({
        error: 'Time Slot Unavailable',
        message: 'The selected time slot is already booked'
      });
    }

    // Update appointment
    cita.fecha = new Date(fecha);
    cita.horaInicio = hora;
    await cita.save();

    res.json({
      message: 'Appointment rescheduled successfully',
      cita: {
        id: cita._id,
        fecha: cita.fecha,
        horaInicio: cita.horaInicio,
        estado: cita.estado
      }
    });

  } catch (error) {
    console.error('Reschedule appointment error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to reschedule appointment'
    });
  }
});


// DELETE /api/citas/:id/cancelar - Cancel appointment
router.delete('/:id/cancelar', auth, async (req, res) => {
  try {
    const citaId = req.params.id;

    // Get existing appointment
    const cita = await Cita.findById(citaId);

    if (!cita) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Appointment not found'
      });
    }


    if (req.usuario.id !== cita.pacienteId.toString() &&
        req.usuario.rol !== 'doctor' &&
        req.usuario.rol !== 'admin') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only cancel your own appointments'
      });
    }

    if (cita.estado === 'completada' || cita.estado === 'cancelada') {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Cannot cancel completed or already cancelled appointments'
      });
    }

    cita.estado = 'cancelada';
    await cita.save();

    res.json({
      message: 'Appointment cancelled successfully',
      cita_id: citaId
    });

  } catch (error) {
    console.error('Cancel appointment error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to cancel appointment'
    });
  }
});


router.get('/historial/:id_usuario', auth, async (req, res) => {
  try {
    const userId = req.params.id_usuario;


    if (req.usuario.id !== userId && req.usuario.rol !== 'doctor') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only view your own appointment history'
      });
    }

    const citas = await Cita.find({ pacienteId: userId })
      .populate('tratamientoId', 'nombre')
      .populate('pacienteId', 'nombre')
      .populate('doctorId', 'nombre')
      .sort({ fecha: -1, horaInicio: -1 });

    const result = citas.map(cita => ({
      id: cita._id,
      fecha: cita.fecha,
      horaInicio: cita.horaInicio,
      estado: cita.estado,
      tratamiento: {
        id: cita.tratamientoId?._id,
        nombre: cita.tratamientoId?.nombre
      },
      paciente_nombre: cita.pacienteId?.nombre,
      creado_en: cita.createdAt
    }));

    res.json({
      user_id: userId,
      citas: result
    });

  } catch (error) {
    console.error('Get appointment history error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get appointment history'
    });
  }
});


// GET /api/citas/agenda/doctor/:id_doctor - Get doctor's complete schedule
router.get('/agenda/doctor/:id_doctor', auth, requireDoctor, async (req, res) => {
  try {
    const doctorId = req.params.id_doctor;
    const { fecha_inicio, fecha_fin } = req.query;

    // Build date filter
    let dateFilter = {};

    if (fecha_inicio && fecha_fin) {
      dateFilter.fecha = {
        $gte: new Date(fecha_inicio),
        $lte: new Date(fecha_fin)
      };
    } else if (fecha_inicio) {
      dateFilter.fecha = { $gte: new Date(fecha_inicio) };
    } else {
      // Default to next 30 days
      const today = new Date();
      const thirtyDaysLater = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);
      dateFilter.fecha = {
        $gte: today,
        $lte: thirtyDaysLater
      };
    }

    const citas = await Cita.find(dateFilter)
      .populate('tratamientoId', 'nombre')
      .populate('pacienteId', 'nombre telefono')
      .sort({ fecha: 1, horaInicio: 1 });

    const agenda = citas.map(cita => ({
      id: cita._id,
      fecha: cita.fecha,
      horaInicio: cita.horaInicio,
      estado: cita.estado,
      tratamiento: {
        id: cita.tratamientoId?._id,
        nombre: cita.tratamientoId?.nombre
      },
      paciente: {
        nombre: cita.pacienteId?.nombre,
        telefono: cita.pacienteId?.telefono
      },
      creado_en: cita.createdAt
    }));

    res.json({
      doctor_id: doctorId,
      fecha_inicio: fecha_inicio || dateFilter.fecha?.$gte?.toISOString().split('T')[0],
      fecha_fin: fecha_fin || dateFilter.fecha?.$lte?.toISOString().split('T')[0],
      total_citas: agenda.length,
      agenda
    });

  } catch (error) {
    console.error('Get doctor agenda error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get doctor agenda'
    });
  }
});

module.exports = router;