const app = require('./server');
const request = require('supertest');

// Simple test to verify server is working
const testServer = async () => {
  try {
    console.log('🧪 Testing CheckDent API...');
    
    // Test health endpoint
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    console.log('✅ Health check passed:', response.body);
    
    // Test 404 endpoint
    const notFoundResponse = await request(app)
      .get('/api/nonexistent')
      .expect(404);
    
    console.log('✅ 404 handling works:', notFoundResponse.body);
    
    console.log('🎉 All basic tests passed!');
    console.log('\n📋 API Endpoints available:');
    console.log('  - POST /api/usuarios/register - Register user');
    console.log('  - POST /api/usuarios/login - Login');
    console.log('  - GET /api/usuarios/me - Get profile (requires auth)');
    console.log('  - GET /api/citas/disponibilidad - Check availability');
    console.log('  - POST /api/citas - Schedule appointment (requires auth)');
    console.log('  - GET /api/tratamientos - Get treatments (requires auth)');
    console.log('  - POST /api/notificaciones/enviar - Send notification (doctor only)');
    console.log('  - GET /api/calendar/disponibilidad - Google Calendar availability');
    console.log('  - GET /api/admin/dashboard - Admin dashboard (doctor only)');
    console.log('\n🔧 Make sure to configure your .env file with database credentials!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
};

if (require.main === module) {
  testServer();
}

module.exports = testServer;