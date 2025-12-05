const Usuario = require('../models/Usuario');

// Simplified auth middleware: removes JWT dependency.
// It attempts to read user info from headers `x-user-id` and `x-user-rol`.
// If not provided, sets a guest user (rol: 'guest').
const auth = async (req, res, next) => {
  try {
    const userId = req.header('x-user-id') || null;
    const userRol = req.header('x-user-rol') || 'guest';

    // Optional: if userId provided, try to load basic user info
    if (userId) {
      try {
        const usuario = await Usuario.findById(userId).select('nombre email rol');
        if (usuario) {
          req.usuario = { id: usuario._id.toString(), email: usuario.email, rol: usuario.rol };
          return next();
        }
      } catch (e) {
        // ignore and fallback to header-provided role
      }
    }

    // Fallback: set user from header role (or guest)
    req.usuario = { id: userId, rol: userRol };
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Error interno del servidor'
      }
    });
  }
};

const requireDoctor = (req, res, next) => {
  if (!req.usuario || req.usuario.rol !== 'doctor') {
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Solo los doctores pueden acceder a este recurso' }
    });
  }
  next();
};

const requirePatient = (req, res, next) => {
  if (!req.usuario || req.usuario.rol !== 'paciente') {
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Solo los pacientes pueden acceder a este recurso' }
    });
  }
  next();
};

const requireAdmin = (req, res, next) => {
  if (!req.usuario || req.usuario.rol !== 'admin') {
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Solo los administradores pueden acceder a este recurso' }
    });
  }
  next();
};

module.exports = {
  auth,
  requireDoctor,
  requirePatient,
  requireAdmin
};