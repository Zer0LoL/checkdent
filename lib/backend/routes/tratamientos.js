const express = require('express');
const { auth, requireDoctor } = require('../middleware/auth');
const { schemas, validate } = require('../middleware/validation');
const Tratamiento = require('../models/Tratamiento');
const Cita = require('../models/Cita');

const router = express.Router();

// GET /api/tratamientos - Get all available treatments
router.get('/', auth, async (req, res) => {
  try {
    const tratamientos = await Tratamiento.find().sort({ nombre: 1 });

    const result = tratamientos.map(t => ({
      id: t._id,
      nombre: t.nombre,
      descripcion: t.descripcion,
      duracionPromedio: t.duracionPromedio,
      costo: t.costo
    }));

    res.json({
      total: result.length,
      tratamientos: result
    });

  } catch (error) {
    console.error('Get treatments error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get treatments'
    });
  }
});

// GET /api/tratamientos/:id - Get specific treatment details
router.get('/:id', auth, async (req, res) => {
  try {
    const tratamientoId = req.params.id;

    const tratamiento = await Tratamiento.findById(tratamientoId);

    if (!tratamiento) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Treatment not found'
      });
    }

    // Get related appointments statistics (if user is doctor)
    let statistics = null;
    if (req.user.rol === 'doctor') {
      const citas = await Cita.find({ tratamientoId });
      
      statistics = {
        total_citas: citas.length,
        citas_completadas: citas.filter(c => c.estado === 'completada').length,
        citas_pendientes: citas.filter(c => c.estado === 'pendiente').length,
        citas_cancelada: citas.filter(c => c.estado === 'cancelada').length
      };
    }

    res.json({
      tratamiento: {
        id: tratamiento._id,
        nombre: tratamiento.nombre,
        descripcion: tratamiento.descripcion,
        duracionPromedio: tratamiento.duracionPromedio,
        costo: tratamiento.costo,
        categoria: tratamiento.categoria
      },
      ...(statistics && { statistics })
    });

  } catch (error) {
    console.error('Get treatment details error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to get treatment details'
    });
  }
});

// POST /api/tratamientos - Create new treatment (Doctor only)
router.post('/', auth, requireDoctor, validate(schemas.createTratamiento), async (req, res) => {
  try {
    const { nombre, descripcion, duracionPromedio, costo, categoria } = req.validatedBody;

    // Check if treatment with same name already exists
    const existingTreatment = await Tratamiento.findOne({ nombre });

    if (existingTreatment) {
      return res.status(409).json({
        error: 'Conflict',
        message: 'A treatment with this name already exists'
      });
    }

    // Create new treatment
    const tratamiento = new Tratamiento({
      nombre,
      descripcion: descripcion || '',
      duracionPromedio: duracionPromedio || 60,
      costo: costo || 0,
      categoria: categoria || 'general',
      doctorId: req.user.id
    });

    await tratamiento.save();

    res.status(201).json({
      message: 'Treatment created successfully',
      tratamiento: {
        id: tratamiento._id,
        nombre: tratamiento.nombre,
        descripcion: tratamiento.descripcion,
        duracionPromedio: tratamiento.duracionPromedio,
        costo: tratamiento.costo,
        categoria: tratamiento.categoria
      }
    });

  } catch (error) {
    console.error('Create treatment error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to create treatment'
    });
  }
});

// PUT /api/tratamientos/:id - Update treatment (Doctor only)
router.put('/:id', auth, requireDoctor, validate(schemas.createTratamiento), async (req, res) => {
  try {
    const tratamientoId = req.params.id;
    const { nombre, descripcion, duracionPromedio, costo, categoria } = req.validatedBody;

    // Check if treatment exists
    const tratamiento = await Tratamiento.findById(tratamientoId);

    if (!tratamiento) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Treatment not found'
      });
    }

    // Check if another treatment with same name exists (excluding current)
    if (nombre && nombre !== tratamiento.nombre) {
      const duplicateCheck = await Tratamiento.findOne({
        nombre,
        _id: { $ne: tratamientoId }
      });

      if (duplicateCheck) {
        return res.status(409).json({
          error: 'Conflict',
          message: 'A treatment with this name already exists'
        });
      }
    }

    // Update treatment
    if (nombre) tratamiento.nombre = nombre;
    if (descripcion) tratamiento.descripcion = descripcion;
    if (duracionPromedio) tratamiento.duracionPromedio = duracionPromedio;
    if (costo !== undefined) tratamiento.costo = costo;
    if (categoria) tratamiento.categoria = categoria;

    await tratamiento.save();

    res.json({
      message: 'Treatment updated successfully',
      tratamiento: {
        id: tratamiento._id,
        nombre: tratamiento.nombre,
        descripcion: tratamiento.descripcion,
        duracionPromedio: tratamiento.duracionPromedio,
        costo: tratamiento.costo,
        categoria: tratamiento.categoria
      }
    });

  } catch (error) {
    console.error('Update treatment error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to update treatment'
    });
  }
});

// DELETE /api/tratamientos/:id - Delete treatment (Doctor only)
router.delete('/:id', auth, requireDoctor, async (req, res) => {
  try {
    const tratamientoId = req.params.id;

    // Check if treatment exists
    const tratamiento = await Tratamiento.findById(tratamientoId);

    if (!tratamiento) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Treatment not found'
      });
    }

    // Check if treatment has associated appointments
    const appointmentCount = await Cita.countDocuments({ tratamientoId });

    if (appointmentCount > 0) {
      return res.status(409).json({
        error: 'Conflict',
        message: 'Cannot delete treatment with existing appointments. Consider disabling it instead.'
      });
    }

    // Delete treatment
    await Tratamiento.findByIdAndDelete(tratamientoId);

    res.json({
      message: 'Treatment deleted successfully',
      deleted_treatment: {
        id: tratamientoId,
        nombre: tratamiento.nombre
      }
    });

  } catch (error) {
    console.error('Delete treatment error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to delete treatment'
    });
  }
});

module.exports = router;