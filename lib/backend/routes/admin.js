const express = require('express');
const { auth, requireAdmin } = require('../middleware/auth');
const Cita = require('../models/Cita');
const Usuario = require('../models/Usuario');
const Tratamiento = require('../models/Tratamiento');
const Notificacion = require('../models/Notificacion');

const router = express.Router();


router.get('/citas/pendientes', auth, requireAdmin, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const citas = await Cita.find({
      fecha: { $gte: today },
      estado: { $in: ['pendiente', 'programada', 'confirmada'] }
    })
      .populate('tratamientoId', 'nombre')
      .populate('pacienteId', 'nombre email telefono')
      .populate('doctorId', 'nombre')
      .sort({ fecha: 1, horaInicio: 1 });

    const result = citas.map(cita => ({
      id: cita._id,
      fecha: cita.fecha,
      horaInicio: cita.horaInicio,
      estado: cita.estado,
      paciente: {
        nombre: cita.pacienteId?.nombre || 'Desconocido',
        email: cita.pacienteId?.email,
        telefono: cita.pacienteId?.telefono
      },
      doctor: cita.doctorId?.nombre || 'General',
      tratamiento: cita.tratamientoId?.nombre || 'Consulta'
    }));

    res.json({ citas: result });

  } catch (error) {
    console.error('Error getting pending appointments:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// GET /api/admin/citas/hoy - Citas de hoy (Agenda Global)
router.get('/citas/hoy', auth, requireAdmin, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const citas = await Cita.find({
      fecha: { $gte: today, $lt: tomorrow },
      estado: { $in: ['pendiente', 'programada', 'confirmada', 'completada'] }
    })
      .populate('tratamientoId', 'nombre descripcion')
      .populate('pacienteId', 'nombre email telefono')
      .sort({ horaInicio: 1 });

    const citasHoy = citas.map(cita => ({
      id: cita._id,
      horaInicio: cita.horaInicio,
      estado: cita.estado,
      tratamiento: {
        id: cita.tratamientoId?._id,
        nombre: cita.tratamientoId?.nombre,
      },
      paciente: {
        nombre: cita.pacienteId?.nombre,
        telefono: cita.pacienteId?.telefono
      },
      creado_en: cita.createdAt
    }));

    res.json({
      fecha: today.toISOString().split('T')[0],
      citas: citasHoy
    });

  } catch (error) {
    console.error('Get today appointments error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// GET /api/admin/dashboard - Estadísticas
router.get('/dashboard', auth, requireAdmin, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
    endOfMonth.setHours(23, 59, 59, 999);

    // Stats Hoy
    const todayCitas = await Cita.find({ fecha: { $gte: today, $lt: tomorrow } });
    const todayStats = {
      total: todayCitas.length,
      pendientes: todayCitas.filter(c => ['pendiente', 'programada'].includes(c.estado)).length,
      confirmadas: todayCitas.filter(c => c.estado === 'confirmada').length,
      completadas: todayCitas.filter(c => c.estado === 'completada').length
    };

    // Stats Mes
    const monthlyCitas = await Cita.find({ fecha: { $gte: startOfMonth, $lte: endOfMonth } });
    const monthlyStats = {
      total: monthlyCitas.length,
      completadas: monthlyCitas.filter(c => c.estado === 'completada').length
    };

    // Totales
    const totalPatients = await Usuario.countDocuments({ rol: 'paciente' });

    // Tratamientos Populares
    const treatmentStats = await Cita.aggregate([
      { $group: { _id: '$tratamientoId', total: { $sum: 1 } } },
      { $sort: { total: -1 } },
      { $limit: 3 },
      { $lookup: { from: 'tratamientos', localField: '_id', foreignField: '_id', as: 'tratamiento' } }
    ]);

    const dashboard = {
      hoy: todayStats,
      mes_actual: monthlyStats,
      pacientes_totales: totalPatients,
      tratamientos_populares: treatmentStats.map(t => ({
        nombre: t.tratamiento[0]?.nombre || 'General',
        total_citas: t.total
      })),
    };

    res.json({ dashboard });

  } catch (error) {
    console.error('Get dashboard error:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

module.exports = router;