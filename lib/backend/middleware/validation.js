const Joi = require('joi');

// Validation schemas
const schemas = {
  // User registration validation
  registerUser: Joi.object({
    nombre: Joi.string().min(2).max(100).required(),
    email: Joi.string().email().max(120).required(),
    password: Joi.string().min(6).max(100).required(),
    rol: Joi.string().valid('paciente', 'doctor', 'admin').default('paciente'),
    telefono: Joi.string().pattern(/^[0-9+\-\s()]+$/).min(10).max(20),
    especialidad: Joi.when('rol', { is: 'doctor', then: Joi.string().required() })
  }),

  // User login validation
  loginUser: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),

  // Update user validation
  updateUser: Joi.object({
    nombre: Joi.string().min(2).max(100),
    telefono: Joi.string().pattern(/^[0-9+\-\s()]+$/).min(10).max(20),
    direccion: Joi.string().max(200),
    especialidad: Joi.string().max(100),
    foto: Joi.string()
  }),

  // Appointment validation
  createCita: Joi.object({
    pacienteId: Joi.string().required(),
    doctorId: Joi.string().required(),
    tratamientoId: Joi.string().allow(null),
    fecha: Joi.date().iso().required(),
    horaInicio: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
    horaFin: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).required(),
    motivo: Joi.string().max(500),
    notas: Joi.string().max(1000)
  }),

  // Update appointment validation
  updateCita: Joi.object({
    fecha: Joi.date().iso(),
    horaInicio: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/),
    horaFin: Joi.string().pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/),
    estado: Joi.string().valid('programada', 'completada', 'cancelada', 'no-presentada'),
    motivo: Joi.string().max(500),
    notas: Joi.string().max(1000)
  }),

  // Treatment validation
  createTratamiento: Joi.object({
    nombre: Joi.string().min(2).max(100).required(),
    descripcion: Joi.string().max(1000),
    duracionPromedio: Joi.number().integer().min(5).default(30),
    costo: Joi.number().positive().required(),
    categoria: Joi.string().valid('limpieza', 'extracción', 'endodoncia', 'ortodoncia', 'periodoncia', 'prótesis', 'estética', 'otro'),
    precauciones: Joi.array().items(Joi.string())
  }),

  // Notification validation
  createNotificacion: Joi.object({
    id_usuario: Joi.number().integer().positive().required(),
    tipo: Joi.string().max(50),
    mensaje: Joi.string().max(1000).required()
  }),

  // Calendar event validation
  calendarEvent: Joi.object({
    title: Joi.string().required(),
    description: Joi.string(),
    startDateTime: Joi.date().iso().required(),
    endDateTime: Joi.date().iso().required(),
    attendeeEmail: Joi.string().email()
  })
};

// Validation middleware factory
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errorDetails = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        error: 'Validation Error',
        message: 'Invalid input data',
        details: errorDetails
      });
    }

    req.validatedBody = value;
    next();
  };
};

module.exports = {
  schemas,
  validate
};