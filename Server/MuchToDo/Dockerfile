# Stage 1: Build
FROM golang:1.25-alpine AS builder
WORKDIR /app

# Copy Go modules first
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire source code
COPY . .
RUN go mod tidy
# Build from the cmd directory
RUN go build -o backend ./cmd/api

# Stage 2: Run
FROM alpine:latest
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=builder /app/backend .

EXPOSE 3000
CMD ["./backend"]