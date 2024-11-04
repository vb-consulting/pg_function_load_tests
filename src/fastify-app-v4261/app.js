const fastify = require('fastify')({ logger: false });
const { Pool } = require('pg');

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: 5432,
});

fastify.get('/api/test-data', async (request, reply) => {
    // Get parameters from query string with defaults
    const numRecords = parseInt(request.query._records);
    const textParam = request.query._text_param;
    const intParam = parseInt(request.query._int_param);
    const tsParam = request.query._ts_param;
    const boolParam = request.query._bool_param.toLowerCase() === 'true';

    try {
        const result = await pool.query(
            `select id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar from public.test_func_v1($1, $2, $3, $4::timestamp, $5)`, 
            [numRecords, textParam, intParam, tsParam, boolParam]);
        return result.rows;
    } catch (err) {
        fastify.log.error('Error executing query:', err);
        reply.code(500).send({ error: err.message });
    }
});

const start = async () => {
    try {
        await fastify.listen({ port: 3101, host: '0.0.0.0' });
    } catch (err) {
        fastify.log.error(err);
        process.exit(1);
    }
};

start();
