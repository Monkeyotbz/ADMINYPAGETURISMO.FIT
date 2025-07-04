const express = require('express');
const cors = require('cors');
const propertiesRoutes = require('./backend/routes/properties');
const path = require('path');
const db = require('./db'); // Asegúrate de tener tu conexión a la base de datos
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');
const mercadopago = require('mercadopago');

// Nueva forma de crear el cliente:
const mp = new mercadopago.MercadoPagoConfig({
  accessToken: 'TU_ACCESS_TOKEN_DE_PRUEBA'
});

const app = express();
app.use(express.json());

// Configura CORS para todos tus frontends
app.use(cors({
  origin: [
    'http://localhost:5174',
    'http://localhost:5173'
    // agrega más si tienes más apps
  ]
}));

// Carpeta para archivos estáticos (imágenes)
const uploadsPath = path.resolve(__dirname, 'backend', 'uploads');
console.log('Sirviendo imágenes desde:', uploadsPath);
app.use('/uploads', express.static(uploadsPath));

// Rutas
app.use('/properties', propertiesRoutes);

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const result = await db.query(
      'SELECT * FROM usuarios WHERE email = $1',
      [email]
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    const user = result.rows[0];
    if (!user.password || typeof user.password !== 'string') {
      return res.status(401).json({ message: 'Contraseña no válida. Contacta al administrador.' });
    }
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }
    res.json({ user, token: 'fake-jwt-token' });
  } catch (err) {
    console.error('Error en /login:', err);
    res.status(500).json({ message: 'Error en el servidor' });
  }
});

app.post('/register', async (req, res) => {
  const { email, password } = req.body;
  try {
    // Hashea la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Guarda hashedPassword en la base de datos
    const result = await db.query(
      'INSERT INTO usuarios (email, password) VALUES ($1, $2) RETURNING *',
      [email, hashedPassword]
    );
    
    res.status(201).json({ user: result.rows[0], token: 'fake-jwt-token' });
  } catch (err) {
    res.status(500).json({ message: 'Error en el servidor' });
  }
});

app.post('/signup', async (req, res) => {
  const { nombre, email, password, telefono, rol } = req.body;
  try {
    if (!password || typeof password !== 'string') {
      return res.status(400).json({ message: 'La contraseña es obligatoria.' });
    }
    // Verifica si el usuario ya existe
    const exists = await db.query('SELECT * FROM usuarios WHERE email = $1', [email]);
    if (exists.rows.length > 0) {
      return res.status(400).json({ message: 'El correo ya está registrado.' });
    }
    // Encripta la contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Genera un token de confirmación
    const token = crypto.randomBytes(32).toString('hex');

    // Inserta el usuario con el token de confirmación
    await db.query(
      'INSERT INTO usuarios (nombre, email, password, telefono, rol, confirm_token, confirmado) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [nombre, email, hashedPassword, telefono, rol, token, false]
    );

    // Configura el transporte de nodemailer
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'turismocolombia.fit.mail@gmail.com',
        pass: 'cawcexrgagsbsrmb', // <-- tu contraseña de aplicación, sin espacios
      },
    });

    // Enlace de confirmación
    const confirmUrl = `http://localhost:5000/confirmar-correo?token=${token}`;

    // Envía el correo
    await transporter.sendMail({
      from: '"Turismo Colombia" <turismocolombia.fit.mail@gmail.com>',
      to: email,
      subject: '¡Confirma tu correo y recibe un 10% de descuento!',
      html: `
        <div style="font-family: Arial, sans-serif; background: #fafafa; padding: 32px 0;">
          <div style="max-width: 420px; margin: auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px 32px 24px 32px; text-align: center;">
            <img src="https://turismocolombiafit.vercel.app/turismo%20colombia%20fit%20logo-02.png" alt="Turismocolombia" style="height: 50px; margin-bottom: 16px;" />
            <h2 style="color: #c00; margin-bottom: 16px;">¡Confirma tu correo!</h2>
            <p style="font-size: 16px; color: #222; margin-bottom: 16px;">
              Confirma tu email para recibir un <b>10% de descuento</b> en tu primera reservación en <b>Turismocolombia</b>.
            </p>
            <a href="${confirmUrl}" style="display: inline-block; background: #c00; color: #fff; font-weight: bold; font-size: 18px; padding: 14px 32px; border-radius: 8px; text-decoration: none; margin: 24px 0;">
              Confirmar mi email
            </a>
            <p style="font-size: 12px; color: #888; margin-top: 24px;">
              Si no creaste una cuenta, puedes ignorar este mensaje.
            </p>
          </div>
        </div>
      `,
    });

    res.status(201).json({ message: 'Usuario registrado. Revisa tu correo para confirmar tu cuenta.' });
  } catch (err) {
    console.error('Error en /signup:', err);
    res.status(500).json({ message: 'Error en el servidor' });
  }
});

