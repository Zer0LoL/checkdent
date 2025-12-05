const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: process.env.SMTP_PORT || 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const enviarCorreoCita = async (emailDestino, nombrePaciente, fecha, hora, doctor) => {
  try {
    const info = await transporter.sendMail({
      from: '"CheckDent 🦷" <no-reply@checkdent.com>',
      to: emailDestino,
      subject: '✅ Confirmación de Cita - CheckDent',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #9C27B0;">¡Tu cita está confirmada!</h2>
          <p>Hola <strong>${nombrePaciente}</strong>,</p>
          <p>Hemos reservado tu espacio exitosamente.</p>
          <div style="background-color: #f3e5f5; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <p><strong>📅 Fecha:</strong> ${fecha}</p>
            <p><strong>⏰ Hora:</strong> ${hora}</p>
            <p><strong>👨‍⚕️ Doctor:</strong> ${doctor}</p>
          </div>
          <p>Por favor llega 10 minutos antes. Si necesitas cancelar, hazlo desde la app.</p>
          <p><em>Saludos,<br>Equipo CheckDent</em></p>
        </div>
      `,
    });
    console.log("Correo enviado: %s", info.messageId);
    return true;
  } catch (error) {
    console.error("Error enviando correo:", error);
    return false;
  }
};

module.exports = { enviarCorreoCita };