#!/bin/bash

STAMP=$(date +"%Y%m%d%H%M")

mkdir -p /results/$STAMP
echo "Results will be saved in /results/$STAMP"

echo "Starting k6 tests, output will be saved in /results/$STAMP"
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=django-app-v1 -e PORT=8000
k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=express-app-v1 -e PORT=3000

OUTPUT_FILE="/results/$STAMP.csv"
> "$OUTPUT_FILE"
echo "Processing results... Saving to $OUTPUT_FILE"

if ls /results/$STAMP/*.csv 1> /dev/null 2>&1; then
    for file in /results/$STAMP/*.csv; do
        echo "Processing file: $file"
        filename=$(basename "$file" .csv)
        echo "Filename extracted: $filename"
        content=$(cat "$file")
        echo "Content read: $content"
        if [ ! -z "$content" ]; then
            echo "$filename,$content" >> "$OUTPUT_FILE"
            echo "Line written to output file"
        else
            echo "Warning: $file is empty"
        fi
    done
else
    echo "No CSV files found in /results/$STAMP/"
fi

echo "Results processed and saved to $OUTPUT_FILE"
