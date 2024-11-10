# Load Performance Testing for Web APIs Returning a Single PostgreSQL Function

This project performs load performance testing for Web APIs on different tech stack that will execute a single [PostgreSQL function](https://github.com/vb-consulting/pg_function_load_tests/blob/master/src/postgres/init.sql) and return the result.

## Running Manually

```
git clone https://github.com/vb-consulting/pg_function_load_tests.git
cd src
docker-compose down && docker-compose up --build
```

Please wait a few seconds for all services to initialize properly (health check isn't implemented yet), and then run from the same directory:

```
docker-compose exec test /bin/sh /scripts/run.sh
```

Results will be save to `src/k6/results/` directory under the current timestamp subdirectory.

## Results

These are the preliminary results conductedon my laptop until I find the suitable isolated server enviorment for testing.

Test parameters:

- Function returns 25 records.
- Test running for 10 seconds.
- 100 simulated concurent users.

| service tag | total req. | req. per second | error rate | source link | summary link |
| ----------- | ---------: | --------------: | ---------: | ----------: | -----------: |
| npgsqlrest-aot-v2.2.1 | 24998 | 2478.6403342712874 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/npgsqlrest-aot-v2.2.1) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/npgsqlrest-aot-v2.2.1_summary.txt) |
| net8-npgsqlrest-jit-v2.12.1 | 21286 | 2121.850722587053 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/net8-npgsqlrest-jit-v2.12.1) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/net8-npgsqlrest-jit-v2.12.1_summary.txt) |
| swoole-php-app-8.3.13 | 18708 | 1859.1572229170743 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/swoole-php-app-8.3.13) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/swoole-php-app-8.3.13_summary.txt) |
| net8-minapi-ado-jit-v8.0.5 | 17304 | 1727.563324091721 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/net8-minapi-ado-jit-v8.0.5) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/net8-minapi-ado-jit-v8.0.5_summary.txt) |
| net8-minapi-dapper-jit-v2.1.35 | 16641 | 1655.71719161188 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/net8-minapi-dapper-jit-v2.1.35) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/net8-minapi-dapper-jit-v2.1.35_summary.txt) |
| net8-minapi-norm-jit-v5.4.0 | 16401 | 1633.2765316050677 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/net8-minapi-norm-jit-v5.4.0) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/net8-minapi-norm-jit-v5.4.0_summary.txt) |
| fastify-app-v4.26.1 | 16287 | 1619.39254748701 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/fastify-app-v4.26.1) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/fastify-app-v4.26.1_summary.txt) |
| express-app-v4.18.2 | 12497 | 1241.2275781549447 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/express-app-v4.18.2) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/express-app-v4.18.2_summary.txt) |
| java21-spring-boot-v3.2.2 | 11618 | 1149.2032119415896 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/java21-spring-boot-v3.2.2) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/java21-spring-boot-v3.2.2_summary.txt) |
| net8-minapi-ef-jit-v8.0.10 | 10492 | 1040.7790824632668 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/net8-minapi-ef-jit-v8.0.10) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/net8-minapi-ef-jit-v8.0.10_summary.txt) |
| go-app-v1.22.9 | 7777 | 770.3826543274147 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/go-app-v1.22.9) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/go-app-v1.22.9_summary.txt) |
| postgrest-v12.2.3 | 6272 | 611.3536207356975 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/postgrest-v12.2.3) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/postgrest-v12.2.3_summary.txt) |
| fastapi-app-v0.103.2 | 4713 | 463.31483994503816 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/fastapi-app-v0.103.2) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/fastapi-app-v0.103.2_summary.txt) |
| rust-app-v1.75.0 | 4565 | 448.07314407487564 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/rust-app-v1.75.0) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/rust-app-v1.75.0_summary.txt) |
| django-app-v5.0.9 | 3012 | 218.8683662805552 | 0 | [source](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/django-app-v5.0.9) | [summary](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/_k6/results/202411101305/django-app-v5.0.9_summary.txt) |

Notes:

- There is something wrong with [Deno service](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/deno-app-v1.40.2), couldn't make it work with K6 framework.
- There is something wrong with [Rust service](https://github.com/vb-consulting/pg_function_load_tests/tree/master/src/rust-app-v1.75.0). It shouldn't be that slow.

## License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.