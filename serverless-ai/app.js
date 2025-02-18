const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');

// Load environment variables locally but not in production
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

const app = express();
app.use(bodyParser.json());
app.use(cors());

console.log('DB CONFIG:', {
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});

const pool = new Pool({
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 5432,
  ssl: { rejectUnauthorized: false },
});

// Basic API routes
app.get('/api', async (req, res) => {
  res.json({ message: 'From Node.js API root!' });
});

app.get('/api/hello', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ message: 'From Node.js Hello API!', time: result.rows[0].now });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Database query failed', details: error.message });
  }
});

// Local server start
if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// Export app for Lambda compatibility
module.exports = app;

// Lambda handler for serverless
const serverlessExpress = require('@vendia/serverless-express');
module.exports.main = serverlessExpress({ app });
