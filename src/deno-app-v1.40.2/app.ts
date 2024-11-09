// app.ts
import { Application, Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

// Create database client
const client = new Client({
    user: Deno.env.get("DB_USER"),
    database: Deno.env.get("DB_NAME"),
    hostname: Deno.env.get("DB_HOST"),
    password: Deno.env.get("DB_PASSWORD"),
    port: 5432,
});

const app = new Application();
const router = new Router();

router.get("/api/test-data", async (ctx) => {
    const params = ctx.request.url.searchParams;

    // Get parameters from query string with defaults
    const numRecords = parseInt(params.get("_records") || "0");
    const textParam = params.get("_text_param") || "";
    const intParam = parseInt(params.get("_int_param") || "0");
    const tsParam = params.get("_ts_param") || "";
    const boolParam = (params.get("_bool_param") || "").toLowerCase() === "true";

    try {
        await client.connect();
        const result = await client.queryObject({
            text: "SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar FROM public.test_func_v1($1, $2, $3, $4::timestamp, $5)",
            args: [numRecords, textParam, intParam, tsParam, boolParam],
        });
    
        ctx.response.body = result.rows;
    } catch (err) {
        console.error("Error executing query:", err);
        ctx.response.status = 500;
        ctx.response.body = { error: err.message };
    } finally {
        await client.end();
    }
});

app.use(router.routes());
app.use(router.allowedMethods());

const port = 3102;
console.log(`Deno app listening at http://localhost:${port}`);

await app.listen({
    port: 3102,
    hostname: "0.0.0.0"
});
