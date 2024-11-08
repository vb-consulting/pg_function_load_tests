#!/bin/bash

STAMP=$(date +"%Y%m%d%H%M")

mkdir -p /results
mkdir -p /results/$STAMP
echo "Results will be saved in /results/$STAMP"

echo "Starting k6 tests, output will be saved in /results/$STAMP"

echo "Starting django-app-v509..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=django-app-v509 -e PORT=8000

sleep 2
echo "Starting express-app-v4182..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=express-app-v4182 -e PORT=3100

sleep 2
echo "Starting postgrest-v1223..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=postgrest-v1223 -e PORT=3000 -e REQ_PATH=/rpc/test_func_v1

sleep 2
echo "Starting fastapi-app-v01032..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=fastapi-app-v01032 -e PORT=8001

sleep 2
echo "Starting fastify-app-v4261..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=fastify-app-v4261 -e PORT=3101

sleep 2
echo "Starting deno-app-v1402..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=deno-app-v1402-e PORT=3102

sleep 2
echo "Starting npgsqlrest-aot-v210..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=npgsqlrest-aot-v210 -e PORT=5000

sleep 2
echo "Starting npgsqlrest-aot-v221..."
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=npgsqlrest-aot-v221 -e PORT=5001

OUTPUT_FILE="/results/$STAMP.csv"
> "$OUTPUT_FILE"
echo "Processing results... Saving to $OUTPUT_FILE"

if ls /results/$STAMP/*.csv 1> /dev/null 2>&1; then
    for file in /results/$STAMP/*.csv; do
        echo "Processing file: $file"
        filename=$(basename "$file" .csv)
        content=$(cat "$file")
        echo "Content read: $content"
        if [ ! -z "$content" ]; then
            echo "$filename,$content" >> "$OUTPUT_FILE"
        else
            echo "Warning: $file is empty"
        fi
    done

    rm /results/$STAMP/*.csv
else
    echo "No CSV files found in /results/$STAMP/"
fi

echo "Results processed and saved to $OUTPUT_FILE"
