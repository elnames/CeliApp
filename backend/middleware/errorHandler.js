const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  
  const errorResponse = {
    message: err.message || 'Error interno del servidor',
    status: err.status || 500,
    error: process.env.NODE_ENV === 'development' ? err : {}
  };

  res.status(errorResponse.status).json(errorResponse);
};

module.exports = errorHandler; 