const { Client } = require('pg');
require('dotenv').config();

exports.handler = async (event) => {
    console.log("Lambda triggered with event:", event);

    // Database connection config from environment variables
    const dbConfig = {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        password: process.env.DB_PASSWORD,
        port: process.env.DB_PORT || 5432,
        ssl: { rejectUnauthorized: false } // Temporary: Disables SSL requirement for local testing
    };

    console.log("Connecting to database:", dbConfig.host);

    const client = new Client(dbConfig);

    try {
        await client.connect();
        console.log("Connected to database");

        const result = await client.query('SELECT NOW()');
        await client.end();

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "Connected to Postgres successfully!",
                time: result.rows[0].now,
            }),
        };
    } catch (err) {
        console.error("Database connection error:", err);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: "Failed to connect to database",
                details: err.message,
            }),
        };
    }
};
