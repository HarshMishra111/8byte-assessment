## 1. Project Overview

This project is based on deploying a web application on AWS using Terraform, Jenkins and Docker. The complete setup is divided into 3 phases.

The main objective of this project was to provision the required AWS infrastructure, create a CI/CD pipeline for application deployment and then setup infrastructure monitoring using AWS CloudWatch.

 Project Flow


Developer
    |
    v
GitHub Repository
    |
    v
Jenkins Pipeline
    |
    +---- Build
    +---- Test
    +---- Code Analysis
    +---- Security Scan
    +---- Docker Build
    +---- Docker Image Push
    |
    v
Ubuntu EC2
    |
    v
Docker Container
    |
    v
Application
    |
    v
CloudWatch Monitoring
    |
    v
SNS Alerts

## 2. Technologies Used

| Category               | Tools / Services |
| ---------------------- | ---------------- |
| Cloud                  | AWS              |
| Infrastructure as Code | Terraform        |
| Source Code Management | Git, GitHub      |
| CI/CD                  | Jenkins          |
| Build Tool             | Maven            |
| Containerization       | Docker           |
| Container Security     | Trivy            |
| Deployment Server      | Ubuntu EC2       |
| Monitoring             | AWS CloudWatch   |
| Alerting               | Amazon SNS       |
| Operating System       | Ubuntu Linux     |
| Scripting              | Bash / Shell     |
| Version Control        | Git              |

## 3. Project Phases

3.1. Phase 1 – Infrastructure Provisioning using Terraform

""AWS Resources Provisioned""

The Terraform configuration was used for provisioning the required AWS resources.

The main resources include:

* VPC
* Subnets
* Internet Gateway
* Route Tables
* Security Groups
* EC2 instances
* S3 resources
* RDS resources

Terraform Workflow

The Terraform workflow used for the project was:

Terraform Configuration > terraform init > terraform validate > terraform plan > terraform apply > AWS Infrastructure

### Initialize Terraform

```bash
terraform init
```

This downloads the required Terraform providers and initializes the working directory.

### Validate Configuration

```bash
terraform validate
```

This was used to check whether the Terraform configuration was syntactically correct.

### Review Infrastructure Changes

```bash
terraform plan
```

The plan was checked before applying the infrastructure changes.

### Provision Infrastructure

```bash
terraform apply
```

After reviewing the plan, the infrastructure was provisioned in AWS.

---

## 3.2. Phase 2 – Jenkins CI/CD Pipeline

## Objective

After provisioning the infrastructure, the next phase was to automate the application build and deployment process.

Jenkins was configured on the local machine and was used as the CI/CD server.

The application container was deployed on the Ubuntu EC2 instance created for the deployment.

The Jenkins server and application server are kept seperately so that the deployment machine can focus on running the application and infrastructure monitoring.

## CI/CD Pipeline Flow

The Jenkins pipeline follows the below process:

GitHub > Git Checkout > Maven Build > Unit Testing > Docker Image Build > Trivy Security Scan >Docker Image Push > SSH to Ubuntu EC2 > Pull Docker Image > Stop old container > Start New Container > Application Deployed


## Jenkins Pipeline Stages

## Stage 1 – Git Checkout

The pipeline fetches the latest application source code from the GitHub repository.

This makes sure Jenkins always works with the latest version of the application.

---

## Stage 2 – Build

Maven is used to compile the application and generate the required build artifacts.

Example:

```bash
mvn clean package
```

---

## Stage 3 – Testing

Automated test cases are executed using Maven.

```bash
mvn test
```

If the test stage fails, the pipeline should stop and the application should not be deployed.

---

## Stage 4 – Docker Image Build

After the application build is successful, a Docker image is created.

Example:

```bash
docker build -t <docker-image-name>:latest .
```

Docker allows the application and its required runtime dependencies to be packaged together.

---

## Stage 5 – Trivy Security Scan

