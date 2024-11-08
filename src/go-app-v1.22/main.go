package main

import (
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "runtime"
    "time"

    _ "github.com/lib/pq"
)

type Result struct {
    ID1        int       `json:"id1"`
    Foo1       *string   `json:"foo1"`
    Bar1       *string   `json:"bar1"`
    Datetime1  time.Time `json:"datetime1"`
    ID2        int       `json:"id2"`
    Foo2       *string   `json:"foo2"`
    Bar2       *string   `json:"bar2"`
    Datetime2  time.Time `json:"datetime2"`
    LongFooBar *string   `json:"long_foo_bar"`
    IsFoobar   bool      `json:"is_foobar"`
}

func main() {
    fmt.Printf("Go version: %s\n", runtime.Version())

    db, err := sql.Open("postgres", "host=postgres port=5432 user=testuser password=testpass dbname=testdb sslmode=disable")
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()

    http.HandleFunc("/api/test-data", func(w http.ResponseWriter, r *http.Request) {
        if r.Method != http.MethodGet {
            http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
            return
        }

        query := r.URL.Query()
        records := query.Get("_records")
        textParam := query.Get("_text_param")
        intParam := query.Get("_int_param")
        tsParam := query.Get("_ts_param")
        boolParam := query.Get("_bool_param")

        if records == "" || textParam == "" || intParam == "" || tsParam == "" || boolParam == "" {
            http.Error(w, "Missing required parameters", http.StatusBadRequest)
            return
        }

        results, err := getTestData(db, records, textParam, intParam, tsParam, boolParam)
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }

        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(results)
    })

    port := os.Getenv("PORT")
    if port == "" {
        port = "5200"
    }

    fmt.Printf("Server starting on port %s...\n", port)
    if err := http.ListenAndServe(":"+port, nil); err != nil {
        log.Fatal(err)
    }
}

func getTestData(db *sql.DB, records, textParam, intParam, tsParam, boolParam string) ([]Result, error) {
    query := `
        SELECT id1, foo1, bar1, datetime1, id2, foo2, bar2, datetime2, long_foo_bar, is_foobar
        FROM public.test_func_v1($1, $2, $3, $4::timestamp, $5)
    `

    rows, err := db.Query(query, records, textParam, intParam, tsParam, boolParam)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var results []Result
    for rows.Next() {
        var r Result
        err := rows.Scan(
            &r.ID1,
            &r.Foo1,
            &r.Bar1,
            &r.Datetime1,
            &r.ID2,
            &r.Foo2,
            &r.Bar2,
            &r.Datetime2,
            &r.LongFooBar,
            &r.IsFoobar,
        )
        if err != nil {
            return nil, err
        }
        results = append(results, r)
    }

    return results, rows.Err()
}
