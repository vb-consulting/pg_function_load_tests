FROM golang:1.22-alpine

WORKDIR /app
RUN apk add --no-cache gcc musl-dev
COPY main.go ./
RUN go mod init testapp && \
    go get github.com/lib/pq && \
    go mod tidy
RUN go build -o main .
EXPOSE 5200
CMD ["./main"]