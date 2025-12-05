const express = require('express');
const router = express.Router();
const Usuario = require('../models/Usuario');
const { auth, requireDoctor, requirePatient, requireAdmin } = require('../middleware/auth');
const Joi = require('joi');
const multer = require('multer');

const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'checkdent_avatars',
    allowed_formats: ['jpg', 'png', 'jpeg'],
    transformation: [{ width: 500, height: 500, crop: 'limit' }]
  },
});

const upload = multer({ storage: storage });

const registerSchema = Joi.object({
  nombre: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  rol: Joi.string().valid('paciente', 'doctor', 'admin').default('paciente'),
  especialidad: Joi.string().when('rol', { is: 'doctor', then: Joi.string().required() })
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

const updateSchema = Joi.object({
  nombre: Joi.string().min(2).max(100),
  telefono: Joi.string(),
  direccion: Joi.string(),
  especialidad: Joi.string()
});


router.get('/doctores/disponibles', async (req, res, next) => {
  try {
    const doctores = await Usuario.find({ rol: 'doctor', estado: 'activo' });
    res.status(200).json({
      success: true,
      data: doctores
    });
  } catch (error) {
    next(error);
  }
});

router.get('/:id', auth, async (req, res, next) => {
  try {
    const usuario = await Usuario.findById(req.params.id).select('-password');
    if (!usuario) return res.status(404).json({ success: false, error: { code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' } });
    res.json({ success: true, data: usuario });
  } catch (error) {
    next(error);
  }
});

router.put('/:id/password', auth, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    if (!currentPassword || !newPassword) return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR', message: 'currentPassword y newPassword son requeridos' } });

    if (req.usuario.id !== req.params.id && req.usuario.rol !== 'admin') {
      return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'No tienes permisos para cambiar esta contraseña' } });
    }

    const usuario = await Usuario.findById(req.params.id).select('+password');
    if (!usuario) return res.status(404).json({ success: false, error: { code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' } });

    const esValida = await usuario.compararPassword(currentPassword);
    if (!esValida) return res.status(401).json({ success: false, error: { code: 'INVALID_CREDENTIALS', message: 'Contraseña actual incorrecta' } });

    usuario.password = newPassword;
    await usuario.save();

    res.json({ success: true, message: 'Contraseña actualizada correctamente' });
  } catch (error) {
    next(error);
  }
});

router.post('/:id/avatar', auth, upload.single('avatar'), async (req, res, next) => {
  try {
    if (req.usuario.id !== req.params.id && req.usuario.rol !== 'admin') {
      return res.status(403).json({ success: false, error: { code: 'FORBIDDEN', message: 'No tienes permisos para subir avatar de este usuario' } });
    }

    if (!req.file) {
      return res.status(400).json({ success: false, error: { code: 'NO_FILE', message: 'No se ha subido archivo' } });
    }

    const usuario = await Usuario.findById(req.params.id);
    if (!usuario) return res.status(404).json({ success: false, error: { code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' } });

    usuario.foto = req.file.path;
    await usuario.save();

    res.status(201).json({ success: true, message: 'Avatar subido', foto: usuario.foto });
  } catch (error) {
    next(error);
  }
});

router.post('/register', async (req, res, next) => {
  try {
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: error.details[0].message }
      });
    }

    const { nombre, email, password, rol, especialidad } = value;

    const usuarioExistente = await Usuario.findOne({ email });
    if (usuarioExistente) {
      return res.status(409).json({
        success: false,
        error: { code: 'DUPLICATE_EMAIL', message: 'El email ya está registrado' }
      });
    }

    const usuario = new Usuario({
      nombre,
      email,
      password,
      rol,
      ...(rol === 'doctor' && { especialidad })
    });

    await usuario.save();

    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente',
      data: {
        id: usuario._id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol
      }
    });
  } catch (error) {
    next(error);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: error.details[0].message }
      });
    }

    const { email, password } = value;

    const usuario = await Usuario.findOne({ email }).select('+password');
    if (!usuario) {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Email o contraseña incorrectos' }
      });
    }

    const esValida = await usuario.compararPassword(password);
    if (!esValida) {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_CREDENTIALS', message: 'Email o contraseña incorrectos' }
      });
    }

    res.status(200).json({
      success: true,
      message: 'Login exitoso',
      data: {
        id: usuario._id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol,
        foto: usuario.foto,
        telefono: usuario.telefono,
        direccion: usuario.direccion,
        especialidad: usuario.especialidad
      }
    });
  } catch (error) {
    next(error);
  }
});

// Obtener usuario actual
router.get('/me', auth, async (req, res, next) => {
  try {
    const usuario = await Usuario.findById(req.usuario.id);
    if (!usuario) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' }
      });
    }

    res.status(200).json({
      success: true,
      data: usuario
    });
  } catch (error) {
    next(error);
  }
});

// Obtener todos los usuarios (admin solo)
router.get('/', auth, async (req, res, next) => {
  try {
    if (req.usuario.rol !== 'admin') {
      return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Solo administradores pueden ver todos los usuarios' }
      });
    }

    const usuarios = await Usuario.find();
    res.status(200).json({
      success: true,
      data: usuarios
    });
  } catch (error) {
    next(error);
  }
});

// Actualizar perfil
router.put('/:id', auth, async (req, res, next) => {
  try {
    const { error, value } = updateSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: error.details[0].message }
      });
    }

    if (req.usuario.id !== req.params.id && req.usuario.rol !== 'admin') {
      return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'No tienes permisos para actualizar este perfil' }
      });
    }

    const usuario = await Usuario.findByIdAndUpdate(
      req.params.id,
      { ...value, updatedAt: new Date() },
      { new: true, runValidators: true }
    );

    if (!usuario) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' }
      });
    }

    res.status(200).json({
      success: true,
      message: 'Perfil actualizado exitosamente',
      data: usuario
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;