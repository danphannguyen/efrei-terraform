# --- Amazon SNS ---
# Création du "Sujet" (le canal de diffusion)
resource "aws_sns_topic" "alerte_securite" {
  name = var.sns_topic_name
}

# Création de l'abonnement (Qui reçoit l'alerte ?)
resource "aws_sns_topic_subscription" "email_admin" {
  topic_arn = aws_sns_topic.alerte_securite.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

# Autorisation : S3 doit avoir le droit de publier dans ce sujet SNS
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerte_securite.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "SNS:Publish",
      Resource  = aws_sns_topic.alerte_securite.arn,
      Condition = {
        ArnLike = { "aws:SourceArn" = aws_s3_bucket.coffre_fort_rh.arn }
      }
    }]
  })
}