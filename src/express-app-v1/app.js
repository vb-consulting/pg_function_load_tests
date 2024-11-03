const express = require('express');
const { Pool } = require('pg');
const app = express();

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: 5432,
});

app.get('/api/test-data', async (req, res) => {
    // Get parameters from query string with defaults
    const numRecords = parseInt(req.query.records) || 10;
    const textParam = req.query.text || 'default';
    const intParam = parseInt(req.query.int) || 0;
    const tsParam = req.query.timestamp || new Date().toISOString();
    const boolParam = (req.query.bool || 'true').toLowerCase() === 'true';

    try {
        const result = await pool.query(
            `select id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar from test_func_v1($1, $2, $3, $4::timestamp, $5)`, 
            [numRecords, textParam, intParam, tsParam, boolParam]);
        res.json(result.rows);
    } catch (err) {
        console.error('Error executing query:', err);
        res.status(500).json({ error: err.message });
    }
});

const port = 3000;
app.listen(port, () => {
    console.log(`Express app listening at http://localhost:${port}`);
});
