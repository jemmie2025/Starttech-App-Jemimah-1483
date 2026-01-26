# MuchToDo API

This assessment demonstrates a complete DevOps workflow for the MuchToDo backend API.
The application was containerized using Docker, orchestrated locally with Docker Compose, and deployed to Kubernetes using Deployments, ReplicaSets, Services, and Ingress.
MongoDB persistence was implemented, and application health was verified via exposed health endpoints.
Evidence of successful deployment and service availability is included.

# MuchToDo Backend API – DevOps Assessment

MuchToDo is a backend task-management application built with *Golang* and *MongoDB*, designed for productivity, reliability, and scalability.  
This project demonstrates a *real-world DevOps workflow*, covering containerization, orchestration, health monitoring, and persistent storage.

##  Tech Stack
	•	Language: Golang
	•	Database: MongoDB
	•	Containerization: Docker
	•	Local Orchestration: Docker Compose
	•	Container Orchestration: Kubernetes (Kind)
	•	CLI Tools: kubectl, Docker CLI, Git Bash, PowerShell


 ##   Skills Demonstrated
	•	Docker containerization
	•	Docker Compose orchestration
	•	Kubernetes deployment & scaling
	•	NodePort & Ingress networking
	•	Persistent storage using PVCs
	•	Health monitoring & self-healing

##  Clone Forked Repository

Clone *forked repository* from GitHub:


git clone https://github.com/jemmie2025/much-to-do-.git

cd much-to-do
##  Docker Workflow

docker build -t muchtodo-backend . (Build backend image)
docker compose up -d --build (Start Services With Docker Compose)
docker ps (Verify Containers)
docker logs muchtodo-backend (View Backend Logs)

##  Kubernetes Workflow

 kind create cluster --name muchtodo (Create Kind Cluster)
 kubectl get nodes (Verify Cluster)
 kubectl apply -f kubernetes/ (Apply Kubernetes Manifests)

##  Kubernetes Verification Commands

kubectl get all -n muchtodo (Get All Resources)
 kubectl get ns (Get Names)
 kubectl get pods -n muchtodo (Get Pods)

 kubectl get deployment -n muchtodo (Get Deployments)
 kubectl get svc -n muchtodo (Get Replicas)
 kubectl get ingress -n muchtodo (Get Ingress)


##  Accessing The Application
The backend runs on port 3000 inside the cluster and is exposed via NodePort 30473.

 kubectl port-forward svc/backend 30473:3000 -n muchtodo (Port Forward Service)

curl http://localhost:30473/health -UseBasicParsing (Health Check Test PowerShell)

     Expected Response:
{
  "cache": "disabled",
  "database": "ok"
}


##  Evidence Screenshots
What each proves:
	•	pods → workloads running
	•	services → NodePort & ClusterIP
	•	get all → full cluster state
	•	replicaset → scaling & availability
	•	ingress → external routing
	•	health check → app + DB working

##  Conclusion

The MuchToDo Backend API demonstrates a complete DevOps lifecycle — from local Docker development to Kubernetes deployment with scaling, health checks, ingress, and persistence.
This implementation satisfies the assessment requirements and reflects real-world backend infrastructure practices.

