const cron = require('node-cron');
const Cita = require('../models/Cita');
const Usuario = require('../models/Usuario');
const { enviarCorreoCita } = require('../utils/emailService');

const iniciarRecordatorios = () => {

  cron.schedule('0 8 * * *', async () => {
    console.log('⏰ Ejecutando chequeo diario de recordatorios...');

    try {
      // Calcular fecha
      const hoy = new Date();
      const mañana = new Date(hoy);
      mañana.setDate(hoy.getDate() + 1);

      // Ajustar inicio y fin del día para buscar
      const inicioDia = new Date(mañana.setHours(0,0,0,0));
      const finDia = new Date(mañana.setHours(23,59,59,999));

      const citasMañana = await Cita.find({
        fecha: { $gte: inicioDia, $lte: finDia },
        estado: 'programada',
        notificacionEnviada: false
      });

      console.log(`🔎 Se encontraron ${citasMañana.length} citas para mañana.`);

      for (const cita of citasMañana) {
        const paciente = await Usuario.findById(cita.pacienteId);
        const doctor = await Usuario.findById(cita.doctorId);

        if (paciente && doctor) {

          console.log(`📨 Enviando recordatorio a ${paciente.email}`);


          require('../utils/emailService').enviarCorreoCita(
             paciente.email,
             paciente.nombre,
             "MAÑANA a las " + cita.horaInicio,
             cita.horaInicio,
             doctor.nombre
          );

          cita.notificacionEnviada = true;
          await cita.save();
        }
      }
    } catch (error) {
      console.error("❌ Error en el servicio de recordatorios:", error);
    }
  });

  console.log("✅ Servicio de recordatorios automáticos iniciado (08:00 AM)");
};

module.exports = { iniciarRecordatorios };