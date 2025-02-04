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
                --function-name devops-exam-lambda \
                --zip-file fileb://lambda.zip \
                --region $AWS_REGION
                '''
            }
        }
        stage("Invoke Lambda") {
            steps {
                script {
                    // Fetch subnet ID from Terraform output
                    def subnetId = sh(script: 'terraform output -raw subnet_id', returnStdout: true).trim()

                    // Invoke Lambda with dynamic subnet ID
                    def lambdaResponse = sh(script: """
                        aws lambda invoke --function-name devops-exam-lambda \
                        --payload '{"subnet_id": "${subnetId}"}' \
                        --log-type Tail output.json | jq -r '.LogResult' | base64 --decode
                    """, returnStdout: true).trim()

                    // Log the Lambda response
                    echo "Lambda Response: ${lambdaResponse}"
                }
            }
        }
    }
}