require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { iniciarRecordatorios } = require('./jobs/reminderService');

const { database } = require('./config/database');

// Import routes
const usuariosRoutes = require('./routes/usuarios');
const citasRoutes = require('./routes/citas');
const tratamientosRoutes = require('./routes/tratamientos');
const notificacionesRoutes = require('./routes/notificaciones');
const calendarRoutes = require('./routes/calendar');
const adminRoutes = require('./routes/admin');
const consejosRoutes = require('./routes/consejos');
const clinicaRoutes = require('./routes/clinica');

// Import middleware
const errorHandler = require('./middleware/errorHandler');
const auth = require('./middleware/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api', limiter);
app.use('/api/seed', require('./routes/seed'));
// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files (avatars, etc.)
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));

// CORS configuration - Mejorado para Flutter
app.use(cors({
  origin: function(origin, callback) {
    const allowedOrigins = [
      process.env.FRONTEND_URL || 'http://localhost:3000',
      'http://localhost:3000',
      'http://localhost:8080',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:8080'
    ];
    
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('CORS no permitido'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Number'],
  maxAge: 86400
}));

// Logging middleware
app.use(morgan('combined'));

// Health check endpoint with database status
app.get('/health', async (req, res) => {
  try {
    const dbStatus = await database.getConnectionStatus();
    
    res.status(dbStatus.connected ? 200 : 503).json({
      status: dbStatus.connected ? 'OK' : 'DEGRADED',
      message: 'CheckDent API',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      database: dbStatus,
      environment: process.env.NODE_ENV || 'development'
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: 'Health check failed',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Database connection check endpoint
app.get('/api/status', async (req, res) => {
  try {
    // This will attempt connection if not already connected
    await database.connect();
    
    const status = await database.getConnectionStatus();
    
    res.status(200).json({
      success: true,
      message: 'System is operational',
      database: status,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({
      success: false,
      message: 'System is not operational',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// API routes
app.use('/api/usuarios', usuariosRoutes);
app.use('/api/citas', citasRoutes);
app.use('/api/tratamientos', tratamientosRoutes);
app.use('/api/notificaciones', notificacionesRoutes);
app.use('/api/calendar', calendarRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/consejos', consejosRoutes);
app.use('/api/clinica', clinicaRoutes);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.originalUrl} not found`,
    timestamp: new Date().toISOString()
  });
});

// Global error handler
app.use(errorHandler);

// Initialize database and start server
async function startServer() {
  try {
    // Attempt database connection on startup
    console.log('[SERVER] Initializing database connection...');
    await database.connect();
    console.log('[SERVER] ✅ Database connection successful');

    iniciarRecordatorios();

    app.listen(PORT, () => {
      console.log(`[SERVER] 🚀 CheckDent API running on port ${PORT}`);
      console.log(`[SERVER] 📱 Health: http://localhost:${PORT}/health`);
      console.log(`[SERVER] 📊 Status: http://localhost:${PORT}/api/status`);
      console.log(`[SERVER] 🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
    });
    
  } catch (error) {
    console.error('[SERVER] ❌ Failed to start server:', error.message);
    process.exit(1);
  }
}

// Start the server
startServer();

module.exports = app;