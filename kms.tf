data "aws_caller_identity" "current" {}

# Définition de la clé KMS
resource "aws_kms_key" "cle_documents_rh" {
  description             = "Cle pour chiffrer les documents RH"
  deletion_window_in_days = 7
  enable_key_rotation     = false
}

resource "aws_kms_alias" "alias_rh" {
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.cle_documents_rh.key_id
}

# Définition du S3
resource "aws_s3_bucket" "coffre_fort_rh" {
  # Le nom du bucket doit être unique mondialement
  bucket = var.s3_bucket_name
  force_destroy = true # Permet de détruire le bucket même s'il est plein (pour la démo)
}

# Définition de la configuration de chiffrement côté serveur pour le bucket S3
resource "aws_s3_bucket_server_side_encryption_configuration" "securite_bucket" {
  bucket = aws_s3_bucket.coffre_fort_rh.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cle_documents_rh.arn
    }
    bucket_key_enabled = true
  }
}
