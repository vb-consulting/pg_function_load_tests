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

## Results

### Round 1 

- [Test Branch](https://github.com/vb-consulting/pg_function_load_tests/tree/202411281042/src)
- [Test Results Raw Output](https://github.com/vb-consulting/pg_function_load_tests/tree/202411281042/src/_k6/results)
- [Parsed Tests Results Disucssion Thread](https://github.com/vb-consulting/pg_function_load_tests/discussions/2)

## License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.