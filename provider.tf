# Contient les informations liées a/aux provider(s)

# Configuration du provider AWS pour Terraform
provider "aws" {
  region = var.aws_region # Région dans laquelle déployer les ressources
}

# (Optionnel) Spécifier la version du provider AWS 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
