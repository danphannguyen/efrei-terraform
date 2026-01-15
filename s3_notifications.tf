# Configuration des notifications S3 vers SNS
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.coffre_fort_rh.id

  topic {
    topic_arn = aws_sns_topic.alerte_securite.arn
    events    = ["s3:ObjectCreated:*"]
    filter_prefix = ""  # Optionnel : préfixe pour filtrer les objets
    filter_suffix = ""  # Optionnel : suffixe pour filtrer les objets
  }

  # Notification pour les suppressions aussi (optionnel)
  # topic {
  #   topic_arn = aws_sns_topic.alerte_securite.arn
  #   events    = ["s3:ObjectRemoved:*"]
  # }
}