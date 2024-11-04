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
    const numRecords = parseInt(req.query._records);
    const textParam = req.query._text_param;
    const intParam = parseInt(req.query._int_param);
    const tsParam = req.query._ts_param;
    const boolParam = req.query._bool_param.toLowerCase() === 'true';

    try {
        const result = await pool.query(
            `select id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar from public.test_func_v1($1, $2, $3, $4::timestamp, $5)`, 
            [numRecords, textParam, intParam, tsParam, boolParam]);
        res.json(result.rows);
    } catch (err) {
        console.error('Error executing query:', err);
        res.status(500).json({ error: err.message });
    }
});

const port = 3100;
app.listen(port, () => {
    console.log(`Express app listening at http://localhost:${port}`);
});
