const express = require('express');
const { auth, requireDoctor } = require('../middleware/auth');
const { schemas, validate } = require('../middleware/validation');
const Notificacion = require('../models/Notificacion');
const Cita = require('../models/Cita');
const Usuario = require('../models/Usuario');

const router = express.Router();

// POST /api/notificaciones/enviar - Send notification/reminder
router.post('/enviar', auth, requireDoctor, validate(schemas.createNotificacion), async (req, res) => {
  try {
    const { id_usuario, tipo, mensaje } = req.validatedBody;

    // Verify target user exists
    const targetUser = await Usuario.findById(id_usuario);

    if (!targetUser) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Target user not found'
      });
    }

    // Create notification in database
    const notificacion = new Notificacion({
      usuarioId: id_usuario,
      tipo: tipo || 'general',
      titulo: tipo || 'Notificación',
      mensaje,
      leida: false,
      enviada: true,
      canal: 'in-app'
    });

    await notificacion.save();

    res.status(201).json({
      message: 'Notification sent successfully',
      notificacion: {
        id: notificacion._id,
        id_usuario: id_usuario,
        tipo: tipo || 'general',
        mensaje,
        fecha_envio: notificacion.createdAt,
        destinatario: {
          nombre: targetUser.nombre,
          email: targetUser.email
        }
      }
    });

  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to send notification'
    });
  }
});

// GET /api/notificaciones/:id_usuario - Get user's notifications
router.get('/:id_usuario', auth, async (req, res) => {
  try {
    const userId = req.params.id_usuario;

    // Check permissions (only own notifications or doctor can see all)
    if (req.user.id !== userId && req.user.rol !== 'doctor') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only view your own notifications'
      });
    }

    const { limit = 20, offset = 0, tipo } = req.query;

    // Build query with optional filters
    let filter = { usuarioId: userId };
    if (tipo) {
      filter.tipo = tipo;
    }

    const notificaciones = await Notificacion.find(filter)
      .sort({ createdAt: -1 })
      .skip(parseInt(offset))
      .limit(parseInt(limit));

    const total = await Notificacion.countDocuments(filter);

    const result = notificaciones.map(notif => ({
      id: notif._id,
      tipo: notif.tipo,
      titulo: notif.titulo,
      mensaje: notif.mensaje,
      leida: notif.leida,
      fecha_envio: notif.createdAt
    }));

    res.json({
      user_id: userId,
      total,
      limit: parseInt(limit),
      offset: parseInt(offset),
      notificaciones: result
    });

  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get notifications'
    });
  }
});

// GET /api/notificaciones - Get all notifications (Doctor only)
router.get('/', auth, requireDoctor, async (req, res) => {
  try {
    const { limit = 50, offset = 0, tipo, fecha_desde, fecha_hasta } = req.query;

    // Build query with optional filters
    let filter = {};

    if (tipo) {
      filter.tipo = tipo;
    }

    if (fecha_desde || fecha_hasta) {
      filter.createdAt = {};
      if (fecha_desde) filter.createdAt.$gte = new Date(fecha_desde);
      if (fecha_hasta) filter.createdAt.$lte = new Date(fecha_hasta);
    }

    const notificaciones = await Notificacion.find(filter)
      .populate('usuarioId', 'nombre email')
      .sort({ createdAt: -1 })
      .skip(parseInt(offset))
      .limit(parseInt(limit));

    const total = await Notificacion.countDocuments(filter);

    const result = notificaciones.map(notif => ({
      id: notif._id,
      id_usuario: notif.usuarioId?._id,
      tipo: notif.tipo,
      titulo: notif.titulo,
      mensaje: notif.mensaje,
      fecha_envio: notif.createdAt,
      destinatario: {
        nombre: notif.usuarioId?.nombre,
        email: notif.usuarioId?.email
      }
    }));

    res.json({
      total,
      limit: parseInt(limit),
      offset: parseInt(offset),
      filters: {
        tipo: tipo || null,
        fecha_desde: fecha_desde || null,
        fecha_hasta: fecha_hasta || null
      },
      notificaciones: result
    });

  } catch (error) {
    console.error('Get all notifications error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get notifications'
    });
  }
});

// POST /api/notificaciones/recordatorio-cita - Send appointment reminder
router.post('/recordatorio-cita', auth, requireDoctor, async (req, res) => {
  try {
    const { cita_id, mensaje_personalizado } = req.body;

    if (!cita_id) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Appointment ID is required'
      });
    }

    // Get appointment details
    const cita = await Cita.findById(cita_id)
      .populate('tratamientoId', 'nombre')
      .populate('pacienteId', 'nombre email');

    if (!cita || !['pendiente', 'confirmada'].includes(cita.estado)) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Active appointment not found'
      });
    }

    // Create reminder message
    const defaultMessage = `Recordatorio: Tienes una cita programada para ${cita.tratamientoId?.nombre || 'tu cita'} el ${cita.fecha.toISOString().split('T')[0]} a las ${cita.horaInicio}.`;
    const mensaje = mensaje_personalizado || defaultMessage;

    // Create notification
    const notificacion = new Notificacion({
      usuarioId: cita.pacienteId._id,
      citaId: cita_id,
      tipo: 'recordatorio_cita',
      titulo: 'Recordatorio de Cita',
      mensaje,
      leida: false,
      enviada: true,
      canal: 'in-app'
    });

    await notificacion.save();

    res.status(201).json({
      message: 'Appointment reminder sent successfully',
      notificacion: {
        id: notificacion._id,
        cita_id: cita._id,
        id_usuario: cita.pacienteId._id,
        tipo: 'recordatorio_cita',
        mensaje,
        fecha_envio: notificacion.createdAt,
        destinatario: {
          nombre: cita.pacienteId.nombre,
          email: cita.pacienteId.email
        }
      }
    });

  } catch (error) {
    console.error('Send appointment reminder error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to send appointment reminder'
    });
  }
});

// DELETE /api/notificaciones/:id - Delete notification (Doctor only)
router.delete('/:id', auth, requireDoctor, async (req, res) => {
  try {
    const notificationId = req.params.id;

    // Check if notification exists
    const notificacion = await Notificacion.findById(notificationId);

    if (!notificacion) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Notification not found'
      });
    }

    // Delete notification
    await Notificacion.findByIdAndDelete(notificationId);

    res.json({
      message: 'Notification deleted successfully',
      deleted_notification_id: notificationId
    });

  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to delete notification'
    });
  }
});

module.exports = router;