FROM denoland/deno:1.40.2

WORKDIR /app
COPY deno.json .
COPY app.ts .
RUN deno cache app.ts
EXPOSE 3102

CMD ["deno", "task", "start"]