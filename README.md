<img src="img/city_emblem.png" alt="City Logo"/>

# City of Cape Town - Data Analytics Hub Devops Challenge

Welcome to the technical assessment for the Senior DevOps Engineer position at the City's Data Analytics Hub. We appreciate you taking the time to complete this challenge.

The goal of this assessment is to evaluate your practical skills in building and automating a modern, containerized application stack. We are interested in your approach, your understanding of best practices, and the quality of your implementation.

**Estimated time to complete: 3-5 hours**

---

## Scenario

You have been tasked with containerizing and creating a CI/CD pipeline for a new Python-based microservice. This service is a small component of our larger data analytics platform. It needs to interact with a Minio S3-compatible object storage service. Your mission is to automate the deployment of this stack.

You will need a Linux environment (Ubuntu 20.04+ or similar) with Docker and Docker Compose installed. You'll create bash scripts to automate the deployment process that would normally be handled by a CI/CD tool.

## Core Technologies

You will be expected to use the following technologies:

- **Docker & Docker Compose**: For containerization and service orchestration
- **Bash scripting**: For automation and deployment scripts
- **Minio**: As the S3-compatible object storage solution
- **Python**: The language of the application
- **Git**: For version control

## Provided Resources

The `resources/` directory contains:
- `app.py` - A Python Flask application that interacts with Minio
- `requirements.txt` - Python dependencies for the application

---

## Your Tasks

### Task 1: Containerize the Application

The `resources/` directory contains a simple Python Flask application (`app.py`).

1. Create a `Dockerfile` in the project root for the Python application
2. The Docker image should be production-ready:
   - Optimized for size (consider multi-stage builds)
   - Security-hardened (run as non-root user, minimal base image)
   - Include appropriate health checks
   - Use gunicorn as the production WSGI server
3. Ensure all dependencies from `requirements.txt` are installed correctly

**Challenge Element**: When you examine the application code, you'll notice it has a deliberate inefficiency in how it handles S3 connections. Identify this issue in your submission comments and implement a fix either in the application code or through environment configuration.

### Task 2: Orchestrate the Services

Create a `docker-compose.yml` file in the root of the repository to define and run the application stack.

1. The stack must consist of at least two services:
   - `data-app`: Your containerized Python application
   - `minio`: The official Minio image (minio/minio)

2. **Networking**: 
   - Services must communicate on a custom bridge network
   - The data-app should NOT be accessible from the host on its native port
   - Only expose what's necessary to the outside world

3. **Data Persistence**: 
   - Minio's data must persist across container restarts
   - Use named volumes with appropriate configurations

4. **Configuration**:
   - Use environment variables for Minio connection details
   - **Do NOT hardcode secrets** - use `.env` file (which should be in `.gitignore`)
   - Provide a `.env.example` file with placeholder values

**Challenge Element**: Your deployment script will need to verify the services are running correctly. Design your networking and service exposure strategy to accommodate health checks while maintaining security best practices.

### Task 3: Create Deployment Automation Scripts

Create bash scripts to automate the deployment process. At minimum, you should create:

1. **`scripts/deploy.sh`** - Main deployment script that:
   - Checks prerequisites (Docker, Docker Compose installed)
   - Validates environment configuration
   - Runs linting on the Python code (using pylint or flake8)
   - Builds the Docker image with appropriate tagging
   - Performs a basic security check on the Docker image (e.g., checking for vulnerabilities)
   - Deploys the stack using Docker Compose
   - Verifies the deployment was successful
   - Provides clear output and error messages

2. **`scripts/test.sh`** - Testing script that:
   - Runs unit tests for the application (you'll need to create at least 2 basic tests in `tests/test_app.py`)
   - Exits with appropriate error codes for CI/CD integration

3. **`scripts/health-check.sh`** - Post-deployment verification script that:
   - Checks if services are running
   - Verifies the application can connect to Minio
   - Performs a basic operation (upload/retrieve test data)
   - Returns clear success/failure status

**Challenge Elements**: 
- Implement proper error handling - if deployment fails, the old version should remain running
- Scripts should be idempotent (safe to run multiple times)
- Include rollback functionality in case of deployment failure
- Use proper bash scripting best practices (error handling, logging, parameter validation)

### Task 4: Documentation & Testing

1. Create a `.gitignore` file to exclude unnecessary files

2. Create basic unit tests in `tests/test_app.py` (at least 2 tests)

3. Add a `DEPLOYMENT.md` file that includes:
   - Prerequisites for running this stack
   - Step-by-step deployment instructions
   - How to run the deployment scripts
   - Troubleshooting section with at least 3 common issues and their solutions
   - How to verify the deployment was successful
   - How to perform a rollback
   
4. Update the main `README.md` with:
   - Architecture diagram (ASCII art is fine, or use a tool like Mermaid)
   - Environment variables documentation
   - Script usage instructions
   - Any assumptions you made during implementation

**Challenge Element**: In your documentation, include a "Day 2 Operations" section describing how you would handle a scenario where Minio becomes unavailable while the application is running. What happens to the application? How would you detect this? How would you recover?

---

## Submission Guidelines

1. Fork this repository to your own GitHub account
2. Create a new branch for your work (e.g., `submission/your-name`)
3. Complete all tasks on your branch with logical, atomic commits
4. When finished, push your branch and create a Pull Request to **your fork's** main branch
5. In the PR description, include:
   - A brief summary of your implementation approach
   - Any assumptions or decisions you made
   - Known limitations or areas for improvement
   - Estimated time spent on the assessment
   - Instructions for testing your submission
6. Share the link to your Pull Request with us
7. **Do not merge the Pull Request** - we will review it as submitted

---

## Testing Your Submission

Before submitting, ensure you can run the following successfully on a fresh Linux system with Docker and Docker Compose installed:

```bash
# Clone your repository
git clone <your-fork-url>
cd <repository-name>

# Copy and configure environment
cp .env.example .env
# Edit .env with appropriate values

# Run deployment
./scripts/deploy.sh

# Run tests
./scripts/test.sh

# Verify health
./scripts/health-check.sh
```

---

## Important Notes

- We value working solutions over perfect solutions - ship something that works first
- Feel free to ask clarifying questions via email
- Your commit history tells a story - make it a good one
- Comments in code should explain "why," not "what"
- All scripts should be executable (`chmod +x scripts/*.sh`)
- Scripts should include proper shebang lines (`#!/bin/bash`)

**Good luck! We're excited to see your approach to solving these challenges.**
