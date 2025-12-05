const express = require('express');
const { auth, requireDoctor } = require('../middleware/auth');
const { schemas, validate } = require('../middleware/validation');
const Cita = require('../models/Cita');
const Usuario = require('../models/Usuario');

const router = express.Router();

// All calendar functionality now persists events as `Cita` documents in MongoDB.

// GET /api/calendar/disponibilidad - Get availability from DB only
router.get('/disponibilidad', auth, async (req, res) => {
  try {
    const { fecha, id_doctor } = req.query;

    if (!fecha) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Date parameter is required'
      });
    }

    // Resolve doctorId
    let doctorId = id_doctor;
    if (!doctorId) {
      const doctor = await Usuario.findOne({ rol: 'doctor' });
      if (!doctor) {
        return res.status(404).json({ error: 'Not Found', message: 'No doctor available' });
      }
      doctorId = doctor._id;
    }

    // Normalize date (only date portion)
    const targetDate = new Date(fecha);
    targetDate.setHours(0,0,0,0);

    const nextDate = new Date(targetDate);
    nextDate.setDate(nextDate.getDate() + 1);

    // Query appointments for that doctor and date
    const citas = await Cita.find({
      doctorId,
      fecha: { $gte: targetDate, $lt: nextDate },
      estado: { $in: ['programada'] }
    });

    // Generate working hours (9:00 - 17:00, 1-hour slots)
    const workingHours = [];
    for (let hour = 9; hour < 18; hour++) {
      workingHours.push(`${hour.toString().padStart(2, '0')}:00`);
    }

    const bookedHours = citas.map(cita => {
      // horaInicio is stored as string like '09:00'
      return cita.horaInicio.substring(0,5);
    });

    const availableHours = workingHours.filter(h => !bookedHours.includes(h));

    res.json({
      fecha: targetDate.toISOString().split('T')[0],
      doctorId,
      available_slots: availableHours,
      booked_slots: bookedHours,
      total_booked: bookedHours.length
    });

  } catch (error) {
    console.error('Get calendar availability error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to get calendar availability' });
  }
});

// POST /api/calendar/evento - Create calendar event persisted as a Cita
router.post('/evento', auth, validate(schemas.calendarEvent), async (req, res) => {
  try {
    const { pacienteId, doctorId, fecha, horaInicio, horaFin, tratamientoId, motivo, notas } = req.validatedBody;

    // Only allow patients to create for themselves or doctors to create for patients
    if (req.usuario.rol === 'paciente' && req.usuario.id !== pacienteId) {
      return res.status(403).json({ error: 'Forbidden', message: 'Patients can only create events for themselves' });
    }

    // Validate doctor and patient exist
    const [paciente, doctor] = await Promise.all([
      Usuario.findById(pacienteId),
      Usuario.findById(doctorId)
    ]);

    if (!paciente) return res.status(404).json({ error: 'Not Found', message: 'Paciente no encontrado' });
    if (!doctor) return res.status(404).json({ error: 'Not Found', message: 'Doctor no encontrado' });

    // Check for time conflict for the doctor
    const targetDate = new Date(fecha);
    targetDate.setHours(0,0,0,0);
    const nextDate = new Date(targetDate);
    nextDate.setDate(nextDate.getDate() + 1);

    const conflict = await Cita.findOne({
      doctorId,
      fecha: { $gte: targetDate, $lt: nextDate },
      horaInicio: horaInicio,
      estado: { $in: ['programada'] }
    });

    if (conflict) {
      return res.status(409).json({ error: 'Conflict', message: 'Time slot already booked for this doctor' });
    }

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

    res.status(201).json({ message: 'Evento creado como cita', cita });

  } catch (error) {
    console.error('Create calendar event error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to create event' });
  }
});

// PUT /api/calendar/evento/:id - Update (reschedule) a Cita
router.put('/evento/:id', auth, async (req, res) => {
  try {
    const citaId = req.params.id;
    const { fecha, horaInicio, horaFin, motivo, notas } = req.body;

    const cita = await Cita.findById(citaId);
    if (!cita) return res.status(404).json({ error: 'Not Found', message: 'Cita no encontrada' });

    // Permission: owner patient or doctor
    if (req.usuario.id !== cita.pacienteId.toString() && req.usuario.rol !== 'doctor') {
      return res.status(403).json({ error: 'Forbidden', message: 'No tienes permiso para modificar esta cita' });
    }

    // If changing date/time, check conflicts
    if (fecha || horaInicio) {
      const newFecha = fecha ? new Date(fecha) : cita.fecha;
      newFecha.setHours(0,0,0,0);
      const nextDate = new Date(newFecha);
      nextDate.setDate(nextDate.getDate() + 1);

      const conflict = await Cita.findOne({
        _id: { $ne: citaId },
        doctorId: cita.doctorId,
        fecha: { $gte: newFecha, $lt: nextDate },
        horaInicio: horaInicio || cita.horaInicio,
        estado: { $in: ['programada'] }
      });

      if (conflict) return res.status(409).json({ error: 'Conflict', message: 'El nuevo horario ya está reservado' });

      if (fecha) cita.fecha = new Date(fecha);
      if (horaInicio) cita.horaInicio = horaInicio;
      if (horaFin) cita.horaFin = horaFin;
    }

    if (motivo !== undefined) cita.motivo = motivo;
    if (notas !== undefined) cita.notas = notas;

    await cita.save();

    res.json({ message: 'Cita actualizada', cita });

  } catch (error) {
    console.error('Update calendar event error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to update event' });
  }
});

