pipeline {
    agent any

    environment {
        IMAGE_NAME = "pavansarvepalli0/javaapp"
        GIT_REPO_NAME = "java-end-to-end"
        GIT_USERNAME = "pavan-sarvepalli"
        version = "v.1.0${BUILD_NUMBER}"
    }
    tools {
           maven 'maven3'
         }

   
    stages {

        stage('Git Checkout') {
            steps {
                echo "Cloning the project from GitHub"
                git branch: 'main', url: 'https://github.com/Pavan-sarvepalli/java-end-to-end.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    echo "Running SonarQube scan"
                    withCredentials([string(credentialsId: 'sonarpassword', variable: 'sonarpassword')]) {
                        sh 'ls -ltr'
                        sh """
                            mvn sonar:sonar \
                            -Dsonar.projectKey=java-end-to-end \
                            -Dsonar.host.url=http://18.227.134.150:9000 \
                            -Dsonar.login=${sonarpassword}
                        """
                    }
                }
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean install'
                echo "Artifact built"
            }
        }

        stage('Create Docker Image') {
            steps {
                script {
                    echo "Building Docker image"
                    sh "docker build -t ${IMAGE_NAME}:${version} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhubpassword', variable: 'dockerhubpassword')]) {
                        sh "docker login -u pavansarvepalli -p ${dockerhubpassword}"
                    }
                    sh "docker push ${IMAGE_NAME}:${version}"
                    echo "Image pushed to Docker Hub"
                }
            }
        }

        stage('Update Deployment File in Git') {
            steps {
                echo "Updating deployment file in Git"
                script {
                    withCredentials([string(credentialsId: 'githubpassword', variable: 'githubpassword')]) {
                        sh """
                            git config user.name "pavan-sarvepalli"
                            git config user.email "sarvepallipvan55@gmail.com"

                           sed -i "s|javaapp:.*|javaapp:${env.version}|g" deploymentfiles/deployment.yml

                            git add deploymentfiles/deployment.yml
                            git commit -m "update deployment image version ${version}" || echo "No changes to commit"
                            git push https://${githubpassword}@github.com/${GIT_USERNAME}/${GIT_REPO_NAME}.git HEAD:main
                        """
                    }
                }
            }
        }
    }
}