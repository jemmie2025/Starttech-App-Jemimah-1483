# StartTech Application

This repository contains the frontend and backend services for the **StartTech** platform, including CI/CD pipelines, containerization, and AWS deployment assets.

The platform provides user authentication, task management, health checks, structured logging, and automated deployment to AWS.


## Architecture Overview

- **Frontend**: React + TypeScript application built with Vite.
- **Backend**: Go RESTful API built with the Gin framework.
- **Database**: MongoDB for persistent data storage.
- **Cache**: Redis for caching and performance optimisation.
- **Containerisation**: Docker images for frontend and backend.
- **CI/CD**: GitHub Actions pipelines.
- **Deployment**: AWS (EC2, Application Load Balancer, S3, CloudFront).

At a high level:

- The frontend is built into static assets and served from an S3 bucket behind a CloudFront distribution.
- The backend API runs behind an Application Load Balancer (ALB).
- A dedicated CloudFront distribution sits in front of the ALB to provide HTTPS for the API and avoid mixed-content issues when called from the HTTPS frontend.

---

## Features

- User registration, login, and authentication (JWT-based).
- Task/ToDo management (create, read, update, delete).
- Health check endpoints for monitoring.
- Structured logging for observability.
- Optional Redis-backed caching.
- CORS configuration to allow the deployed frontend to call the backend securely.

---

## Tech Stack

- **Frontend**: React, TypeScript, Vite, Node.js (18+).
- **Backend**: Go (1.25+), Gin.
- **Database**: MongoDB.
- **Caching**: Redis.
- **Infrastructure**: Docker, Docker Compose, AWS EC2, ALB, S3, CloudFront.
- **CI/CD**: GitHub Actions.

---

## Local Development

### Prerequisites

- Node.js **18+**
- Go **1.25+**
- Docker **20.10+** and Docker Compose
- Git

### Frontend

From the project root:

```bash
cd frontend
npm install
npm run dev
```

Access the app at:

```text
http://localhost:5173
```

### Backend

From the project root:

```bash
cd backend/MuchToDo
go mod download
go run ./cmd/api/main.go
```

The API will be available at:

```text
http://localhost:8080
```

### Docker

Build and run services using Docker images.

- **Build frontend image**:

	```bash
	docker build -t starttech-frontend:latest frontend/
	```

- **Build backend image**:

	```bash
	docker build -t starttech-backend:latest backend/MuchToDo/
	```

- **Run frontend container**:

	```bash
	docker run -p 3000:3000 starttech-frontend:latest
	```

- **Run backend container**:

	```bash
	docker run -p 8080:8080 starttech-backend:latest
	```

### Docker Compose

From the backend/MuchToDo directory:

```bash
cd backend/MuchToDo
docker-compose up -d
```

Useful commands:

```bash
docker-compose logs -f
docker-compose down
```

This starts MongoDB, Redis, and the backend API wired together using the provided docker-compose configuration.

---

## Configuration

### Frontend Environment

The frontend uses Vite environment variables (in a `.env` file in the frontend directory).

Key variables:

- `VITE_API_BASE_URL` – Base URL of the backend API.

For the current deployed setup, the frontend is configured to call the backend via its CloudFront distribution:

```dotenv
VITE_API_BASE_URL=https://d2b1vhoymeqvxy.cloudfront.net
```

### Backend Environment

The backend reads configuration from `.env` in backend/MuchToDo and from environment variables.

Key variables:

- `PORT` – API server port (default `8080`).
- `MONGO_URI` – MongoDB connection string.
- `DB_NAME` – MongoDB database name.
- `ENABLE_CACHE` / `REDIS_ADDR` – Redis caching configuration.
- `JWT_SECRET_KEY` – Secret used to sign JWTs.
- `ALLOWED_ORIGINS` – Comma-separated list of allowed CORS origins.
- `COOKIE_DOMAINS` – Comma-separated list of cookie domains.
- `SECURE_COOKIE` – Enables secure cookies over HTTPS.

