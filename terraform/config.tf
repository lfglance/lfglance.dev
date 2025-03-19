terraform {
  backend "s3" {
    region         = "us-west-2"
    bucket         = "your-tf-state-bucket"
    key            = "your.tfstate"
    dynamodb_table = "your-tf-state-table"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
