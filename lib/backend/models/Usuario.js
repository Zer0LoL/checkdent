const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const usuarioSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre es requerido'],
    trim: true,
    minlength: 2,
    maxlength: 100
  },
  email: {
    type: String,
    required: [true, 'El email es requerido'],
    unique: true,
    lowercase: true,
    match: [/.+@.+\..+/, 'Por favor proporciona un email válido']
  },
  password: {
    type: String,
    required: [true, 'La contraseña es requerida'],
    minlength: 6,
    select: false
  },
  rol: {
    type: String,
    enum: ['doctor', 'paciente', 'admin'],
    default: 'paciente'
  },
  especialidad: {
    type: String,
    default: null
  },
  telefono: {
    type: String,
    default: null
  },
  direccion: {
    type: String,
    default: null
  },
  estado: {
    type: String,
    enum: ['activo', 'inactivo', 'suspendido'],
    default: 'activo'
  },
  foto: {
    type: String,
    default: null
  },
  horarioInicio: {
    type: String,
    default: '08:00'
  },
  horarioFin: {
    type: String,
    default: '17:00'
  },
  diasAtencion: {
    type: [String],
    default: ['lunes', 'martes', 'miércoles', 'jueves', 'viernes']
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

usuarioSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

usuarioSchema.methods.compararPassword = async function(passwordIngresada) {
  return await bcrypt.compare(passwordIngresada, this.password);
};

usuarioSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('Usuario', usuarioSchema);
