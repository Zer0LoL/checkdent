const mongoose = require('mongoose');

const consejoSchema = new mongoose.Schema({
  titulo: { type: String, required: true },
  descripcion: { type: String, required: true },
  autor: { type: String, default: 'Clínica' },
  creadoEn: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Consejo', consejoSchema);
