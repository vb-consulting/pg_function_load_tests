use actix_web::{get, web, App, HttpServer, Result};
use chrono::{DateTime, NaiveDateTime, Utc};
use serde::{Deserialize, Serialize};
use tokio_postgres::{Client, NoTls};

#[derive(Serialize)]
struct TestResult {
    id1: i32,
    foo1: Option<String>,
    bar1: Option<String>,
    datetime1: DateTime<Utc>,
    id2: i32,
    foo2: Option<String>,
    bar2: Option<String>,
    datetime2: DateTime<Utc>,
    long_foo_bar: Option<String>,
    is_foobar: bool,
}

#[derive(Deserialize)]
struct QueryParams {
    _records: i32,
    _text_param: String,
    _int_param: i32,
    _ts_param: DateTime<Utc>,
    _bool_param: bool,
}

async fn get_client() -> Client {
    let (client, connection) = tokio_postgres::connect(
        "host=postgres port=5432 user=testuser password=testpass dbname=testdb",
        NoTls,
    )
    .await
    .unwrap();

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    client
}

#[get("/api/test-data")]
async fn get_test_data(query: web::Query<QueryParams>) -> Result<web::Json<Vec<TestResult>>> {
    let client = get_client().await;
    
    // Convert DateTime<Utc> to NaiveDateTime for PostgreSQL
    let ts_param = query._ts_param.naive_utc();

    let rows = client
        .query(
            "SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar 
             FROM public.test_func_v1($1, $2, $3, $4::timestamp, $5)",
            &[
                &query._records,
                &query._text_param,
                &query._int_param,
                &ts_param,
                &query._bool_param,
            ],
        )
        .await
        .unwrap();

    let results: Vec<TestResult> = rows
        .iter()
        .map(|row| {
            // Convert NaiveDateTime back to DateTime<Utc> for the response
            let datetime1: NaiveDateTime = row.get(3);
            let datetime2: NaiveDateTime = row.get(7);

            TestResult {
                id1: row.get(0),
                foo1: row.get(1),
                bar1: row.get(2),
                datetime1: DateTime::<Utc>::from_naive_utc_and_offset(datetime1, Utc),
                id2: row.get(4),
                foo2: row.get(5),
                bar2: row.get(6),
                datetime2: DateTime::<Utc>::from_naive_utc_and_offset(datetime2, Utc),
                long_foo_bar: row.get(8),
                is_foobar: row.get(9),
            }
        })
        .collect();

    Ok(web::Json(results))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("warn"));
    HttpServer::new(|| App::new().service(get_test_data))
        .bind("0.0.0.0:5300")?
        .run()
        .await
}
