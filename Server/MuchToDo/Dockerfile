# Stage 1: Build
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

WORKDIR /app

# Copy dependency files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
# CGO_ENABLED=0 for a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api/main.go

# Stage 2: Final Run Image
FROM alpine:3.18

# Create a non-root user
RUN adduser -D appuser
WORKDIR /home/appuser

# Install curl for health checks
RUN apk add --no-cache curl

# Copy binary from builder
COPY --from=builder /app/main .

# Use non-root user
USER appuser

# Environment variables (Defaults)
ENV PORT=8080
ENV MONGODB_URI=mongodb://mongodb:27017/todoapp

EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["./main"]