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
        stage("Invoke Lambda") {
            steps {
                script {
                    // Fetch subnet ID from Terraform output
                    def subnetId = sh(script: 'terraform output -raw subnet_id', returnStdout: true).trim()
                    def name = sh(script: 'terraform output -raw name', returnStdout: true).trim()
                    def email = sh(script: 'terraform output -raw email', returnStdout: true).trim()

                    // Invoke Lambda with dynamic subnet ID
                    def lambdaResponse = sh(script: """
                        aws lambda invoke --function-name devops-exam-lambda \
                        --log-type Tail --cli-binary-format raw-in-base64-out /dev/stdout | jq
                    """, returnStdout: true).trim()

                    // Log the Lambda response
                    echo "Lambda Response: ${lambdaResponse}"
                }
            }
        }
    }
}