The Docker image is scanned using Trivy before deployment.

Example:

```bash
trivy image <docker-image-name>:latest
```

The scan is used to identify known vulnerabilities in the image and its installed packages.

---

## Stage 6 – Docker Image Push

After the image passes the required checks, it is pushed to the configured container registry.

Example:

```text
Jenkins
   |
   v
Docker Build
   |
   v
Trivy Scan
   |
   v
Docker Registry
```

The EC2 server can then pull the image during deployment.

---

# 4. EC2 Deployment

The application is deployed on an Ubuntu EC2 instance.

Jenkins connects to the EC2 server through SSH and performs the deployment steps remotely.

The deployment process is:

```text
Jenkins
   |
   | SSH
   v
Ubuntu EC2
   |
   +--> Docker Pull
   |
   +--> Stop Old Container
   |
   +--> Remove Old Container
   |
   +--> Start New Container
   |
   v
Application Running
```

A typical deployment command sequence on the server is:

```bash
docker pull <image>:latest

docker stop <container-name> || true

docker rm <container-name> || true

docker run -d \
  --name <container-name> \
  -p <host-port>:<container-port> \
  <image>:latest
```

# 5. Deployment Verification

After deployment, the container can be checked using:

```bash
docker ps
```


The application can then be accessed using the EC2 public IP and configured application port.

Example:

```text
http://<EC2-PUBLIC-IP>:<PORT>
```

---

# Phase 3 – Infrastructure Monitoring

## Objective

After deploying the application, the third phase was to setup monitoring for the AWS infrastructure.

AWS CloudWatch was used for monitoring the EC2 deployment server.

The main goal was to monitor the health and resource utilization of the EC2 instance and identify issues before they impact the application.

---

# 6. CloudWatch Monitoring Architecture

```text
                 Ubuntu EC2
                     |
          +----------+----------+
          |          |          |
         CPU       Memory      Disk
          |          |          |
          +----------+----------+
                     |
                     v
              CloudWatch Agent
                     |
                     v
               AWS CloudWatch
                     |
          +----------+----------+
          |                     |
       Dashboard              Alarms
                                |
                                v
                               SNS
                                |
                                v
                             Email
```

---

# 7. IAM Configuration for Monitoring

An IAM role was associated with the EC2 instance so that the CloudWatch Agent could communicate with AWS services.

The required permissions include:

```text
AmazonSSMManagedInstanceCore
CloudWatchAgentServerPolicy
```

`AmazonSSMManagedInstanceCore` is used for Systems Manager communication and management of the EC2 instance.

`CloudWatchAgentServerPolicy` provides permissions required by the CloudWatch Agent to publish monitoring information.

---

# 8. CloudWatch Agent

The CloudWatch Agent was configured on the Ubuntu EC2 server.

The agent allows additional system-level metrics to be collected which are not available through the basic EC2 monitoring.

The monitoring configuration includes metrics such as:

* CPU utilization
* Memory utilization
* Disk utilization
* Disk space
* Network activity

The agent can also be used for collecting application and system logs.

---

# 9. CloudWatch Dashboard

A CloudWatch dashboard was created for monitoring the deployment EC2 instance.

The dashboard contains important infrastructure metrics such as:

```text
CPU Utilization
Memory Utilization
Disk Utilization
Network Traffic
```

<img width="1913" height="763" alt="image" src="https://github.com/user-attachments/assets/26e229d4-817c-4a92-ab0b-8828492e237e" />
<img width="1769" height="838" alt="image" src="https://github.com/user-attachments/assets/c4463ffa-fac5-45d0-996d-34ba0d397e9c" />


# 10. CloudWatch Alarms

CloudWatch alarms were configured for important infrastructure conditions.

Examples of configured thresholds:

| Metric             | Threshold | Purpose                         |
| ------------------ | --------: | ------------------------------- |
| CPU Utilization    |    >= 80% | Detect high CPU usage           |
| Memory Utilization |    >= 80% | Detect high memory usage        |
| Disk Utilization   |    >= 80% | Detect low available disk space |

