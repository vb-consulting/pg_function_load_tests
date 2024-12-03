FROM ghcr.io/omnigres/omnigres-slim

COPY init.sql /docker-entrypoint-initdb.d/100-init.sql
COPY app.sql  /docker-entrypoint-initdb.d/200-app.sql
