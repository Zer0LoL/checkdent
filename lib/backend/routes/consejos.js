const express = require('express');
const { auth, requireAdmin } = require('../middleware/auth');
const Consejo = require('../models/Consejo');

const router = express.Router();

// GET /api/consejos - list consejos
router.get('/', async (req, res) => {
  try {
    const consejos = await Consejo.find().sort({ creadoEn: -1 }).limit(50);
    res.json({ total: consejos.length, consejos });
  } catch (error) {
    console.error('Get consejos error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to get consejos' });
  }
});

// POST /api/consejos - create consejo (admin)
router.post('/', auth, requireAdmin, async (req, res) => {
  try {
    const { titulo, descripcion, autor } = req.body;
    if (!titulo || !descripcion) return res.status(400).json({ error: 'Bad Request', message: 'titulo y descripcion son requeridos' });

    const consejo = new Consejo({ titulo, descripcion, autor });
    await consejo.save();

    res.status(201).json({ message: 'Consejo creado', consejo });
  } catch (error) {
    console.error('Create consejo error:', error);
    res.status(500).json({ error: 'Internal Server Error', message: 'Failed to create consejo' });
  }
});

module.exports = router;
