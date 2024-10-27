
# Blue-Green Deployment

## Overview

This repository contains an implementation of the Blue-Green Deployment strategy, which allows for seamless application updates with minimal downtime. This approach involves maintaining two identical environments: **Blue** (current live version) and **Green** (new version). This allows for quick switching between versions to ensure high availability and reliability.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Setup](#setup)
- [Usage](#usage)
- [Deployment Process](#deployment-process)
- [Contributing](#contributing)
- [License](#license)

## Features

- Seamless switching between Blue and Green environments
- Automated deployment and rollback capabilities
- Integration with CI/CD pipelines
- Monitoring and logging for both environments

## Architecture

![Architecture Diagram][architecture.png]

This diagram illustrates the architecture of the Blue-Green Deployment strategy implemented in this project.

## Setup

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Kubernetes](https://kubernetes.io/docs/setup/)
  
### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/blue-green-d.git
   cd blue-green-d
   ```

2. Build the Docker images:
   ```bash
   docker build -t your-image-name:latest .
   ```

3. Deploy to Kubernetes:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   ```

## Usage

To switch between Blue and Green environments, use the following commands:

- To set the Green environment live:
   ```bash
   kubectl apply -f k8s/green-service.yaml
   ```

- To set the Blue environment live:
   ```bash
   kubectl apply -f k8s/blue-service.yaml
   ```

## Deployment Process

The deployment process for the Blue-Green Deployment strategy is organized into several clear stages, integrated into a CI/CD pipeline. This ensures a smooth transition from the development phase to production. The stages are as follows:

## Deployment Process

The deployment process for the Blue-Green Deployment strategy is structured into several stages within the CI/CD pipeline, ensuring a seamless transition from development to production. The stages are as follows:

### 1. **Code Checkout**
   - Developers push code changes to the repository.
   - The CI/CD pipeline is triggered, checking out the latest code:
     ```bash
     git checkout main
     ```

### 2. **SonarQube Analysis**
   - Perform static code analysis using SonarQube to ensure code quality and maintainability.
   - Any issues are reported, and developers must address them before proceeding.

### 3. **Build Stage**
   - **Docker Build:**
     - Build the Docker image from the updated code:
       ```bash
       docker build -t your-image-name:latest .
       ```

   - **Docker Push:**
     - Push the newly built image to a container registry:
       ```bash
       docker push your-image-name:latest
       ```

### 4. **Security Scanning**
   - **Trivy Scan:**
     - Scan the Docker image for vulnerabilities using Trivy:
       ```bash
       trivy image your-image-name:latest
       ```
   - Review scan results and address any critical vulnerabilities.

### 5. **Database Setup**
   - **MySQL Service Deployment:**
     - Deploy or update the MySQL service required by the application. Ensure the database schema is up to date.

### 6. **Deploy to Green Environment**
   - Deploy the application using Kubernetes manifests to the Green environment:
     ```bash
     kubectl apply -f k8s/green-deployment.yaml
     ```

### 7. **Traffic Switch**
   - Once deployed, switch the production traffic to the Green environment:
     ```bash
     kubectl apply -f k8s/green-service.yaml
     ```

### 8. **Verification Stage**
   - Verify the deployment by conducting:
     - **Smoke Tests:** Check basic functionality.
     - **End-to-End Tests:** Ensure the entire application workflow functions correctly.
     - **Load Testing:** Validate performance under expected load.

### 9. **Monitoring and Validation**
   - Monitor the application using monitoring tools (e.g., Prometheus, Grafana) to track metrics and logs.
   - Gather user feedback to identify any issues.

### 10. **Rollback (if needed)**
   - If issues are detected, quickly rollback to the Blue environment:
     ```bash
     kubectl apply -f k8s/blue-service.yaml
     ```

### 11. **Cleanup Stage**
   - After successful validation and stabilization of the Green environment, decommission the Blue environment or prepare it for the next deployment cycle.



## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Blue-Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html) - Martin Fowler
- [Aditya](https://github.com/jaiswaladi246)
- Other resources and inspirations.
```

