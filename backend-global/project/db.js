// filepath: DashboardBackend/db/index.js
const { Pool } = require('pg');

const pool = new Pool({
  user: 'turismo',
  host: '192.168.0.24',
  database: 'turismocolombia',
  password: 'turismo123',
  port: 5432,
});

module.exports = pool;