# Use official Golang image
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o core-engine .

# Final stage
FROM alpine:latest

WORKDIR /root/

# Install CA certificates for HTTPS calls (needed for Spotify API)
RUN apk --no-cache add ca-certificates

COPY --from=builder /app/core-engine .

# Default port (can be overridden by env var)
EXPOSE 8080

# Command to run
CMD ["./core-engine"]
