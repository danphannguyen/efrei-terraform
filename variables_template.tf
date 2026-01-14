# Document ou l'on peut instancier des variables
# - réutilisables partout dans le même répertoire
# - prend le défault si rien n'est spécifier

# Région AWS où déployer les ressources
variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "your-region"       # <--- Add your region here
}

# Type d'instance EC2
variable "instance_type" {
  description = "Type d'instance EC2 (doit être éligible Free Tier)"
  type        = string
  default     = "t3.micro"          # <--- Edit your instance type here
}

# Nom de la paire de clés SSH à utiliser pour les instances
variable "key_name" {
  description = "Nom de la paire de cles EC2 pour SSH"
  type        = string
  default     = "terraform-key"      # <--- Edit your key name here
}

# Configuration SNS pour les alertes
variable "sns_topic_name" {
  description = "Nom du topic SNS pour les alertes de sécurité"
  type        = string
  default     = "alerte-depot-documents-sensibles"
}

variable "admin_email" {
  description = "Email de l'administrateur pour recevoir les alertes SNS"
  type        = string
  default     = "exemple@gmail.com"          # <--- Edit your email here
}

# Configuration S3 pour le coffre-fort RH
variable "s3_bucket_name" {
  description = "Nom du bucket S3 (doit être unique mondialement)"
  type        = string
  default     = "mon-coffre-fort-rh-demo-123456"          # <--- Edit your bucket name here
}

# Configuration KMS
variable "kms_key_alias" {
  description = "Alias de la clé KMS pour chiffrer les documents RH"
  type        = string
  default     = "alias/demo-documents-rh"
}