# CheckDent Backend API

Backend API for the CheckDent dental appointment management system.

## Features

- 🔐 JWT Authentication
- 📅 Appointment Management
- 🗓️ Google Calendar Integration
- 📱 Push Notifications (Firebase FCM)
- 👥 User Management (Patients & Doctors)
- 🏥 Treatment Management
- 📊 Admin Dashboard
- 🔔 Notification System

## API Endpoints

### Authentication & Users (`/api/usuarios`)
- `POST /register` - Register new user (patient/doctor)
- `POST /login` - User login
- `GET /me` - Get current user profile
- `PUT /:id` - Update user profile

### Appointments (`/api/citas`)
- `GET /disponibilidad` - Check doctor availability
- `POST /` - Schedule new appointment
- `PUT /:id/reprogramar` - Reschedule appointment
- `DELETE /:id/cancelar` - Cancel appointment
- `GET /historial/:id_usuario` - Get user's appointment history
- `GET /agenda/doctor/:id_doctor` - Get doctor's complete schedule

### Treatments (`/api/tratamientos`)
- `GET /` - Get all treatments
- `GET /:id` - Get treatment details
- `POST /` - Create new treatment (Doctor only)
- `PUT /:id` - Update treatment (Doctor only)
- `DELETE /:id` - Delete treatment (Doctor only)

### Notifications (`/api/notificaciones`)
- `POST /enviar` - Send notification (Doctor only)
- `GET /:id_usuario` - Get user's notifications
- `GET /` - Get all notifications (Doctor only)
- `POST /recordatorio-cita` - Send appointment reminder
- `DELETE /:id` - Delete notification (Doctor only)

### Google Calendar (`/api/calendar`)
- `GET /disponibilidad` - Get real availability from Google Calendar
- `POST /evento` - Create calendar event
- `PUT /evento/:id` - Update calendar event
- `DELETE /evento/:id` - Delete calendar event
- `GET /auth-url` - Get Google OAuth2 URL
- `POST /auth-callback` - Handle OAuth2 callback

### Admin (`/api/admin`)
- `GET /citas/hoy` - Today's appointments
- `GET /citas/semana` - Weekly schedule
- `GET /dashboard` - Dashboard summary
- `POST /citas/:id/completar` - Mark appointment as completed
- `GET /reportes/mensual` - Monthly report

## Installation

1. Clone the repository
2. Copy `.env.example` to `.env` and configure your environment variables
3. Install dependencies:
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm start
   ```

## Environment Variables

Required environment variables:

```env
# Database
DB_SERVER=your_sql_server
DB_DATABASE=CheckDent
DB_USER=your_db_user
DB_PASSWORD=your_db_password

# JWT
JWT_SECRET=your_jwt_secret

# Google Calendar
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Firebase (for notifications)
FIREBASE_PROJECT_ID=your_firebase_project
FIREBASE_PRIVATE_KEY=your_firebase_key
FIREBASE_CLIENT_EMAIL=your_firebase_email
```

## Database Schema

The API uses the SQL Server database schema defined in `BD.sql` with the following tables:
- `Usuario` - Users (patients and doctors)
- `Tratamiento` - Available treatments
- `Cita` - Appointments
- `Notificacion` - Notifications

## Authentication

The API uses JWT tokens for authentication. Include the token in the Authorization header:

```
Authorization: Bearer your_jwt_token
```

## Error Handling

All endpoints return consistent error responses:

```json
{
  "error": "Error Type",
  "message": "Detailed error message",
  "timestamp": "2023-11-18T10:30:00.000Z",
  "path": "/api/endpoint",
  "method": "POST"
}
```

## Development

- `npm run dev` - Start with nodemon for development
- `npm test` - Run tests
- `npm start` - Start production server

## Integration Notes

### Flutter App Integration
This backend is designed to work with the Flutter CheckDent app. The API endpoints match the use cases defined in the mobile app's views:

- `/lib/view/citas/` - Uses appointment endpoints
- `/lib/view/home/` - Uses dashboard and summary endpoints
- `/lib/view/perfil/` - Uses user profile endpoints
- `/lib/view/contacto/` - Uses notification endpoints

### Google Calendar Setup
1. Create a Google Cloud project
2. Enable the Calendar API
3. Create OAuth2 credentials
4. Configure redirect URIs
5. Use `/api/calendar/auth-url` to get authorization URL
6. Handle callback with `/api/calendar/auth-callback`

### Firebase Push Notifications
1. Create a Firebase project
2. Generate service account key
3. Configure environment variables
4. Notifications will be sent automatically for:
   - Appointment confirmations
   - Reminders
   - Cancellations

## Security Features

- Helmet.js for security headers
- Rate limiting
- CORS configuration
- Password hashing with bcrypt
- JWT token validation
- Role-based access control

## API Testing

Use the health check endpoint to verify the API is running:
```
GET http://localhost:3000/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "CheckDent API is running",
  "timestamp": "2023-11-18T10:30:00.000Z",
  "version": "1.0.0"
}
```