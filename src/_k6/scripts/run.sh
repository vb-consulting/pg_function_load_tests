#!/bin/sh

STAMP=$(date +"%Y%m%d%H%M")

mkdir -p /results
mkdir -p /results/$STAMP

echo "*** Starting k6 tests, output will be saved in /results/$STAMP"

for records in 10 50 500; do # records retrieved
for target in 1 50 100; do # target number of virtual users VUs
for duration in 10s 60s 120s; do # for duration in 5s 60s 120s; do # duration of the test
while read -r tag port; do
    echo "*** Running $tag:$port with $records records, $target VUs, and $duration duration"
    k6 run /scripts/script.js -e STAMP=$STAMP -e TAG=$tag -e PORT=$port -e RECORDS=$records -e DURATION=$duration -e TARGET=$target
    sleep 10 # sleep for 10 seconds between tests
done << EOF
django-app-v5.0.9 8000
express-app-v4.18.2 3100
postgrest-v12.2.3 3000
fastapi-app-v0.103.2 8001
fastify-app-v4.26.1 3101
deno-app-v1.40.2 3102
swoole-php-app-8.3.13 3103
npgsqlrest-aot-v2.2.1 5000
net8-npgsqlrest-jit-v2.12.1 5001
net8-minapi-ef-jit-v8.0.10 5002
net8-minapi-dapper-jit-v2.1.35 5003
net8-minapi-norm-jit-v5.4.0 5004
net8-minapi-ado-jit-v8.0.5 5005
go-app-v1.22.9 5200
rust-app-v1.75.0 5300
java21-spring-boot-v3.2.2 5400
perl-net-server-prefork-v5.34 8088
npgsqlrest-aot-v2.4.0 5500
net9-npgsqlrest-jit-v2.13.1 5501
net9-minapi-ef-jit-v9.0.1 5502
net9-minapi-dapper-jit-v2.1.35 5503
net9-minapi-norm-jit-v5.4.0 5504
net9-minapi-ado-jit-v8.0.5 5505
EOF
done # duration of the test
done # target number of virtual users VUs
done # records retrieved

OUTPUT_FILE="/results/$STAMP.md"
> "$OUTPUT_FILE"
echo "*** processing results... Saving to $OUTPUT_FILE"

# `|${tag}|${target}|${duration}|${records}|${reqs}|${reqsPerSec}|${reqsDuration}|${failedReqs}|[summary](/${stamp}/${fileTag}_summary.txt)|`
echo "| Service | Virtual Users | Duration | Retrived Records | Total Requests | Requests Per Second | Average Duration | Failed Requests | Summary Link |" >> "$OUTPUT_FILE"
echo "|---------|--------------:|---------:|-----------------:|---------------:|--------------------:|-----------------:|----------------:|--------------|" >> "$OUTPUT_FILE"

if ls /results/$STAMP/*.md 1> /dev/null 2>&1; then
    for file in /results/$STAMP/*.md; do
        echo "Processing file: $file"
        filename=$(basename "$file" .md)
        content=$(cat "$file")
        echo "Content read: $content"
        if [ ! -z "$content" ]; then
            echo $content >> "$OUTPUT_FILE"
        else
            echo "Warning: $file is empty"
        fi
    done

    rm /results/$STAMP/*.md
else
    echo "No MD files found in /results/$STAMP/"
fi

echo "*** Results processed and saved to $OUTPUT_FILE"
