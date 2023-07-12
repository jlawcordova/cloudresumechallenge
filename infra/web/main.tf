terraform {
  backend "s3" {
    bucket = "cloud-resume-challenge-terraform-backend"
    key    = "tfstate"
    region = "ap-southeast-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.2"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "random_pet" "project" {
  length = 2
}

module "web" {
  source = "../modules/web"

  # Use a random name when the project variable is not set.
  project = coalesce(var.project, "cloud-resume-challenge-${random_pet.project.id}")
  domain = var.domain

  environment = var.environment
}
