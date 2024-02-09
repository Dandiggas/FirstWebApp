# Flask Web Application Deployment

## Overview
This project demonstrates a comprehensive deployment of a Flask web application using Docker, AWS EC2, ECS, Auto Scaling, and Terraform. The application is containerized using Docker and deployed to an AWS EC2 instance. Infrastructure management is automated using Terraform, and the CI/CD pipeline is set up with GitHub Actions.

## Key Features
- **Dockerization:** Containerization of the Flask application for consistent deployment.
- **AWS EC2 Deployment:** Hosting the containerized application on AWS EC2 instance for high availability.
- **AWS ECS and Auto Scaling:** Leveraging ECS for container orchestration and Auto Scaling for handling load efficiently.
- **Terraform:** Infrastructure as Code to provision and manage AWS resources systematically.
- **GitHub Actions CI/CD:** Automated build and deployment pipeline using GitHub Actions.

## Deployment Architecture
- **AWS VPC:** Set up with a custom CIDR block, enabling a secure and isolated network.
- **AWS Subnet:** Configured for the VPC, ensuring proper network segmentation.
- **Internet Gateway & Route Table:** For enabling access to and from the Internet.
- **Security Group:** Configured to allow HTTP, SSH, and custom application port traffic.
- **ECS Cluster & Task Definition:** For managing and running containerized applications.
- **Auto Scaling Group:** To automatically adjust the capacity of the application to maintain steady performance.
- **IAM Roles and Policies:** Ensuring secure access control to AWS resources.

## Terraform Configuration
The Terraform configuration files are used to create the necessary AWS infrastructure, including VPC, subnet, internet gateway, route table, security group, ECS cluster, and more. This infrastructure as code approach ensures a reliable and repeatable way to set up the AWS environment.

## GitHub Actions Workflow
The GitHub Actions workflow is configured for continuous integration and continuous deployment (CI/CD). It automates the process of building the Docker image, pushing it to Amazon ECR, and applying Terraform configurations to update the AWS infrastructure.

## Running the Project
To run this project, you will need to have Docker, AWS CLI, and Terraform installed on your machine.

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Dandiggas/FirstWebApp
   cd FirstWebApp
   ```

2. **Build and Run the Docker Container:**
   ```bash
   docker build -t flask-app .
   docker run -p 8000:8000 flask-app
   ```

3. **Terraform Initialization and Application:**
   ```bash
   terraform init
   terraform apply
   ```

## Contributing
Contributions are welcome. Please adhere to the standard fork, branch, and pull request workflow.

## License
[Specify License]

## Contact
For any inquiries or contributions, please contact [Your Name] at [Your Email].

---

This project showcases my proficiency in deploying web applications using Flask, Docker, AWS, Terraform, and GitHub Actions, demonstrating a thorough understanding of modern deployment strategies and cloud infrastructure management.