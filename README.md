# Vote App – Phase 1: Containerization & Local Setup

## Overview

This is the multi-service **Voting App** from [Code Quests DevOps](https://github.com/code-quests/devops).  

**Goal:** Run the app locally using **Docker** and **Docker Compose** with:  

- Containerized services  
- Frontend/backend network separation  
- Health checks  
- Optional seed data  

Running `docker compose up` brings up the full app.

---

## Services

| Service    | Description                       | Port  | Notes                         |
|------------|-----------------------------------|-------|-------------------------------|
| `vote`     | Frontend to cast votes             | 8080  | Talks to `result` and `redis`|
| `result`   | Displays vote results              | 8081  | Talks to `postgres`           |
| `worker`   | Processes votes from queue         | n/a   | Talks to `redis` and `postgres` |
| `seed-data`| Adds test/demo data                | n/a   | Optional, run once            |
| `redis`    | In-memory message queue            | 6379  | Health check included         |
| `postgres` | Database storing results           | 5432  | Health check included         |

---

## Prerequisites

- Docker ≥ 24  
- Docker Compose ≥ 2  
- Git  

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/Vote-App.git
cd Vote-App

2. Build and run all services
docker compose up --build


Frontend (vote) → http://localhost:8080

Result (result) → http://localhost:8081

3. Network Architecture

Two-tier network separation:

frontend network: vote + result

backend network: worker + redis + postgres

This keeps backend services isolated and secure.

4. Health Checks

redis:

redis-cli ping


postgres:

pg_isready -U app


Docker Compose waits for these services to be ready before starting dependent services.

5. Seed Data (Optional)

Populate test/demo data:

docker compose run --rm seed-data

6. Exposed ports
Service	Port
vote	8080
Result	8081

7. Stopping the App
docker compose down


Stops all containers and removes networks.

Best Practices Implemented

Non-root Docker images for security

Minimal base images (alpine, python:slim)

Health checks for Redis and Postgres

Two-tier networks for frontend/backend isolation

Optional seed service to populate test data
