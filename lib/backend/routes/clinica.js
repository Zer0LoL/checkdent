const express = require('express');
const router = express.Router();

// GET /api/clinica/info - basic clinic info for frontend
router.get('/info', async (req, res) => {
  try {
    // Static info for now; can be moved to DB or env
    const info = {
      nombre: process.env.CLINICA_NOMBRE || 'Clínica Sonrisa',
      direccion: process.env.CLINICA_DIRECCION || 'Av. Los Olivos 123, Lima',
      telefono: process.env.CLINICA_TELEFONO || '+51 987 654 321',
      horario: {
        inicio: process.env.CLINICA_HORARIO_INICIO || '08:00',
        fin: process.env.CLINICA_HORARIO_FIN || '18:00',
        dias: ['lunes','martes','miércoles','jueves','viernes']
      },
      ubicacion: {
        lat: process.env.CLINICA_LAT || -12.046374,
        lng: process.env.CLINICA_LNG || -77.042793
      }
    };

    res.json({ success: true, info });
  } catch (error) {
    console.error('Clinica info error:', error);
    res.status(500).json({ success: false, message: 'Failed to get clinic info' });
  }
});

module.exports = router;
