# Load Performance Testing for Web APIs Returning a Single PostgreSQL Function

This project performs load performance testing for Web APIs on different tech stacks that will execute a single [PostgreSQL function](https://github.com/vb-consulting/pg_function_load_tests/blob/master/src/postgres/init.sql) and return the result.

## Running Manually

```
git clone https://github.com/vb-consulting/pg_function_load_tests.git
cd pg_function_load_tests
cd src
docker-compose down && docker-compose up --build
```

Please wait a few seconds for all services to initialize properly (health check isn't implemented yet), and then run from the same directory:

```
docker-compose exec test /bin/sh /scripts/run.sh
```

Results will be saved to the `src/k6/results/` directory under the current timestamp subdirectory.

## Latest Results

- [Test Branch](https://github.com/vb-consulting/pg_function_load_tests/tree/202412231024/src)
- [Test Results Raw Output](https://github.com/vb-consulting/pg_function_load_tests/blob/202412231024/src/_k6/results/202412231024.md)
- [Parsed Tests Results Disucssion Thread](https://github.com/vb-consulting/pg_function_load_tests/discussions/5)

## License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
