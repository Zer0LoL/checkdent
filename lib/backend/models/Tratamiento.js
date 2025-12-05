const mongoose = require('mongoose');

const tratamientoSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre del tratamiento es requerido'],
    unique: true,
    trim: true
  },
  descripcion: {
    type: String,
    default: null
  },
  duracionPromedio: {
    type: Number,
    default: 30,
    required: [true, 'La duración promedio es requerida']
  },
  costo: {
    type: Number,
    required: [true, 'El costo es requerido'],
    min: 0
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El ID del doctor es requerido']
  },
  categoria: {
    type: String,
    enum: ['limpieza', 'extracción', 'endodoncia', 'ortodoncia', 'periodoncia', 'prótesis', 'estética', 'otro'],
    default: 'otro'
  },
  activo: {
    type: Boolean,
    default: true
  },
  materiales: [{
    nombre: String,
    cantidad: Number,
    unidad: String
  }],
  complicaciones: [{
    tipo: String,
    probabilidad: String,
    descripcion: String
  }],
  precauciones: [String],
  notas: String,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Índices
// `nombre` ya tiene `unique: true` declarado en el campo, lo que crea un índice automáticamente.
// Evitamos declarar el mismo índice dos veces para prevenir warnings de mongoose.
tratamientoSchema.index({ doctorId: 1 });
tratamientoSchema.index({ categoria: 1 });

module.exports = mongoose.model('Tratamiento', tratamientoSchema);