// DELETE /api/calendar/evento/:id - Cancel a Cita
router.delete('/evento/:id', auth, async (req, res) => {
  try {
    const citaId = req.params.id;

    const cita = await Cita.findById(citaId);
    if (!cita) return res.status(404).json({ error: 'Not Found', message: 'Cita no encontrada' });

    // Permission: owner patient or doctor
    if (req.usuario.id !== cita.pacienteId.toString() && req.usuario.rol !== 'doctor') {
      return res.status(403).json({ error: 'Forbidden', message: 'No tienes permiso para cancelar esta cita' });
    }

    // Mark as cancelled
    cita.estado = 'cancelada';
    await cita.save();

    res.json({ message: 'Cita cancelada', citaId });

  } catch (error) {
    console.error('Delete calendar event error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to cancel event' });
  }
});

module.exports = router;

// PUT /api/calendar/evento/:id - Update calendar event when appointment is rescheduled
router.put('/evento/:id', auth, async (req, res) => {
  try {
    const eventId = req.params.id;
    const { title, description, startDateTime, endDateTime } = req.body;

    if (req.user.rol !== 'doctor') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Only doctors can update calendar events'
      });
    }

    if (!startDateTime || !endDateTime) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Start and end date times are required'
      });
    }

    try {
      const oauth2Client = getOAuth2Client();
      setCredentials(oauth2Client);

      // First, get the existing event
      const existingEvent = await calendar.events.get({
        auth: oauth2Client,
        calendarId: 'primary',
        eventId: eventId,
      });

      // Update the event
      const updatedEventData = {
        ...existingEvent.data,
        summary: title || existingEvent.data.summary,
        description: description || existingEvent.data.description,
        start: {
          dateTime: startDateTime,
          timeZone: 'America/Mexico_City',
        },
        end: {
          dateTime: endDateTime,
          timeZone: 'America/Mexico_City',
        },
      };

      const response = await calendar.events.update({
        auth: oauth2Client,
        calendarId: 'primary',
        eventId: eventId,
        resource: updatedEventData,
        sendUpdates: 'all',
      });

      const updatedEvent = response.data;

      res.json({
        message: 'Calendar event updated successfully',
        event: {
          id: updatedEvent.id,
          title: updatedEvent.summary,
          description: updatedEvent.description,
          start: updatedEvent.start,
          end: updatedEvent.end,
          htmlLink: updatedEvent.htmlLink
        }
      });

    } catch (googleError) {
      console.error('Google Calendar update event error:', googleError);
      
      if (googleError.code === 404) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'Calendar event not found'
        });
      }

      res.status(503).json({
        error: 'Service Unavailable',
        message: 'Google Calendar service is currently unavailable'
      });
    }

  } catch (error) {
    console.error('Update calendar event error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to update calendar event'
    });
  }
});

// DELETE /api/calendar/evento/:id - Delete calendar event when appointment is cancelled
router.delete('/evento/:id', auth, async (req, res) => {
  try {
    const eventId = req.params.id;

    if (req.user.rol !== 'doctor') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Only doctors can delete calendar events'
      });
    }

    try {
      const oauth2Client = getOAuth2Client();
      setCredentials(oauth2Client);

      await calendar.events.delete({
        auth: oauth2Client,
        calendarId: 'primary',
        eventId: eventId,
        sendUpdates: 'all',
      });

      res.json({
        message: 'Calendar event deleted successfully',
        deleted_event_id: eventId
      });

    } catch (googleError) {
      console.error('Google Calendar delete event error:', googleError);
      
      if (googleError.code === 404) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'Calendar event not found'
        });
      }

      res.status(503).json({
        error: 'Service Unavailable',
        message: 'Google Calendar service is currently unavailable'
      });
    }

  } catch (error) {
    console.error('Delete calendar event error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to delete calendar event'
    });
  }
});

// GET /api/calendar/auth-url - Get Google OAuth2 authorization URL
router.get('/auth-url', auth, requireDoctor, (req, res) => {
  try {
    const oauth2Client = getOAuth2Client();
    
    const scopes = [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events'
    ];

    const authUrl = oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      prompt: 'consent'
    });

    res.json({
      auth_url: authUrl,
      message: 'Visit this URL to authorize the application to access your Google Calendar'
    });

  } catch (error) {
    console.error('Generate auth URL error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to generate authorization URL'
    });
  }
});

// POST /api/calendar/auth-callback - Handle OAuth2 callback
router.post('/auth-callback', auth, requireDoctor, async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Authorization code is required'
      });
    }

    const oauth2Client = getOAuth2Client();
    
    const { tokens } = await oauth2Client.getToken(code);
    
    // TODO: Store these tokens securely in database for the doctor
    // For now, we'll just return them
    
    res.json({
      message: 'Authorization successful',
      tokens: {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        expires_at: tokens.expiry_date
      },
      note: 'Store these tokens securely for Google Calendar integration'
    });

  } catch (error) {
    console.error('OAuth callback error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to process authorization'
    });
  }
});

module.exports = router;