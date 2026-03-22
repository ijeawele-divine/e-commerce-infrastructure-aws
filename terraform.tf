terraform {
  cloud {
    organization = "teleios"

    workspaces {
      tags = ["e-commerce-divine"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}