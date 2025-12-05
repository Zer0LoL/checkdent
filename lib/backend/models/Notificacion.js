const mongoose = require('mongoose');

const notificacionSchema = new mongoose.Schema({
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El ID del usuario es requerido']
  },
  citaId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Cita',
    default: null
  },
  tipo: {
    type: String,
    enum: ['recordatorio', 'confirmación', 'cancelación', 'urgente', 'general'],
    default: 'general'
  },
  titulo: {
    type: String,
    required: [true, 'El título es requerido']
  },
  mensaje: {
    type: String,
    required: [true, 'El mensaje es requerido']
  },
  leida: {
    type: Boolean,
    default: false
  },
  enviada: {
    type: Boolean,
    default: false
  },
  fechaEnvio: {
    type: Date,
    default: null
  },
  fechaLectura: {
    type: Date,
    default: null
  },
  canal: {
    type: String,
    enum: ['email', 'sms', 'push', 'app'],
    default: 'app'
  },
  prioridad: {
    type: String,
    enum: ['baja', 'media', 'alta'],
    default: 'media'
  },
  datos: {
    type: mongoose.Schema.Types.Mixed,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Índices
notificacionSchema.index({ usuarioId: 1, createdAt: -1 });
notificacionSchema.index({ leida: 1 });
notificacionSchema.index({ tipo: 1 });

module.exports = mongoose.model('Notificacion', notificacionSchema);
