const mongoose = require('mongoose');

const citaSchema = new mongoose.Schema({
  pacienteId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El ID del paciente es requerido']
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El ID del doctor es requerido']
  },
  tratamientoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Tratamiento',
    default: null
  },
  fecha: {
    type: Date,
    required: [true, 'La fecha es requerida']
  },
  horaInicio: {
    type: String,
    required: [true, 'La hora de inicio es requerida']
  },
  horaFin: {
    type: String,
    required: [true, 'La hora de fin es requerida']
  },
  estado: {
    type: String,
    enum: ['programada', 'completada', 'cancelada', 'no-presentada'],
    default: 'programada'
  },
  motivo: {
    type: String,
    default: null
  },
  notas: {
    type: String,
    default: null
  },
  notificacionEnviada: {
    type: Boolean,
    default: false
  },
  duracion: {
    type: Number,
    default: 30
  },
  ubicacion: {
    type: String,
    default: 'Consultorio'
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

// Índices para búsquedas rápidas
citaSchema.index({ pacienteId: 1, fecha: 1 });
citaSchema.index({ doctorId: 1, fecha: 1 });
citaSchema.index({ fecha: 1 });

module.exports = mongoose.model('Cita', citaSchema);
