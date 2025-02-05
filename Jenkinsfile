pipeline {
    agent any
    environment {
        AWS_REGION = "ap-south-1"
        S3_BUCKET = "467.devops.candidate.exam"
        API_ENDPOINT = "https://api-endpoint-url" // Replace with actual endpoint
    }
    stages {
        stage("TF Init") {
            steps {
                sh 'terraform init'
            }
        }
        stage("Package Lambda") {
            steps {
                sh 'zip -r lambda.zip lambda_function.py'
            }
        }
        stage("TF Validate") {
            steps {
                sh 'terraform validate'
            }
        }
        stage("TF Plan") {
            steps {
                sh 'terraform plan'
            }
        }
        stage("TF Apply") {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
        stage("Upload Lambda") {
            steps {
                sh '''
                aws lambda update-function-code \
                --function-name devops-exam-lambda \
                --zip-file fileb://lambda.zip \
                --region ${AWS_REGION}
                '''
            }
        }
        stage("Update Lambda Config") {
            steps {
                script {
                    def envVars = [
                        "API_ENDPOINT=${API_ENDPOINT}",
                        "CANDIDATE_NAME=${NAME}",
                        "CANDIDATE_EMAIL=${EMAIL}",
                        "SUBNET_ID=${SUBNET_ID}"
                    ].join(',')
                    
                    sh """
                    aws lambda update-function-configuration \
                    --function-name devops-exam-lambda \
                    --region ${AWS_REGION} \
                    --environment "Variables={${envVars}}"
                    """
                }
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    def subnetId = sh(script: 'terraform output -raw subnet_id', returnStdout: true).trim()
                    
                    sh """
                    aws lambda wait function-updated --function-name devops-exam-lambda --region ${AWS_REGION}
                    
                    aws lambda invoke \
                    --function-name devops-exam-lambda \
                    --payload '{"subnet_id": "${subnetId}"}' \
                    --region ${AWS_REGION} \
                    --cli-binary-format raw-in-base64-out \
                    response.json
                    
                    echo "Lambda Response:"
                    cat response.json
                    """
                }
            }
        }
    }
}