# backend.tf
terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "keenal.patel" # Replace with your first and last name
    region = "ap-south-1"
  }
}