const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Default error
  let error = {
    statusCode: err.statusCode || 500,
    message: err.message || 'Internal Server Error',
    code: err.code || 'INTERNAL_ERROR'
  };

  // SQL Server specific errors
  if (err.code) {
    switch (err.code) {
      case 'ELOGIN':
        error.statusCode = 503;
        error.message = 'Database connection failed - Invalid credentials';
        error.code = 'DB_CONNECTION_FAILED';
        break;
      case 'ETIMEOUT':
        error.statusCode = 503;
        error.message = 'Database request timeout';
        error.code = 'DB_TIMEOUT';
        break;
      case 'EREQUEST':
        error.statusCode = 400;
        error.message = 'Invalid database request';
        error.code = 'DB_INVALID_REQUEST';
        break;
      case 'PROTOCOL_CONNECTION_LOST':
        error.statusCode = 503;
        error.message = 'Database connection lost';
        error.code = 'DB_CONNECTION_LOST';
        break;
      default:
        error.statusCode = 500;
        error.message = 'Database error occurred';
        error.code = 'DB_ERROR';
    }
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error.statusCode = 401;
    error.message = 'Invalid token';
    error.code = 'INVALID_TOKEN';
  }

  if (err.name === 'TokenExpiredError') {
    error.statusCode = 401;
    error.message = 'Token expired';
    error.code = 'TOKEN_EXPIRED';
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    error.statusCode = 400;
    error.message = 'Validation error';
    error.code = 'VALIDATION_ERROR';
    error.details = err.details;
  }

  // Duplicate key error (unique constraint violation)
  if (err.number === 2627 || err.number === 2601) {
    error.statusCode = 409;
    error.message = 'Resource already exists';
    error.code = 'DUPLICATE_RESOURCE';
  }

  // Foreign key constraint violation
  if (err.number === 547) {
    error.statusCode = 409;
    error.message = 'Cannot delete: resource has dependencies';
    error.code = 'FOREIGN_KEY_VIOLATION';
  }

  // CORS error
  if (err.message && err.message.includes('CORS')) {
    error.statusCode = 403;
    error.message = 'CORS policy violation';
    error.code = 'CORS_ERROR';
  }

  // Send error response with consistent format
  res.status(error.statusCode).json({
    success: false,
    error: {
      code: error.code,
      message: error.message,
      ...(error.details && { details: error.details }),
      ...(process.env.NODE_ENV === 'development' && { 
        stack: err.stack,
        originalError: err.message 
      })
    },
    timestamp: new Date().toISOString(),
    path: req.path,
    method: req.method
  });
};

module.exports = errorHandler;