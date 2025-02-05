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
                --region $AWS_REGION
                '''
            }
        }
        stage("Update Lambda Config") {
            steps {
                sh '''
                aws lambda update-function-configuration \
                --function-name devops-exam-lambda \
                --region $AWS_REGION \
                --environment "Variables={API_ENDPOINT=$API_ENDPOINT,CANDIDATE_NAME=$NAME,CANDIDATE_EMAIL=$EMAIL,SUBNET_ID=$SUBNET_ID}"
                '''
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    def subnetId = sh(script: 'terraform output -raw subnet_id', returnStdout: true).trim()
                    def payload = "{\"subnet_id\": \"${subnetId}\"}"
                    
                    def response = sh(
                        script: """
                        aws lambda invoke \
                        --function-name devops-exam-lambda \
                        --payload '${payload}' \
                        --region $AWS_REGION \
                        --log-type Tail \
                        response.json
                        
                        echo "Lambda Response:"
                        cat response.json
                        
                        echo "Lambda Logs:"
                        jq -r '.LogResult' response.json | base64 -d || true
                        """,
                        returnStdout: true
                    )
                    
                    echo "Complete Lambda Output: ${response}"
                }
            }
        }
    }
}