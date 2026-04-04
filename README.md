```
CI/CD Pipeline Project with Jenkins, Maven, and Docker

#Project Overview
----------------
This project demonstrates a full Continuous Integration (CI) and Continuous Deployment (CD) pipeline using Jenkins, Maven, Docker, and GitHub.
 
Whenever code is pushed to GitHub:

Jenkins automatically builds the project using Maven.
Creates a Docker image of the application.
Pushes the image to DockerHub.
Runs a Docker container hosting the application.
Ensures the updated application is live and accessible.

---

#Prerequisites
------------- 

Before starting, ensure the following tools and accounts are available:

Jenkins installed (http://localhost:8080)
GitHub account and repository
Docker Desktop installed
DockerHub account (to push Docker images)
Git installed
Java JDK installed
Maven installed (or configure via Jenkins)
ngrok account (optional: exposes public URL for Jenkins if using localhost)


#Project Structure
-----------------

```text
myapp/
│
├── Jenkinsfile           # Pipeline definition for Jenkins 
├── Dockerfile            # Instructions to build Docker image
├── pom.xml               # Maven configuration file
├── src/
│   ├── main/java/com/mycompany/app/App.java
│   └── test/java/com/mycompany/app/AppTest.java
└── README.md
```



#Setup Instructions
------------------

1. Maven Project
Create Maven project with the following structure:

```text
src/
├── main/java/com/mycompany/app/App.java
└── test/java/com/mycompany/app/AppTest.java
pom.xml
```
```markdown
pom.xml: Defines dependencies, plugins, and build steps.
Used by Maven to build the application artifact (.jar) in target/.
App.java: Contains the main application code.
Example: Spring Boot application with server running on 8080.
Server port: server.port=8080 (application port inside Docker container).

2. Dockerfile
Builds a Docker image of the application.
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/myapp-1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

3. Jenkins Configuration
Install Jenkins Plugins:GitHub integration Pipeline, Docker Pipeline

Global Credentials:
GitHub creds: for Jenkins to pull repo
DockerHub creds: to push images
Used in Jenkinsfile as github-creds and docker-creds.

Jenkinsfile: Define pipeline stages.
pipeline {
    agent any
    tools { maven 'Maven3' }
    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/<yourusername>/myapp.git'
            }
        }
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                    docker build -t myapp:latest .
                    echo $PASS | docker login -u $USER --password-stdin
                    docker tag myapp:latest <dockerhub-username>/myapp:latest
                    docker push <dockerhub-username>/myapp:latest
                    '''
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                sh '''
                docker rm -f myapp || true
                docker run -d -p 8081:8080 --name myapp <dockerhub-username>/myapp:latest
                '''
            }
        }
    }
    post {
        success { echo 'Application deployed successfully!' }
        failure { echo 'Build or deployment failed!' }
    }
}

4. GitHub Webhook
Purpose: Trigger Jenkins automatically on code push.

Setup:
Use ngrok public URL (or public server IP)
Configure webhook in GitHub → Settings → Webhooks
Event: push
Target URL: <ngrok-or-server-url>/github-webhook/

6. Running the Pipeline
Push code changes to GitHub (main branch).
Jenkins webhook triggers the pipeline.
Pipeline stages execute:
Maven build → creates .jar
Docker image build → push to DockerHub
Docker container runs → application accessible at http://<server-ip>:8081
Verify Docker container status:
docker ps

8. Continuous Integration & Deployment
Any subsequent code changes and pushes to GitHub automatically trigger the Jenkins pipeline.
Ensures CI/CD process keeps the application up-to-date.


⚠️ Note: Using ngrok on localhost gives a dynamic URL — not recommended for production. Use a public server for Jenkins in real-world scenarios. give me proper readme file of this to put in github so thth the indententation n project structure stays the same in preview as well
```

