pipeline {
    agent any
    environment {
        AWS_REGION = "ap-south-1"
        S3_BUCKET = "467.devops.candidate.exam"
    }
    stages {
        stage("TF Init") {
            steps {
                sh 'terraform init'
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
        stage("Package Lambda") {
            steps {
                sh 'zip -r lambda.zip lambda_function.py'
            }
        }
        stage("Upload Lambda") {
            steps {
                sh '''
                aws lambda update-function-code \
                --function-name devops_lambda \
                --zip-file fileb://lambda.zip \
                --region $AWS_REGION
                '''
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    def lambdaResponse = sh(script: '''
                    aws lambda invoke --function-name devops_lambda \
                    --payload '{"subnet_id": "subnet-xxxxx"}' \
                    --log-type Tail output.json | jq -r '.LogResult' | base64 --decode
                    ''', returnStdout: true).trim()
                    
                    echo "Lambda Response: ${lambdaResponse}"
                }
            }
        }
    }
}
