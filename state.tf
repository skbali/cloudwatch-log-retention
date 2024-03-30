terraform {
  backend "s3" {
    profile = "default"
    region  = "us-east-1"
    key     = "cloudwatch-log-retention/terraform.tfstate"
    bucket  = "sbali-tfstate"
  }
}