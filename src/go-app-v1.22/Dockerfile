FROM golang:1.22-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev

# Copy source code
COPY main.go ./

# Initialize Go module and get dependencies
RUN go mod init testapp && \
    go get github.com/lib/pq && \
    go mod tidy

# Build the application
RUN go build -o main .

# Document that the container listens on port 5200
EXPOSE 5200

# Run the application
CMD ["./main"]