The exact thresholds can be changed based on the application and server requirements.

---

# 11. SNS Notifications

Amazon SNS was used for sending notifications when a CloudWatch alarm enters the alarm state.

The notification flow is:

```text
EC2
 |
 v
CloudWatch Metric
 |
 v
CloudWatch Alarm
 |
 | Threshold crossed
 v
SNS Topic
 |
 v
Email Notification
```

For example:

```text
CPU Utilization
       |
       | >= 80%
       v
CloudWatch Alarm
       |
       v
SNS
       |
       v
Email Alert
```

This allows the infrastructure issue to be noticed without continuously checking the CloudWatch dashboard.

---

# 12. Monitoring Use Cases

The monitoring setup can be used for scenarios such as:

### High CPU

If the application server CPU stays above the configured threshold, CloudWatch changes the alarm state and sends an SNS notification.

Possible investigation:

```bash
top
```

or:

```bash
docker stats
```

---

### High Memory

If memory usage increases continuously, the CloudWatch alarm can notify the administrator.

Possible checks:

```bash
free -h
```

and:

```bash
docker stats
```

---

### High Disk Usage

If disk usage approaches the configured limit, an alarm can be generated.

Possible checks:

```bash
df -h
```

Docker storage can also be checked using:

```bash
docker system df
```

---



# 13. Security Considerations

The following security practices were considered during the implementation:

* SSH access should be restricted to trusted IP addresses.
* EC2 should not expose unnecessary ports.
* IAM roles should be used instead of storing AWS access keys on the EC2 server.
* Jenkins credentials should be stored in Jenkins Credentials rather than directly inside the Jenkinsfile.
* Docker images should be scanned before deployment.
* Secrets and private keys should not be committed to GitHub.
* Terraform state files should be handled carefully and should not be committed to a public repository.
* Security groups should only allow required traffic.

Files such as the following should not be pushed to GitHub:

```text
*.pem
terraform.tfstate
terraform.tfstate.*
.env
credentials
secrets
```

A `.gitignore` file should be maintained for these files.

---

# 14. Repository Structure

The repository is organised approximately as follows:

```text
8byte-assessment/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── ...
│
├── application/
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
│
├── Jenkinsfile
│
├── .gitignore
│
└── README.md
```

The actual folder structure may differ slightly depending on the application source and Terraform configuration.

---

# 15. Complete Project Workflow

The complete implementation can be represented as:

```text
                    PHASE 1
              Terraform Provisioning
                       |
                       v
              AWS Infrastructure
                       |
                       v
                    PHASE 2
                 GitHub Source
                       |
                       v
                   Jenkins
                       |
        +--------------+--------------+
        |              |              |
      Maven         SonarQube       Trivy
        |              |              |
        +--------------+--------------+
                       |
                       v
                  Docker Build
                       |
                       v
                 Docker Registry
                       |
                       v
                 SSH Deployment
                       |
                       v
                 Ubuntu EC2
                       |
                       v
                Docker Container
                       |
                       v
                   Application
                       |
                       v
                    PHASE 3
                 CloudWatch
                       |
             +---------+---------+
             |         |         |
            CPU      Memory     Disk
             |         |         |
             +---------+---------+
                       |
                       v
                  CloudWatch
                    Alarm
                       |
                       v
                      SNS
                       |
                       v
                     Email
```

---

# 16. Result

After completing all three phases, the project provides:

* Infrastructure provisioned through Terraform
* Source code maintained in GitHub
* Automated CI/CD using Jenkins
* Maven based application build and testing
* Trivy container security scanning
* Docker based application deployment
* Application deployed on Ubuntu EC2
* Infrastructure monitoring through CloudWatch
* CPU, memory, disk and network monitoring
* CloudWatch alarms for infrastructure issues
* SNS based email notifications