app.get('/confirmar-correo', async (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).send('Token de confirmación faltante.');
  }
  try {
    // Busca el usuario con ese token
    const result = await db.query(
      'SELECT * FROM usuarios WHERE confirm_token = $1',
      [token]
    );
    if (result.rows.length === 0) {
      return res.status(400).send('Token inválido o ya utilizado.');
    }
    // Marca el usuario como confirmado y elimina el token
    await db.query(
      'UPDATE usuarios SET confirmado = true, confirm_token = NULL WHERE confirm_token = $1',
      [token]
    );
    res.send(`
      <div style="font-family: Arial, sans-serif; background: #fafafa; min-height: 100vh; display: flex; align-items: center; justify-content: center;">
        <div style="max-width: 420px; margin: auto; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px #0001; padding: 32px 32px 24px 32px; text-align: center;">
          <img src="https://turismocolombiafit.vercel.app/turismo%20colombia%20fit%20logo-02.png" alt="Turismocolombia" style="height: 50px; margin-bottom: 16px;" />
          <h2 style="color: #c00; margin-bottom: 16px;">¡Correo confirmado correctamente!</h2>
          <p style="font-size: 16px; color: #222; margin-bottom: 24px;">
            Ya puedes iniciar sesión y disfrutar de tu descuento.
          </p>
          <a href="http://localhost:5173/login" style="display: inline-block; background: #c00; color: #fff; font-weight: bold; font-size: 18px; padding: 14px 32px; border-radius: 8px; text-decoration: none;">
            Ir a iniciar sesión
          </a>
        </div>
      </div>
    `);
  } catch (err) {
    console.error('Error en /confirmar-correo:', err);
    res.status(500).send('Error en el servidor.');
  }
});

app.post('/reservas', async (req, res) => {
  try {
    const {
      usuario_id,
      nombre,
      correo,
      telefono,
      direccion,
      propiedad_id,
      propiedad_nombre,
      location,
      check_in,
      check_out,
      guests,
      precio_noche
    } = req.body;

    // Calcula días de estadía
    const dias = Math.max(
      0,
      (new Date(check_out) - new Date(check_in)) / (1000 * 60 * 60 * 24)
    );
    const subtotal = dias * precio_noche * guests;
    const impuesto = subtotal * 0.05;
    const valor_aseo = subtotal * 0.02;
    const precio_total = subtotal + impuesto + valor_aseo;

    // Inserta la reserva
    const result = await db.query(
      `INSERT INTO reservas (
        usuario_id, nombre, correo, telefono, direccion,
        propiedad_id, propiedad_nombre, location,
        check_in, check_out, guests, precio_noche,
        subtotal, impuesto, valor_aseo, precio_total
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
      RETURNING *`,
      [
        usuario_id,
        nombre,
        correo,
        telefono,
        direccion,
        propiedad_id,
        propiedad_nombre,
        location,
        check_in,
        check_out,
        guests,
        precio_noche,
        subtotal,
        impuesto,
        valor_aseo,
        precio_total
      ]
    );

    // Devuelve la pre-factura (reserva recién creada)
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error en /reservas:', err);
    res.status(500).json({ message: 'Error al guardar la reserva' });
  }
});

app.get('/reservas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('SELECT * FROM reservas WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reserva no encontrada' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error en GET /reservas/:id:', err);
    res.status(500).json({ message: 'Error al obtener la reserva' });
  }
});

const { Preference } = require('mercadopago');
const preferenceClient = new Preference(mp);

app.post('/crear-preferencia', async (req, res) => {
  try {
    const { descripcion, precio, cantidad } = req.body;
    const preference = {
      items: [
        {
          title: descripcion,
          unit_price: Number(precio),
          quantity: Number(cantidad),
        }
      ],
      back_urls: {
        success: "http://localhost:5173/pago-exitoso",
        failure: "http://localhost:5173/pago-fallido",
        pending: "http://localhost:5173/pago-pendiente"
      },
      auto_return: "approved"
    };

    const result = await preferenceClient.create({ body: preference });
    res.json({ id: result.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear preferencia' });
  }
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});