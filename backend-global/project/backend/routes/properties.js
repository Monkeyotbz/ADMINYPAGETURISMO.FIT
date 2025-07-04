// filepath: DashboardBackend/routes/properties.js
const express = require('express');
const multer = require('multer');
const pool = require('../db');
const path = require('path'); // Agrega esto arriba

const router = express.Router();

// Configuración de multer para subir imágenes
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '..', 'uploads')), // <-- Cambia aquí
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname),
});
const upload = multer({ storage });

// Crear una propiedad completa
router.post('/', upload.array('images'), async (req, res) => {
  const {
    name,
    description,
    location,
    type,
    bedrooms,
    bathrooms,
    squareMeters,
    status,
    rating,
    prices, // string JSON
    features // <-- nuevo campo
  } = req.body;

  let parsedPrices;
  try {
    parsedPrices = JSON.parse(prices);
  } catch (e) {
    parsedPrices = [];
  }

  let parsedFeatures;
  try {
    parsedFeatures = features ? JSON.parse(features) : [];
  } catch (e) {
    parsedFeatures = [];
  }

  const imageUrls = req.files
    ? req.files.map(file => `/uploads/${file.filename}`)
    : [];

  try {
    const result = await pool.query(
      `INSERT INTO properties 
      (name, description, location, type, bedrooms, bathrooms, square_meters, status, rating, prices, image_urls, reviews, features)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13) RETURNING *`,
      [
        name,
        description,
        location,
        type,
        bedrooms,
        bathrooms,
        squareMeters,
        status,
        rating,
        JSON.stringify(parsedPrices),
        JSON.stringify(imageUrls),
        JSON.stringify([]), // reviews vacío
        JSON.stringify(parsedFeatures) // features
      ]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear la propiedad' });
  }
});

// Endpoint para obtener todas las propiedades
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM properties');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener propiedades' });
  }
});

// GET una propiedad por id
router.get('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM properties WHERE id = $1', [id]);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener la propiedad' });
  }
});

// PUT actualizar propiedad
router.put('/:id', upload.array('images'), async (req, res) => {
  console.log('PUT /properties/:id llamado');
  const { id } = req.params;
  let {
    name, description, location, type, bedrooms, bathrooms, squareMeters,
    status, rating, features, prices // <-- agrega prices aquí
  } = req.body;

  // Parse features si es string
  let parsedFeatures;
  try {
    parsedFeatures = features ? JSON.parse(features) : [];
  } catch (e) {
    parsedFeatures = [];
  }

  // Parse prices si es string
  let parsedPrices;
  try {
    parsedPrices = prices ? JSON.parse(prices) : [];
  } catch (e) {
    parsedPrices = [];
  }

  // Procesar imágenes actuales y nuevas
  let imageUrls = [];
  if (req.body.image_urls) {
    try {
      imageUrls = JSON.parse(req.body.image_urls);
    } catch {
      imageUrls = [];
    }
  }
  if (req.files && req.files.length > 0) {
    imageUrls = [
      ...imageUrls,
      ...req.files.map(file => `/uploads/${file.filename}`)
    ];
  }

  try {
    await pool.query(
      `UPDATE properties SET
        name=$1, description=$2, location=$3, type=$4, bedrooms=$5, bathrooms=$6,
        square_meters=$7, status=$8, rating=$9, features=$10, image_urls=$11, prices=$12
      WHERE id=$13`,
      [
        name,
        description,
        location,
        type,
        bedrooms,
        bathrooms,
        squareMeters,
        status,
        rating,
        JSON.stringify(parsedFeatures),
        JSON.stringify(imageUrls),
        JSON.stringify(parsedPrices), // <-- aquí guardas los precios
        id
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar la propiedad' });
  }
});

// Endpoint para actualizar hashtags de una propiedad
router.put('/:id/hashtags', async (req, res) => {
  const { id } = req.params;
  const { hashtags } = req.body;
  try {
    await pool.query(
      'UPDATE properties SET hashtags = $1 WHERE id = $2',
      [JSON.stringify(hashtags), id]
    );
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar hashtags' });
  }
});

module.exports = router;

console.log('Backend properties.js cargado');

// Se asume que el cambio sugerido es un ejemplo de datos para el campo "prices"
// Por lo tanto, se debe enviar como parte del cuerpo de la solicitud POST
// Ejemplo de solicitud POST para crear una propiedad:
// {
//   "name": "Propiedad de Ejemplo",
//   "description": "Descripción de la propiedad de ejemplo",
//   "location": "Ubicación de la propiedad",
//   "type": "Casa",
//   "bedrooms": 3,
//   "bathrooms": 2,
//   "squareMeters": 150,
//   "status": "Disponible",
//   "rating": 4.5,
//   "prices": "[{\"people\":1,\"price\":1500}]",
//   "images": [/* Archivos de imagen */]
// }

// El siguiente bloque fue removido porque contiene código React/TypeScript que no pertenece a un archivo backend de Node.js/Express.
