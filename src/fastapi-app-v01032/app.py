from fastapi import FastAPI, Query, HTTPException
import asyncpg
import os
from datetime import datetime
from datetime import timezone

app = FastAPI()

DATABASE_URL = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
pool = None

@app.on_event("startup")
async def startup():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL)

@app.on_event("shutdown")
async def shutdown():
    await pool.close()

@app.get("/api/test-data")
async def get_test_data(
    _records: int = Query(..., alias="_records"),
    _text_param: str = Query(..., alias="_text_param"),
    _int_param: int = Query(..., alias="_int_param"),
    _ts_param: str = Query(..., alias="_ts_param"),
    _bool_param: bool = Query(..., alias="_bool_param")
):
    try:
        async with pool.acquire() as connection:
            rows = await connection.fetch(
                """
                select id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar 
                from public.test_func_v1($1, $2, $3, $4::text::timestamp, $5)
                """,
                _records, _text_param, _int_param, _ts_param, _bool_param
            )
            return [dict(row) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Running the FastAPI server (usually in uvicorn for deployment)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