For the current configuration in backend/MuchToDo/.env, the important pieces are:

```dotenv
MONGO_URI=mongodb://root:example@mongodb:27017/much_todo_db?authSource=admin
DB_NAME=much_todo_db

ALLOWED_ORIGINS="http://localhost:5173,http://localhost:3000,https://d2b1vhoymeqvxy.cloudfront.net"
COOKIE_DOMAINS="localhost,d2b1vhoymeqvxy.cloudfront.net"
SECURE_COOKIE=true
```

In production, mirror these values via your infrastructure (EC2/ECS task definitions, SSM Parameter Store, or similar), adjusting `MONGO_URI` for your actual MongoDB/Atlas deployment.

---

## AWS Deployment

### Frontend (S3 + CloudFront)

- The frontend is built with:

	```bash
	cd frontend
	npm run build
	```

- The build output is written to frontend/dist.
- The dist folder is synced to an S3 bucket (for example, `prod-frontend-816212136006`) and served via a CloudFront distribution.

Example sync command (from the frontend directory, with AWS CLI configured):

```bash
aws s3 sync dist s3://prod-frontend-816212136006 --delete
```

After uploading, create a CloudFront invalidation for `/*` so users see the latest build.

### Backend (ALB + CloudFront + MongoDB)

The backend API is deployed behind an AWS Application Load Balancer (ALB). To avoid browser mixed-content issues (HTTPS frontend calling HTTP backend), a dedicated CloudFront distribution is configured in front of the ALB.

- **Origin**: ALB DNS name (e.g. `prod-alb-1942829792.us-east-1.elb.amazonaws.com`).
- **Origin protocol policy**: `HTTP only` (ALB listens on HTTP).
- **Viewer protocol policy**: `Redirect HTTP to HTTPS` (clients always use HTTPS).
- **Allowed HTTP methods**: `GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE`.

The resulting backend CloudFront domain (currently):

```text
https://d2b1vhoymeqvxy.cloudfront.net
```

This URL is used by the frontend as `VITE_API_BASE_URL` so that all API calls are HTTPS end-to-end.

Health checks and routing:

- The backend exposes `/health` for ALB and CloudFront health checks.
- The ALB target group should health-check `HTTP` on the backend port (8080) at path `/health`.
- When instances are healthy and the app is running, `/health` via ALB and via the backend CloudFront URL should both return `200 OK`.

---

## Testing

### Frontend

From the frontend directory:

```bash
npm test
```

With coverage:

```bash
npm test -- --coverage
```

### Backend

From backend/MuchToDo:

```bash
go test ./...
```

Integration tests:

```bash
INTEGRATION=true go test -v --tags=integration ./...
```

---

## Security

- JWT-based authentication and password hashing.
- Input validation and sanitisation.
- CORS and HTTPS configuration to secure browser ↔ API communication.
- Secrets managed via `.env` files and GitHub Secrets.
- Regular security scanning can be integrated (e.g. gosec, Trivy).

---

## Contributing

1. Create a feature branch:

	 ```bash
	 git checkout -b feature/your-feature-name
	 ```

2. Commit and push your changes:

	 ```bash
	 git commit -m "Add feature"
	 git push origin feature/your-feature-name
	 ```

3. Open a Pull Request against `main`.

All tests should pass before merging.

---

## Support

- Check application logs (frontend, backend, and Docker) and CI/CD workflow runs.
- Verify environment variables and service status (Docker, MongoDB, Redis, AWS resources).
- For deployment issues, verify:
	- ALB target health and `/health` endpoint.
	- CloudFront origins, behaviours, and invalidations.
	- Frontend `VITE_API_BASE_URL` matches the backend CloudFront domain.

If issues persist, open an issue with:

- Error messages and logs.
- Steps to reproduce.
- Environment details (local, staging, production).

---

_Last updated: February 2026 • Node 18+ • Go 1.25+ • Docker 20.10+_

