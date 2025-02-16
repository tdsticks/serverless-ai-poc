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

// Build the connection string from individual environment variables
const dbUser = process.env.DB_USER;
const dbPassword = process.env.DB_PASSWORD;
const dbHost = process.env.DB_HOST;
const dbPort = process.env.DB_PORT || 5432;
const dbName = process.env.DB_NAME;

// Construct DATABASE_URL
const databaseUrl = `postgres://${dbUser}:${dbPassword}@${dbHost}:${dbPort}/${dbName}`;

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: { rejectUnauthorized: false }
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
