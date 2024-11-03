# Load Performance Testing for Web APIs Returning a Single PostgreSQL Function

This project performs load performance testing for Web APIs on different tech stack that will execute a single PostgreSQL function and return the result.

## Running Manually

```
git clone https://github.com/vb-consulting/pg_function_load_tests.git
cd src
docker-compose up --build
```

Please wait a few seconds for all services to initialize properly (health check isn't implemented yet), and then run from the same directory:

```
docker-compose exec test /bin/sh /scripts/run.sh
```

Results will be save to `/results/` directory under current timestamp.


## Results

todo

## License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.