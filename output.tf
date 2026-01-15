# Fichiers permettant de spécifier les sorties des ressources créées
# - Résultats des services
# - Logs

# ===== Instances EC2 =====

output "vm1_public_ip" {
  description = "Adresse IP publique de la VM1"
  value       = aws_instance.vm1.public_ip
}

output "vm1_private_ip" {
  value = aws_instance.vm1.private_ip
}

output "vm2_public_ip" {
  description = "Adresse IP publique de la VM2"
  value       = aws_instance.vm2.public_ip
}

output "vm2_private_ip" {
  value = aws_instance.vm2.private_ip
}

# ===== S3 =====

output "nom_du_bucket" {
  value = aws_s3_bucket.coffre_fort_rh.id
}

# ===== KMS =====

output "id_de_la_cle_kms" {
  value = aws_kms_key.cle_documents_rh.key_id
}

# ===== SNS =====

output "sns_topic_arn" {
  description = "ARN du topic SNS pour les alertes brutes (S3 → Lambda)"
  value       = aws_sns_topic.alerte_securite.arn
}

output "sns_topic_formatted_arn" {
  description = "ARN du topic SNS pour les emails formatés (Lambda → Email)"
  value       = aws_sns_topic.alerte_securite_formatted.arn
}

output "sns_subscription_id" {
  description = "ID de l'abonnement email SNS"
  value       = aws_sns_topic_subscription.email_admin_formatted.id
}

output "confirmation_instructions" {
  description = "Instructions pour confirmer l'abonnement email"
  value       = "Après le déploiement, vérifiez votre email ${var.admin_email} et cliquez sur 'Confirm subscription' pour activer les notifications."
}